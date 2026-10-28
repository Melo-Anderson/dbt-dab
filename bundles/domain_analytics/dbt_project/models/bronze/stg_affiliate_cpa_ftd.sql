{{ config(
    materialized='view'
) }}

WITH source_data AS (
    SELECT * FROM {{ source('raw', 'affiliate_cpa_ftd') }}
)

SELECT
    TRY_CAST(affiliate_id AS STRING) AS affiliate_id,
    TRY_CAST(player_id AS STRING) AS player_id,
    UPPER(TRIM(TRY_CAST(country AS STRING))) AS country,
    COALESCE(TRY_CAST(clicks AS BIGINT), 0) AS clicks,
    COALESCE(TRY_CAST(registrations AS BIGINT), 0) AS registrations,
    COALESCE(TRY_CAST(ftd AS BIGINT), 0) AS ftd,
    COALESCE(TRY_CAST(cpa_value AS DECIMAL(18, 2)), 0.0) AS cpa_value,
    CASE WHEN COALESCE(TRY_CAST(ftd AS BIGINT), 0) > 0 THEN TRUE ELSE FALSE END AS cpa_qualified,
    CURRENT_TIMESTAMP() AS _ingested_at,
    CURRENT_TIMESTAMP() AS _transformed_at
FROM source_data
