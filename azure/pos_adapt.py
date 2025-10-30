# adaptive_job.py
import time
import psutil
import random
from concurrent.futures import ThreadPoolExecutor

# Simulated workload
def simulated_task(task_id):
    start = time.time()
    data = [random.random() for _ in range(10_000)]  # memory pressure
    _ = sum(data)
    time.sleep(random.uniform(0.05, 0.2))  # simulate I/O
    duration = time.time() - start
    print(f"[Task {task_id}] completed in {duration:.3f}s")
    return duration

# System load monitor
def get_system_load():
    cpu = psutil.cpu_percent(interval=0.1)
    mem = psutil.virtual_memory().percent
    return cpu, mem

# Adaptive pool size logic
def calculate_pool_size(cpu, mem, base=8):
    load_factor = max(cpu / 100, mem / 100)
    return max(1, int(base * (1 - load_factor)))

# Main runner
def run_adaptive_pool(num_batches=10):
    task_id = 0
    for batch in range(num_batches):
        cpu, mem = get_system_load()
        pool_size = calculate_pool_size(cpu, mem)
        print(f"\n[Batch {batch}] CPU={cpu:.1f}%, MEM={mem:.1f}%, Pool={pool_size}")

        with ThreadPoolExecutor(max_workers=pool_size) as pool:
            futures = [pool.submit(simulated_task, task_id + i) for i in range(pool_size)]
            task_id += pool_size
            for f in futures:
                f.result()
        time.sleep(1)

if __name__ == "__main__":
    run_adaptive_pool()
