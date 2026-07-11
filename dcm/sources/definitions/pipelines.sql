DEFINE TABLE {{ db_name }}.RAW.ORDERS (
  order_id NUMBER,
  customer_id NUMBER,
  order_date TIMESTAMP_NTZ,
  product_name VARCHAR,
  quantity NUMBER,
  unit_price NUMBER(10,2),
  status VARCHAR,
  region VARCHAR,
  loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

DEFINE DYNAMIC TABLE {{ db_name }}.TRANSFORMED.CLEANED_ORDERS
  TARGET_LAG = '{{ target_lag }}'
  WAREHOUSE = CICD_DEMO_WH_{{ env }}
  AS
    SELECT
      order_id,
      customer_id,
      order_date,
      TRIM(UPPER(product_name)) AS product_name,
      quantity,
      unit_price,
      quantity * unit_price AS total_amount,
      UPPER(TRIM(status)) AS status,
      UPPER(TRIM(region)) AS region,
      loaded_at
    FROM {{ db_name }}.RAW.ORDERS
    WHERE order_id IS NOT NULL
      AND quantity > 0;

DEFINE DYNAMIC TABLE {{ db_name }}.PRESENTATION.ORDER_SUMMARY
  TARGET_LAG = '{{ target_lag }}'
  WAREHOUSE = CICD_DEMO_WH_{{ env }}
  AS
    SELECT
      region,
      DATE_TRUNC('day', order_date) AS order_day,
      COUNT(*) AS total_orders,
      SUM(total_amount) AS total_revenue,
      AVG(total_amount) AS avg_order_value,
      COUNT(DISTINCT customer_id) AS unique_customers
    FROM {{ db_name }}.TRANSFORMED.CLEANED_ORDERS
    WHERE status = 'COMPLETED'
    GROUP BY region, DATE_TRUNC('day', order_date);
