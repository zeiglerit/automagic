=====================================================================
UNIFIED POLICY AUTOMATION ARCHITECTURE
Config Normalization → Policy Packaging → AAP Enforcement
=====================================================================

Author: James  
Document Type: Architecture White Paper  
Version: 1.0  
Repository Structure: Single Repo, Multi‑Pipeline  
Pipelines:
  - config-normalization-opa_1
  - policy-packaging_2
  - aap-enforcement_3

=====================================================================
1. EXECUTIVE SUMMARY
=====================================================================

This document describes a unified, multi‑stage policy automation 
architecture designed to:

- Normalize any configuration or IaC into a canonical JSON schema
- Generate and validate Rego policies using OPA and Policy‑as‑Code (PaC)
- Package and deploy validated policies to Ansible Automation Platform (AAP)
- Enforce policies at runtime across cloud, infrastructure, OS, network,
  and application layers

The system is implemented as a single repository containing three major 
pipelines:

1. config-normalization-opa_1  
   Converts any configuration → JSON → Rego → OPA/PAC → Git

2. policy-packaging_2  
   Takes Rego from Git → Python broker → Ansible → AAP policybooks

3. aap-enforcement_3  
   AAP loads and enforces Rego bundles continuously

This architecture supports full unit testing, PaC guardrails, and secure 
deployment workflows.

=====================================================================
2. REPOSITORY STRUCTURE (FINAL)
=====================================================================

/repo-root
│
├── config-normalization-opa_1/
│   ├── normalizer/
│   ├── rego-generator/
│   ├── opa-tests/
│   ├── pac-guardrails/
│   ├── schemas/
│   └── inputs/
│
├── policy-packaging_2/
│   ├── broker/
│   ├── policybook-builder/
│   ├── ansible/
│   │   ├── roles/
│   │   ├── inventories/
│   │   └── playbooks/
│   └── pac-guardrails/
│
├── aap-enforcement_3/
│   ├── aap-policybooks/
│   ├── aap-bundles/
│   └── aap-config/
│
├── deployment/
│   ├── terraform/
│   ├── ansible/
│   └── bootstrap/
│
├── policies/
│   ├── cloud/
│   ├── os/
│   ├── network/
│   ├── mlops/
│   └── iac/
│
├── tests/
│   ├── config-normalization-opa_1/
│   ├── policy-packaging_2/
│   └── aap-enforcement_3/
│
├── docs/
│   ├── architecture/
│   ├── pipelines/
│   └── governance/
│
└── README.md

=====================================================================
3. ARCHITECTURE OVERVIEW
=====================================================================

The architecture is built around three major pipelines:

---------------------------------------------------------------------
Pipeline A — config-normalization-opa_1
---------------------------------------------------------------------
Purpose:
  Convert any configuration → canonical JSON → Rego → OPA/PAC → Git

---------------------------------------------------------------------
Pipeline B — policy-packaging_2
---------------------------------------------------------------------
Purpose:
  Convert validated Rego → AAP policybooks → Ansible deployment

---------------------------------------------------------------------
Pipeline C — aap-enforcement_3
---------------------------------------------------------------------
Purpose:
  AAP loads and enforces Rego bundles at runtime

Each pipeline is independent but connected through Git and shared artifacts.

=====================================================================
4. PIPELINE A — config-normalization-opa_1
=====================================================================

Purpose:
  Normalize any configuration or IaC into canonical JSON, generate or 
  author Rego, validate with OPA/PAC, and commit validated policies to Git.

---------------------------------------------------------------------
4.1 PIPELINE FLOW DIAGRAM
---------------------------------------------------------------------

          +-------------------------+
          |  Raw Config / IaC       |
          |  (Terraform, K8s, etc.) |
          +------------+------------+
                       |
                       v
        +--------------+----------------+
        |  Normalizer (any → JSON)      |
        |  /config-normalization-opa_1/ |
        +--------------+----------------+
                       |
                       v
        +--------------+----------------+
        |  Rego Generator (optional)    |
        |  /rego-generator/             |
        +--------------+----------------+
                       |
                       v
        +--------------+----------------+
        |  OPA Tests & PaC Guardrails   |
        |  /opa-tests/                  |
        |  /pac-guardrails/             |
        +--------------+----------------+
                       |
                       v
          +------------+------------+
          |  Git Commit (validated) |
          +-------------------------+

