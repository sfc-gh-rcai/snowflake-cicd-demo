DEFINE WAREHOUSE CICD_DEMO_WH_{{ env }}
  WITH
    warehouse_size = '{{ wh_size }}'
    auto_suspend = 300
    auto_resume = TRUE
    initially_suspended = TRUE;
