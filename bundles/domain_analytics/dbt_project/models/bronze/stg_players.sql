{{ config(
    materialized='view'
) }}

WITH source_data AS (
    SELECT * FROM {{ source('raw', 'players') }}
)

SELECT
    TRY_CAST(player_id AS STRING) AS player_id,
    LOWER(TRIM(TRY_CAST(email AS STRING))) AS email,
    TRIM(TRY_CAST(city AS STRING)) AS city,
    COALESCE(
        TRY_TO_TIMESTAMP(TRY_CAST(created_at AS STRING), "yyyy-MM-dd'T'HH:mm:ss[.SSS]'Z'"),
        TRY_TO_TIMESTAMP(TRY_CAST(created_at AS STRING), "yyyy-MM-dd'T'HH:mm:ss"),
        TRY_TO_TIMESTAMP(TRY_CAST(created_at AS STRING), "yyyy-MM-dd"),
        TRY_TO_TIMESTAMP(TRY_CAST(created_at AS STRING))
    ) AS registration_timestamp,
    CURRENT_TIMESTAMP() AS _ingested_at,
    CURRENT_TIMESTAMP() AS _transformed_at
FROM source_data
