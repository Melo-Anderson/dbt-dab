{{ config(
    materialized='incremental',
    unique_key='player_id',
    liquid_clustered_by=['city']
) }}

WITH staged AS (
    SELECT *
    FROM {{ ref('stg_players') }}
    {% if is_incremental() %}
    WHERE _ingested_at > (SELECT COALESCE(MAX(_ingested_at), '1900-01-01') FROM {{ this }})
    {% endif %}
)

SELECT
    player_id,
    email,
    city,
    registration_timestamp,
    _ingested_at,
    CURRENT_TIMESTAMP() AS _processed_at
FROM staged
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY player_id
    ORDER BY registration_timestamp DESC, _ingested_at DESC
) = 1
