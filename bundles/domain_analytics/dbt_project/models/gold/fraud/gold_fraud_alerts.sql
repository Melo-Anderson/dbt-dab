{{ config(
    materialized='table',
    liquid_clustered_by=['severity']
) }}

WITH multi_accounting AS (
    SELECT
        ip_address,
        COUNT(DISTINCT player_id) AS shared_player_count,
        SLICE(COLLECT_SET(player_id), 1, 10) AS related_player_ids
    FROM {{ ref('slv_sessions') }}
    WHERE ip_address IS NOT NULL AND ip_address != ''
    GROUP BY ip_address
    HAVING COUNT(DISTINCT player_id) >= {{ var('min_shared_accounts', 2) }}
),

cpa_farming_alerts AS (
    SELECT
        {{ surrogate_key(["'CPA_FARMING_IP'", "m.ip_address"]) }} AS alert_id,
        'CPA_FARMING_SHARED_IP' AS alert_type,
        'CRITICAL' AS severity,
        TO_JSON(NAMED_STRUCT(
            'ip_address', m.ip_address,
            'shared_player_count', m.shared_player_count,
            'related_player_ids', m.related_player_ids
        )) AS alert_details,
        CURRENT_TIMESTAMP() AS detected_at
    FROM multi_accounting m
),

rollover_abuse_alerts AS (
    SELECT
        {{ surrogate_key(["'ROLLOVER_ABUSE'", "r.player_id"]) }} AS alert_id,
        'ROLLOVER_BONUS_ABUSE' AS alert_type,
        'HIGH' AS severity,
        TO_JSON(NAMED_STRUCT(
            'player_id', r.player_id,
            'email', r.email,
            'total_deposited', r.total_deposited,
            'total_withdrawn', r.total_withdrawn,
            'total_wagered', r.total_wagered,
            'rollover_multiplier', r.rollover_multiplier
        )) AS alert_details,
        CURRENT_TIMESTAMP() AS detected_at
    FROM {{ ref('fct_player_risk_profile') }} r
    WHERE r.total_withdrawn > 500.0
      AND r.rollover_multiplier < {{ var('min_rollover_ratio', 0.5) }}
)

SELECT
    alert_id,
    alert_type,
    severity,
    alert_details,
    detected_at,
    CURRENT_TIMESTAMP() AS _calculated_at
FROM cpa_farming_alerts
UNION ALL
SELECT
    alert_id,
    alert_type,
    severity,
    alert_details,
    detected_at,
    CURRENT_TIMESTAMP() AS _calculated_at
FROM rollover_abuse_alerts
