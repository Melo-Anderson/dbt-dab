{{ config(
    materialized='view'
) }}

WITH source_data AS (
    SELECT * FROM {{ source('raw', 'sessions') }}
)

SELECT
    TRY_CAST(session_id AS STRING) AS session_id,
    TRY_CAST(player_id AS STRING) AS player_id,
    LOWER(TRIM(TRY_CAST(device AS STRING))) AS device_type,
    TRY_CAST(ip AS STRING) AS ip_address,
    COALESCE(
        TRY_TO_TIMESTAMP(TRY_CAST(timestamp AS STRING), "yyyy-MM-dd'T'HH:mm:ss[.SSS]'Z'"),
        TRY_TO_TIMESTAMP(TRY_CAST(timestamp AS STRING), "yyyy-MM-dd'T'HH:mm:ss"),
        TRY_TO_TIMESTAMP(TRY_CAST(timestamp AS STRING), "yyyy-MM-dd HH:mm:ss"),
        TRY_TO_TIMESTAMP(TRY_CAST(timestamp AS STRING))
    ) AS session_start,
    CURRENT_TIMESTAMP() AS _ingested_at,
    CURRENT_TIMESTAMP() AS _transformed_at
FROM source_data
