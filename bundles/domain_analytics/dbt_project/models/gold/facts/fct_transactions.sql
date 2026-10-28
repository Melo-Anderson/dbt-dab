{{ config(
    materialized='table',
    liquid_clustered_by=['player_id', 'transaction_type']
) }}

WITH tx AS (
    SELECT * FROM {{ ref('slv_transactions') }}
),

players AS (
    SELECT
        player_sk,
        player_id,
        affiliate_id
    FROM {{ ref('dim_players') }}
)

SELECT
    {{ surrogate_key(['t.transaction_id']) }} AS transaction_sk,
    t.transaction_id,
    p.player_sk,
    t.player_id,
    p.affiliate_id,
    t.transaction_type,
    t.amount,
    t.transaction_timestamp,
    DATE(t.transaction_timestamp) AS transaction_date,
    CURRENT_TIMESTAMP() AS _calculated_at
FROM tx t
LEFT JOIN players p ON t.player_id = p.player_id
