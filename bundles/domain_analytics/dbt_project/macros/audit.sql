{% macro add_audit_columns() %}
    current_timestamp() as _loaded_at,
    '{{ invocation_id }}' as _dbt_invocation_id
{% endmacro %}

{% macro surrogate_key(columns) %}
    sha2(concat_ws('||', {% for c in columns %}coalesce(cast({{ c }} as string), '_null_'){% if not loop.last %}, {% endif %}{% endfor %}), 256)
{% endmacro %}
