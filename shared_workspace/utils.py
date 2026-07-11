import snowflake.snowpark as snowpark
from snowflake.snowpark.functions import col, lit, current_timestamp


def get_session_info(session: snowpark.Session) -> dict:
    """Return current session context info."""
    result = session.sql("""
        SELECT
            CURRENT_ACCOUNT() AS account,
            CURRENT_ROLE() AS role,
            CURRENT_WAREHOUSE() AS warehouse,
            CURRENT_DATABASE() AS database,
            CURRENT_SCHEMA() AS schema,
            CURRENT_USER() AS user
    """).collect()[0]
    return result.as_dict()


def row_count(session: snowpark.Session, table_name: str) -> int:
    """Quick row count for a table."""
    return session.table(table_name).count()


def freshness_check(session: snowpark.Session, table_name: str, timestamp_col: str = "LOADED_AT") -> dict:
    """Check data freshness for a table with a timestamp column."""
    result = session.sql(f"""
        SELECT
            COUNT(*) AS total_rows,
            MAX({timestamp_col}) AS latest_record,
            DATEDIFF('minute', MAX({timestamp_col}), CURRENT_TIMESTAMP()) AS minutes_since_last_load
        FROM {table_name}
    """).collect()[0]
    return result.as_dict()


def validate_no_nulls(session: snowpark.Session, table_name: str, columns: list) -> dict:
    """Validate that specified columns have no NULL values."""
    results = {}
    for c in columns:
        null_count = session.table(table_name).filter(col(c).is_null()).count()
        results[c] = {"null_count": null_count, "passed": null_count == 0}
    return results
