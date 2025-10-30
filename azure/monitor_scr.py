# monitor_util.py
import time
import psutil

def get_system_load():
    return psutil.cpu_percent(interval=0.1), psutil.virtual_memory().percent

def calculate_pool_size(cpu, mem, base=8):
    load_factor = max(cpu / 100, mem / 100)
    return max(1, int(base * (1 - load_factor)))

def monitor_loop(interval=1):
    print("Monitoring system load. Press Ctrl+C to stop.\n")
    while True:
        cpu, mem = get_system_load()
        pool = calculate_pool_size(cpu, mem)
        print(f"CPU: {cpu:.1f}% | MEM: {mem:.1f}% | Suggested Pool Size: {pool}")
        time.sleep(interval)

if __name__ == "__main__":
    monitor_loop()
