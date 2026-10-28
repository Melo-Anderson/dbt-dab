{{ config(
    materialized='incremental',
    unique_key='transaction_id',
    liquid_clustered_by=['player_id', 'transaction_type']
) }}

WITH staged AS (
    SELECT *
    FROM {{ ref('stg_transactions') }}
    {% if is_incremental() %}
    WHERE _ingested_at > (SELECT COALESCE(MAX(_ingested_at), '1900-01-01') FROM {{ this }})
    {% endif %}
)

SELECT
    transaction_id,
    player_id,
    transaction_type,
    amount,
    transaction_timestamp,
    _ingested_at,
    CURRENT_TIMESTAMP() AS _processed_at
FROM staged
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY transaction_id
    ORDER BY transaction_timestamp DESC, _ingested_at DESC
) = 1
