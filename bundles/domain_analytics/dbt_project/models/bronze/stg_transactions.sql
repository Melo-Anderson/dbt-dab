{{ config(
    materialized='view'
) }}

WITH source_data AS (
    SELECT * FROM {{ source('raw', 'transactions') }}
)

SELECT
    TRY_CAST(transaction_id AS STRING) AS transaction_id,
    TRY_CAST(player_id AS STRING) AS player_id,
    UPPER(TRIM(TRY_CAST(type AS STRING))) AS transaction_type,
    COALESCE(TRY_CAST(amount AS DECIMAL(18, 2)), 0.0) AS amount,
    COALESCE(
        CASE
            WHEN TRY_CAST(timestamp AS BIGINT) > 1000000000000000 THEN TIMESTAMP_MICROS(TRY_CAST(timestamp AS BIGINT))
            WHEN TRY_CAST(timestamp AS BIGINT) > 1000000000 THEN TIMESTAMP_SECONDS(TRY_CAST(timestamp AS BIGINT))
            ELSE NULL
        END,
        TRY_TO_TIMESTAMP(TRY_CAST(timestamp AS STRING), "yyyy-MM-dd'T'HH:mm:ss[.SSS]'Z'"),
        TRY_TO_TIMESTAMP(TRY_CAST(timestamp AS STRING), "yyyy-MM-dd'T'HH:mm:ss"),
        TRY_TO_TIMESTAMP(TRY_CAST(timestamp AS STRING), "yyyy-MM-dd HH:mm:ss"),
        TRY_TO_TIMESTAMP(TRY_CAST(timestamp AS STRING))
    ) AS transaction_timestamp,
    CURRENT_TIMESTAMP() AS _ingested_at,
    CURRENT_TIMESTAMP() AS _transformed_at
FROM source_data
