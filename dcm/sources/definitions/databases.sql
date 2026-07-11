{% for e in environments %}
DEFINE DATABASE {{ e.db_name }};
{% endfor %}
