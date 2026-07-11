# CI/CD Best Practices for Snowflake

## Do's

| # | Practice | Why |
|---|----------|-----|
| 1 | **Use OIDC / workload identity** for CI/CD auth | No long-lived secrets to rotate; auto-expires |
| 2 | **Separate DEV / STAGING / PROD** environments | Isolate blast radius; test before you break prod |
| 3 | **Always plan before deploy** | Catch unintended DROP/ALTER before they execute |
| 4 | **Use DCM Projects for declarative state** | Idempotent, repeatable, diffable infrastructure |
| 5 | **Version control everything** | Audit trail, rollback capability, team collaboration |
| 6 | **Use dedicated service users for CI/CD** | Traceability, least privilege per pipeline |
| 7 | **Run `snow dcm plan` on every PR** | Reviewable change previews before merge |
| 8 | **Use Jinja templating for env differences** | Same code, different config — no drift |
| 9 | **Tag deployments with commit SHA** | Link Snowflake state to Git state for audit |
| 10 | **Test in DEV, validate in STAGING, deploy to PROD** | Progressive confidence in changes |

## Don'ts

| # | Anti-Pattern | Why It's Bad |
|---|--------------|--------------|
| 1 | **Store credentials in Git** | Security risk, rotation nightmare |
| 2 | **Use ACCOUNTADMIN for CI/CD** | Overprivileged, no audit granularity |
| 3 | **Deploy to PROD without plan** | Unreviewed changes can break things |
| 4 | **Use imperative scripts with IF NOT EXISTS** | Drift-prone, not truly idempotent |
| 5 | **Manual deployments alongside CI/CD** | Causes drift between Git and actual state |
| 6 | **Share one service user across pipelines** | No traceability per pipeline |
| 7 | **Skip the plan step in automation** | You lose the safety net |
| 8 | **Mix environment configs in SQL code** | Should live in manifest/config, not definitions |
| 9 | **Deploy without a rollback strategy** | Need ability to revert bad changes |
| 10 | **Ignore DCM plan warnings about DROP** | Accidental data loss is permanent |

## Authentication Patterns

### Recommended: OIDC Workload Identity Federation

```
CI/CD Runner → Requests OIDC token → Snowflake validates issuer → Session created
```

- **GitHub Actions**: Use `SNOWFLAKE_AUTHENTICATOR: EXTERNALBROWSER` or configure OIDC
- **Azure DevOps**: Use Managed Identity or federated credentials
- **GitLab**: Use CI_JOB_JWT with Snowflake's external OAuth

### Acceptable: Key-Pair Authentication

```
CI/CD Runner → Uses private key → Snowflake validates against stored public key
```

- Store private key as a CI/CD secret (never in code)
- Rotate keys on a schedule (90 days recommended)

### Avoid: Password-Based Auth

- Hard to rotate
- Easy to leak
- No support for MFA in automation

## Environment Separation Patterns

### Pattern 1: Same Account, Different Databases (Simple)
```
Account: MYORG-MYACCOUNT
├── CICD_DEMO_ANALYTICS_DEV (database)
├── CICD_DEMO_ANALYTICS_STAGING (database)
└── CICD_DEMO_ANALYTICS_PROD (database)
```
Best for: Small teams, getting started, lower cost.

### Pattern 2: Separate Accounts (Enterprise)
```
MYORG-DEV_ACCOUNT     → DEV database objects
MYORG-STAGING_ACCOUNT → STAGING database objects
MYORG-PROD_ACCOUNT    → PROD database objects
```
Best for: Strict isolation, separate billing, compliance requirements.

### Pattern 3: Hybrid (Common)
```
MYORG-NONPROD → DEV + STAGING databases
MYORG-PROD    → PROD databases only
```
Best for: Balance between isolation and cost.

## Rollback Strategies

1. **Git revert + redeploy**: Revert the commit, push, let CI/CD redeploy previous state
2. **DCM plan to previous version**: Check out the previous Git tag, run `snow dcm deploy`
3. **Time Travel**: For data issues, use Snowflake Time Travel to restore tables
4. **Blue-Green**: Maintain two sets of objects, switch a pointer (advanced)

## Pipeline Promotion Flow

```
Developer → Feature Branch → PR (plan runs) → Review → Merge to main → Auto-deploy PROD
                                    ↓
                              Plan output posted
                              as PR comment for review
```
