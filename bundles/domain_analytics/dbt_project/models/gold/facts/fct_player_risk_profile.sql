{{ config(
    materialized='table',
    liquid_clustered_by=['risk_tier']
) }}

WITH players AS (
    SELECT * FROM {{ ref('dim_players') }}
),

tx_summary AS (
    SELECT
        player_id,
        COALESCE(SUM(CASE WHEN transaction_type = 'DEPOSIT' THEN amount END), 0.0) AS total_deposited,
        COALESCE(SUM(CASE WHEN transaction_type IN ('WITHDRAW', 'WITHDRAWAL') THEN amount END), 0.0) AS total_withdrawn,
        COALESCE(SUM(CASE WHEN transaction_type = 'BET' THEN amount END), 0.0) AS total_wagered,
        COUNT(CASE WHEN transaction_type = 'DEPOSIT' THEN 1 END) AS deposit_count,
        COUNT(CASE WHEN transaction_type IN ('WITHDRAW', 'WITHDRAWAL') THEN 1 END) AS withdrawal_count,
        COUNT(CASE WHEN transaction_type = 'BET' THEN 1 END) AS bet_count
    FROM {{ ref('slv_transactions') }}
    GROUP BY player_id
)

SELECT
    p.player_sk,
    p.player_id,
    p.email,
    p.city,
    p.affiliate_id,
    COALESCE(t.total_deposited, 0.0) AS total_deposited,
    COALESCE(t.total_withdrawn, 0.0) AS total_withdrawn,
    COALESCE(t.total_wagered, 0.0) AS total_wagered,
    0.0 AS total_won,
    COALESCE(t.total_wagered, 0.0) AS net_ggr,
    CASE 
        WHEN COALESCE(t.total_deposited, 0.0) = 0 THEN 0.0 
        ELSE COALESCE(t.total_withdrawn, 0.0) / t.total_deposited 
    END AS withdrawal_to_deposit_ratio,
    CASE 
        WHEN COALESCE(t.total_deposited, 0.0) = 0 THEN 0.0 
        ELSE COALESCE(t.total_wagered, 0.0) / t.total_deposited 
    END AS rollover_multiplier,
    CASE
        WHEN COALESCE(t.total_withdrawn, 0.0) > 1000.0 AND (COALESCE(t.total_deposited, 0.0) > 0 AND (COALESCE(t.total_wagered, 0.0) / t.total_deposited) < 0.5) THEN 'HIGH_RISK_ROLLOVER_ABUSE'
        WHEN COALESCE(t.total_deposited, 0.0) > 5000.0 THEN 'VIP_LOW_RISK'
        ELSE 'STANDARD'
    END AS risk_tier,
    CURRENT_TIMESTAMP() AS _calculated_at
FROM players p
LEFT JOIN tx_summary t ON p.player_id = t.player_id
