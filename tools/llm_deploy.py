# usage: llm_interface.py [-h] [--prompt PROMPT] [--system-message SYSTEM_MESSAGE]
#                        [--train TRAIN] [--pull PULL]
#
# Interact with or train a local LLM via Ollama
#
# optional arguments:
#  -h, --help            show this help message and exit
#  --prompt PROMPT       Prompt to send to the model
#  --system-message SYSTEM_MESSAGE
#                        Optional system message to guide model behavior
#  --train TRAIN         Path to training data (.json, .txt, .csv, .db)
# --pull PULL           URL to pull model from (Ollama-style)
#
# Examples:
#  python llm_interface.py --prompt "Explain firewall rules"
#  python llm_interface.py --prompt "What is zero trust?" --system-message "You are a cybersecurity expert."
#  python llm_interface.py --pull https://ollama.ai/library/llama3
#  python llm_interface.py --train ./training_data.json
#  python llm_interface.py --train ./network_qa.db

import argparse
import json
import subprocess
import sys
from pathlib import Path

# Optional imports for training data formats
import sqlite3
import pandas as pd
from ollama import chat

def load_json(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def pull_model(url):
    model_name = url.strip().split('/')[-1]
    print(f"Pulling model '{model_name}' from {url}...")
    subprocess.run(['ollama', 'pull', model_name], check=True)

def train_model(data_path):
    ext = Path(data_path).suffix.lower()
    print(f"Loading training data from {data_path}...")

    if ext == '.json':
        data = load_json(data_path)

    elif ext == '.txt':
        with open(data_path, 'r', encoding='utf-8') as f:
            data = f.read().splitlines()

    elif ext == '.csv':
        df = pd.read_csv(data_path)
        data = df.to_dict(orient='records')

    elif ext == '.db':
        conn = sqlite3.connect(data_path)
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM training_data")  # assumes table named 'training_data'
        columns = [desc[0] for desc in cursor.description]
        data = [dict(zip(columns, row)) for row in cursor.fetchall()]
        conn.close()

    else:
        print(f"Unsupported training file type: {ext}")
        sys.exit(1)

    # Placeholder for actual training logic
    print("Training data loaded (showing first 3 entries):")
    if isinstance(data, list):
        print(json.dumps(data[:3], indent=2))
    else:
        print(str(data)[:500])

def interact_with_model(prompt, system_message=None):
    messages = []
    if system_message:
        messages.append({'role': 'system', 'content': system_message})
    messages.append({'role': 'user', 'content': prompt})

    response = chat(model='llama3', messages=messages)
    print(f"\n Response:\n{response['message']['content']}")

def main():
    parser = argparse.ArgumentParser(
        description="Interact with or train a local LLM via Ollama",
        epilog="""
Examples:
  python llm_interface.py --prompt "Explain firewall rules"
  python llm_interface.py --prompt "What is zero trust?" --system-message "You are a cybersecurity expert."
  python llm_interface.py --pull https://ollama.ai/library/llama3
  python llm_interface.py --train ./training_data.json
  python llm_interface.py --train ./network_qa.db
        """,
        formatter_class=argparse.RawTextHelpFormatter
    )

    parser.add_argument('--prompt', type=str, help="Prompt to send to the model")
    parser.add_argument('--system-message', type=str, help="Optional system message")
    parser.add_argument('--train', type=str, help="Path to training data (.json, .txt, .csv, .db)")
    parser.add_argument('--pull', type=str, help="URL to pull model from")

    args = parser.parse_args()

    if args.pull:
        pull_model(args.pull)

    if args.train:
        train_model(args.train)

    if args.prompt:
        interact_with_model(args.prompt, args.system_message)

    if not any([args.pull, args.train, args.prompt]):
        print("No action specified. Use --prompt, --train, or --pull. Run with --help for examples.")
        sys.exit(1)

if __name__ == "__main__":
    main()