---------------------------------------------------------------------
4.2 DIRECTORY STRUCTURE & FILENAMES
---------------------------------------------------------------------

Normalizer:
/config-normalization-opa_1/normalizer/
  - main.py
  - detectors/file_type.py
  - parsers/yaml_parser.py
  - parsers/json_parser.py
  - parsers/ini_parser.py
  - parsers/tf_parser.py
  - normalizers/cloud_normalizer.py
  - normalizers/k8s_normalizer.py
  - normalizers/os_normalizer.py
  - normalizers/network_normalizer.py
  - utils/logger.py
  - utils/flatten.py

Schemas:
/config-normalization-opa_1/schemas/canonical_schema.json

Rego Generator:
/config-normalization-opa_1/rego-generator/generate_rego.py

OPA Tests:
/config-normalization-opa_1/opa-tests/

PaC Guardrails:
/config-normalization-opa_1/pac-guardrails/

---------------------------------------------------------------------
4.3 TESTING STRATEGY
---------------------------------------------------------------------

- Unit tests for normalizer  
- Schema validation tests  
- Rego unit tests (opa test)  
- OPA linting (opa fmt, opa check)  
- PaC guardrail tests  
- Git pre‑commit hooks for policy validation  

=====================================================================
5. PIPELINE B — policy-packaging_2
=====================================================================

Purpose:
  Take validated Rego from Git, package it into AAP policybooks using 
  the Python broker, run control‑plane PaC guardrails, and deploy via Ansible.

---------------------------------------------------------------------
5.1 PIPELINE FLOW DIAGRAM
---------------------------------------------------------------------

          +-------------------------+
          |  Validated Rego in Git  |
          +------------+------------+
                       |
                       v
        +--------------+----------------+
        |  Python Broker                |
        |  /policy-packaging_2/broker/  |
        +--------------+----------------+
                       |
                       v
        +--------------+----------------+
        |  Policybook Builder           |
        |  /policybook-builder/         |
        +--------------+----------------+
                       |
                       v
        +--------------+----------------+
        |  PaC Guardrails (control)     |
        |  /pac-guardrails/             |
        +--------------+----------------+
                       |
                       v
          +------------+------------+
          |  Ansible Deployment     |
          |  /ansible/playbooks/    |
          +-------------------------+

---------------------------------------------------------------------
5.2 DIRECTORY STRUCTURE & FILENAMES
---------------------------------------------------------------------

Broker:
/policy-packaging_2/broker/
  - broker.py
  - policy_loader.py
  - metadata_builder.py

Policybook Builder:
/policy-packaging_2/policybook-builder/
  - build_policybook.py
  - bundle_packager.py

Ansible:
/policy-packaging_2/ansible/
  - playbooks/deploy_policybook.yml
  - inventories/hosts.ini
  - roles/aap_deploy/tasks/main.yml

PaC Guardrails:
/policy-packaging_2/pac-guardrails/

---------------------------------------------------------------------
5.3 TESTING STRATEGY
---------------------------------------------------------------------

- Broker unit tests  
- Policybook generation tests  
- Ansible linting  
- OPA guardrail tests on playbooks  
- Dry‑run tests  

=====================================================================
6. PIPELINE C — aap-enforcement_3
=====================================================================

Purpose:
  AAP loads and enforces Rego bundles continuously across infrastructure.

---------------------------------------------------------------------
6.1 PIPELINE FLOW DIAGRAM
---------------------------------------------------------------------

          +-------------------------+
          |  AAP Policybooks        |
          |  /aap-policybooks/      |
          +------------+------------+
                       |
                       v
        +--------------+----------------+
        |  AAP Controller               |
        |  Loads Rego Bundles           |
        +--------------+----------------+
                       |
                       v
        +--------------+----------------+
        |  Runtime Enforcement           |
        |  Violations, Reports, Logs     |
        +--------------+----------------+

