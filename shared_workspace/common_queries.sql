-- Common Queries for Data Engineering Teams
-- Import into your workspace notebooks or use as reference

-- ============================================================
-- Data Freshness Check
-- ============================================================
SELECT
    table_catalog AS database_name,
    table_schema,
    table_name,
    row_count,
    bytes,
    last_altered
FROM information_schema.tables
WHERE table_schema NOT IN ('INFORMATION_SCHEMA')
ORDER BY last_altered DESC
LIMIT 20;

-- ============================================================
-- Pipeline Health: Dynamic Table Refresh Status
-- ============================================================
SELECT
    name,
    schema_name,
    target_lag,
    refresh_mode,
    scheduling_state,
    last_completed_refresh_time,
    DATEDIFF('minute', last_completed_refresh_time, CURRENT_TIMESTAMP()) AS minutes_since_refresh
FROM TABLE(information_schema.dynamic_tables())
ORDER BY last_completed_refresh_time DESC;

-- ============================================================
-- Warehouse Credit Usage (Last 7 Days)
-- ============================================================
SELECT
    warehouse_name,
    DATE_TRUNC('day', start_time) AS usage_day,
    SUM(credits_used) AS credits_used
FROM snowflake.account_usage.warehouse_metering_history
WHERE start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
GROUP BY warehouse_name, usage_day
ORDER BY usage_day DESC, credits_used DESC;

-- ============================================================
-- Role Grants Audit
-- ============================================================
SELECT
    grantee_name,
    role,
    granted_by,
    created_on
FROM snowflake.account_usage.grants_to_users
WHERE deleted_on IS NULL
  AND role LIKE 'CICD_DEMO_%'
ORDER BY created_on DESC;
