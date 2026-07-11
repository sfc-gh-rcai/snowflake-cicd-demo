{% for e in environments %}
DEFINE SCHEMA {{ e.db_name }}.RAW;
DEFINE SCHEMA {{ e.db_name }}.TRANSFORMED;
DEFINE SCHEMA {{ e.db_name }}.PRESENTATION;
{% endfor %}