---------------------------------------------------------------------
6.2 DIRECTORY STRUCTURE & FILENAMES
---------------------------------------------------------------------

AAP Policybooks:
/aap-enforcement_3/aap-policybooks/

AAP Bundles:
/aap-enforcement_3/aap-bundles/

AAP Config:
/aap-enforcement_3/aap-config/

---------------------------------------------------------------------
6.3 TESTING STRATEGY
---------------------------------------------------------------------

- Post‑deployment verification  
- Canary enforcement tests  
- Drift detection tests  
- Compliance report validation  

=====================================================================
7. DEPLOYMENT FOLDER
=====================================================================

/deployment/
  - terraform/
  - ansible/
  - bootstrap/

Contains Terraform for provisioning, Ansible for bootstrap, and scripts 
for initializing AAP, repos, and pipelines.

=====================================================================
8. PAC SECURING PAC (CONTROL‑PLANE GOVERNANCE)
=====================================================================

The system uses two layers of Rego:

---------------------------------------------------------------------
1. CONTROL‑PLANE POLICIES (PaC GUARDRAILS)
---------------------------------------------------------------------

Govern:
  - Pipelines  
  - Ansible playbooks  
  - Broker behavior  
  - Policybook deployment  
  - Git branch protections  
  - Required approvals  
  - Allowed scopes  

Locations:
/config-normalization-opa_1/pac-guardrails/
/policy-packaging_2/pac-guardrails/

---------------------------------------------------------------------
2. BUSINESS POLICIES (RUNTIME ENFORCEMENT)
---------------------------------------------------------------------

Govern:
  - Cloud resources  
  - OS configs  
  - Network configs  
  - IaC  
  - ML pipelines  

Location:
/policies/

This separation prevents recursion and ensures the pipelines themselves 
remain secure.

=====================================================================
9. END‑TO‑END ARCHITECTURE DIAGRAM
=====================================================================

+---------------------------------------------------------------+
|            CONFIG NORMALIZATION & AUTHORING (1)               |
|  /config-normalization-opa_1/                                 |
|                                                               |
|  Config → JSON → Rego → OPA/PAC → Git                         |
+-------------------------------+-------------------------------+
                                |
                                v
+---------------------------------------------------------------+
|            POLICY PACKAGING & DEPLOYMENT (2)                  |
|  /policy-packaging_2/                                          |
|                                                               |
|  Rego → Broker → Policybooks → Ansible → AAP                  |
+-------------------------------+-------------------------------+
                                |
                                v
+---------------------------------------------------------------+
|            AAP RUNTIME ENFORCEMENT (3)                        |
|  /aap-enforcement_3/                                          |
|                                                               |
|  AAP loads bundles → evaluates → enforces → reports           |
+---------------------------------------------------------------+

=====================================================================
10. README.md (FINAL VERSION)
=====================================================================

# Unified Policy Automation & Enforcement Repository

This repository contains a complete, modular, multi‑pipeline system for:

1. Normalizing any configuration or IaC into canonical JSON
2. Generating and validating Rego policies using OPA and PaC
3. Packaging and deploying policies to Ansible Automation Platform (AAP)
4. Enforcing policies at runtime across infrastructure, cloud, and applications

## Pipelines

### config-normalization-opa_1
Location: /config-normalization-opa_1/

Converts any config → JSON → Rego → OPA/PAC → Git.

### policy-packaging_2
Location: /policy-packaging_2/

Takes Rego from Git → Python broker → Ansible → AAP policybooks.

### aap-enforcement_3
Location: /aap-enforcement_3/

AAP loads and enforces Rego bundles continuously.

## Deployment
Location: /deployment/

Contains Terraform, Ansible, and bootstrap scripts for provisioning and 
initializing the system.

## Policies
Location: /policies/

Contains business-plane Rego policies organized by domain.

## Tests
Location: /tests/

Contains unit tests for all pipelines and components.

## Documentation
Location: /docs/

Contains architecture diagrams, pipeline descriptions, governance models, 
and white papers.

=====================================================================
END OF DOCUMENT
=====================================================================