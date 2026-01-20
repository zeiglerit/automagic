#!/usr/bin/env python3
"""
Reusable Python script scaffold with CLI, logging, and JSON export.
"""

import argparse
import logging
import json
import sys
from pathlib import Path

# ----------------------------
# Logging configuration
# ----------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)]
)

# ----------------------------
# Core logic
# ----------------------------
def process_data(input_value: str) -> dict:
    """
    Example function: replace with your SDK exploration or automation logic.
    Returns a dictionary for JSON export.
    """
    logging.info("Processing input value...")
    result = {
        "input": input_value,
        "length": len(input_value),
        "uppercase": input_value.upper()
    }
    logging.debug(f"Result: {result}")
    return result

# ----------------------------
# CLI argument parsing
# ----------------------------
def parse_args():
    parser = argparse.ArgumentParser(
        description="Example scaffold for Python automation scripts"
    )
    parser.add_argument(
        "value",
        help="Input string to process"
    )
    parser.add_argument(
        "--output",
        "-o",
        type=Path,
        default=None,
        help="Optional path to save JSON output"
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Enable debug logging"
    )
    return parser.parse_args()

# ----------------------------
# Main entry point
# ----------------------------
def main():
    args = parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    result = process_data(args.value)

    if args.output:
        logging.info(f"Saving results to {args.output}")
        args.output.write_text(json.dumps(result, indent=2))
    else:
        logging.info("Printing results to stdout")
        print(json.dumps(result, indent=2))

if __name__ == "__main__":
    main()