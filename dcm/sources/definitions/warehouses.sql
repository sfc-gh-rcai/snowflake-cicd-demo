{% for e in environments %}
DEFINE WAREHOUSE CICD_DEMO_WH_{{ e.env }}
  WITH
    warehouse_size = '{{ e.wh_size }}'
    auto_suspend = 300
    auto_resume = TRUE
    initially_suspended = TRUE;
{% endfor %}
