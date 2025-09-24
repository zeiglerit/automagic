import subprocess
import os

def run(cmd, cwd=None):
    """Run a shell command and return output as list of lines"""
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd=cwd).stdout.strip().splitlines()

# === Terraform-managed resources ===
tf_resources = run("terraform state list")

# === AWS resources (Lambda example) ===
aws_resources = run("aws lambda list-functions --query 'Functions[].FunctionName' --output text --region us-east-2")

# === GCP resources (requires gcloud auth login) ===
# This runs from the 'gcp/' folder in your repo root
gcp_resources = run("gcloud asset search-all-resources --format='value(name)'", cwd="gcp")

# === Normalize lengths ===
max_len = max(len(tf_resources), len(aws_resources), len(gcp_resources))
tf_resources += [''] * (max_len - len(tf_resources))
aws_resources += [''] * (max_len - len(aws_resources))
gcp_resources += [''] * (max_len - len(gcp_resources))

# === Format side-by-side ===
output = ["{:<50} | {:<40} | {}".format(tf, aws, gcp) for tf, aws, gcp in zip(tf_resources, aws_resources, gcp_resources)]

# === Print with pager ===
os.system('echo "{}" | more'.format('\n'.join(output)))
