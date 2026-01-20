import unittest
import os
import yaml

class TestPipelineBuild(unittest.TestCase):
    def test_config_parsing(self):
        with open("config.yaml") as f:
            cfg = yaml.safe_load(f)
        self.assertIn("image_name", cfg)
        self.assertTrue(cfg["image_name"].startswith("insightedge"))

    def test_dockerfile_exists(self):
        self.assertTrue(os.path.exists("Dockerfile"))

    def test_dockerfile_non_root(self):
        with open("Dockerfile") as f:
            content = f.read()
        self.assertNotIn("USER root", content)

    def test_requirements_exist(self):
        self.assertTrue(os.path.exists("requirements.txt"))

    def test_tensorboard_hook(self):
        with open("train.py") as f:
            content = f.read()
        self.assertIn("TensorBoard", content)

    def test_teardown_script_safe(self):
        with open("tear_down.sh") as f:
            content = f.read()
        self.assertIn("az group delete", content)
        self.assertIn("--yes", content)
