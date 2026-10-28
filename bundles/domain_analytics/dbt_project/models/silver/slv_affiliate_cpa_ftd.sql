{{ config(
    materialized='incremental',
    unique_key='player_id',
    liquid_clustered_by=['affiliate_id', 'country']
) }}

WITH staged AS (
    SELECT *
    FROM {{ ref('stg_affiliate_cpa_ftd') }}
    {% if is_incremental() %}
    WHERE _ingested_at > (SELECT COALESCE(MAX(_ingested_at), '1900-01-01') FROM {{ this }})
    {% endif %}
)

SELECT
    affiliate_id,
    player_id,
    country,
    clicks,
    registrations,
    ftd,
    cpa_value,
    cpa_qualified,
    _ingested_at,
    CURRENT_TIMESTAMP() AS _processed_at
FROM staged
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY player_id
    ORDER BY _ingested_at DESC
) = 1
