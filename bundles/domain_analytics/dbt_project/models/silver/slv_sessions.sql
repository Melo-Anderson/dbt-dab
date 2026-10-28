{{ config(
    materialized='incremental',
    unique_key='session_id',
    liquid_clustered_by=['player_id', 'device_type']
) }}

WITH staged AS (
    SELECT *
    FROM {{ ref('stg_sessions') }}
    {% if is_incremental() %}
    WHERE _ingested_at > (SELECT COALESCE(MAX(_ingested_at), '1900-01-01') FROM {{ this }})
    {% endif %}
)

SELECT
    session_id,
    player_id,
    device_type,
    ip_address,
    session_start,
    _ingested_at,
    CURRENT_TIMESTAMP() AS _processed_at
FROM staged
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY session_id
    ORDER BY session_start DESC, _ingested_at DESC
) = 1
