# Snowflake CI/CD Best Practices Demo

A reusable demo showcasing Snowflake's DevOps capabilities: Git Workspaces, Shared Workspaces, DCM Projects, Pipeline Builder, and CI/CD automation.

## What's Inside

```
├── manifest.yml                     # DCM project manifest (DEV + PROD targets)
├── sources/definitions/             # Declarative Snowflake object definitions
│   ├── databases.sql
│   ├── schemas.sql
│   ├── warehouses.sql
│   ├── roles.sql
│   └── pipelines.sql               # Dynamic Tables data pipeline
├── shared_workspace/                # Team collaboration examples
│   ├── utils.py                    # Shared Python utilities
│   └── common_queries.sql          # Reusable SQL patterns
├── .github/workflows/
│   └── snowflake-cicd.yml          # GitHub Actions (plan-on-PR, deploy-on-merge)
├── azure-pipelines.yml             # Azure DevOps equivalent
└── docs/
    └── best-practices.md           # CI/CD Do's and Don'ts
```

## Quick Start

### 1. Connect this repo to Snowflake

```sql
CREATE OR REPLACE API INTEGRATION CICD_DEMO_GITHUB_API_INTEGRATION
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-rcai')
  ENABLED = TRUE;

CREATE OR REPLACE SECRET CICD_DEMO_GITHUB_PAT
  TYPE = password
  USERNAME = 'sfc-gh-rcai'
  PASSWORD = '<your-github-pat>';

CREATE OR REPLACE GIT REPOSITORY CICD_DEMO_GIT_REPO
  API_INTEGRATION = CICD_DEMO_GITHUB_API_INTEGRATION
  GIT_CREDENTIALS = CICD_DEMO_GITHUB_PAT
  ORIGIN = 'https://github.com/sfc-gh-rcai/snowflake-cicd-demo.git';
```

### 2. Preview changes

```bash
snow dcm plan --target DEV
```

### 3. Deploy

```bash
snow dcm deploy --target DEV
```

## Key Concepts

- **DCM Projects**: Declarative infrastructure-as-code for Snowflake (like Terraform, but native)
- **Plan then Deploy**: Always preview changes before applying them
- **Jinja Templating**: Same definitions, different configs per environment
- **Pipeline Builder**: Visual pipeline design that produces DCM-compatible code

## CI/CD Platforms

| Platform | File | Status |
|----------|------|--------|
| GitHub Actions | `.github/workflows/snowflake-cicd.yml` | Primary demo |
| Azure DevOps | `azure-pipelines.yml` | Reference |

Both use the same `snow dcm` commands under the hood.

## Environment Strategy

| Target | Database | Warehouse Size | Target Lag |
|--------|----------|----------------|------------|
| DEV | CICD_DEMO_ANALYTICS_DEV | X-SMALL | 1 hour |
| PROD | CICD_DEMO_ANALYTICS_PROD | MEDIUM | 5 minutes |
