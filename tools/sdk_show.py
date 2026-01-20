#!/usr/bin/env python3
import sys
import importlib
import inspect
import pkgutil
import json


# python3 az_sdk_show.py sklearn.linear_model
# python3 az_sdk_show.py sklearn.linear_model --json
# python3 az_sdk_show.py langchain_openai.OpenAI --private=yes

def introspect(target: str, as_json: bool = False, private_enabled: bool = False):
    result = {}

    try:
        # Handle wildcard: e.g. sklearn.*
        if target.endswith(".*"):
            base_module = target[:-2]
            mod = importlib.import_module(base_module)
            result["package"] = base_module
            result["submodules"] = []

            for loader, name, ispkg in pkgutil.iter_modules(mod.__path__):
                if name.startswith("_"):
                    continue  # skip internal modules
                full_name = f"{base_module}.{name}"
                sub_info = {"name": full_name, "classes": [], "functions": []}

                try:
                    submod = importlib.import_module(full_name)
                except Exception as e:
                    sub_info["error"] = str(e)
                    result["submodules"].append(sub_info)
                    continue

                # Classes
                for n, obj in inspect.getmembers(submod, inspect.isclass):
                    if obj.__module__.startswith(base_module):
                        sub_info["classes"].append(n)

                # Functions
                for n, obj in inspect.getmembers(submod, inspect.isfunction):
                    if obj.__module__.startswith(base_module):
                        sub_info["functions"].append(n)

                result["submodules"].append(sub_info)

        # If user passed module.class
        elif "." in target:
            parts = target.split(".")
            module_name = ".".join(parts[:-1])
            class_name = parts[-1]

            mod = importlib.import_module(module_name)
            cls = getattr(mod, class_name, None)

            if cls is None:
                result["error"] = f"Class {class_name} not found in {module_name}"
            else:
                class_info = {
                    "class": f"{module_name}.{class_name}",
                    "methods": [],
                    "attributes": []
                }

                # Collect methods (class-level only)
                for name, obj in inspect.getmembers(cls, inspect.isfunction):
                    class_info["methods"].append(f"{name}{inspect.signature(obj)}")

                # Determine whether to inspect class or instance
                if private_enabled:
                    try:
                        obj_instance = cls()
                        members = inspect.getmembers(obj_instance)
                    except Exception:
                        members = inspect.getmembers(cls)
                else:
                    members = inspect.getmembers(cls)

                # Collect attributes
                for name, obj in members:
                    if not private_enabled and name.startswith("_"):
                        continue
                    if not inspect.isroutine(obj):
                        class_info["attributes"].append(name)

                result = class_info

        else:
            # Just a module
            mod = importlib.import_module(target)
            result["module"] = target
            result["classes"] = []
            result["functions"] = []

            for n, obj in inspect.getmembers(mod, inspect.isclass):
                if obj.__module__.startswith(target):
                    result["classes"].append(n)

            for n, obj in inspect.getmembers(mod, inspect.isfunction):
                if obj.__module__.startswith(target):
                    result["functions"].append(n)

    except ModuleNotFoundError:
        result["error"] = f"Module {target} not found."

    # Output formatting
    if as_json:
        print(json.dumps(result, indent=2))
    else:
        if "error" in result:
            print(result["error"])
            return

        if "package" in result:
            print(f"\n=== Package {result['package']} ===")
            for sub in result["submodules"]:
                print(f"\n--- Submodule {sub['name']} ---")
                if "error" in sub:
                    print(f"  (could not import: {sub['error']})")
                    continue
                if sub["classes"]:
                    print("Classes:")
                    for cls in sub["classes"]:
                        print(f"  {cls}")
                else:
                    print("  (no classes found)")
                if sub["functions"]:
                    print("Functions:")
                    for fn in sub["functions"]:
                        print(f"  {fn}")

        elif "class" in result:
            print(f"\n=== Class {result['class']} ===")
            print("Methods:")
            for m in result["methods"]:
                print(f"  {m}")
            print("\nAttributes:")
            for a in result["attributes"]:
                print(f"  {a}")

        elif "module" in result:
            print(f"\n=== Module {result['module']} ===")
            print("\nClasses:")
            for cls in result["classes"]:
                print(f"  {cls}")
            print("\nFunctions:")
            for fn in result["functions"]:
                print(f"  {fn}")


if __name__ == "__main__":
    args = sys.argv[1:]

    if not args:
        target = input("Enter module, module.class, or module.* to inspect: ")
        as_json = False
        private_enabled = False
    else:
        as_json = "--json" in args
        private_enabled = "--private=yes" in args
        target = [a for a in args if not a.startswith("--")][0]

    introspect(target, as_json, private_enabled)