{{ config(
    materialized='table'
) }}

WITH players AS (
    SELECT * FROM {{ ref('slv_players') }}
),

affiliate_attr AS (
    SELECT
        player_id,
        affiliate_id,
        country,
        clicks,
        registrations,
        ftd,
        cpa_value,
        cpa_qualified
    FROM {{ ref('slv_affiliate_cpa_ftd') }}
),

latest_sessions AS (
    SELECT
        player_id,
        device_type AS latest_device_type,
        ip_address AS latest_ip_address,
        session_start AS latest_session_start
    FROM {{ ref('slv_sessions') }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY player_id
        ORDER BY session_start DESC
    ) = 1
)

SELECT
    {{ surrogate_key(['p.player_id']) }} AS player_sk,
    p.player_id,
    p.email,
    p.city,
    p.registration_timestamp,
    DATE(p.registration_timestamp) AS registration_date,
    COALESCE(a.affiliate_id, 'ORGANIC') AS affiliate_id,
    COALESCE(a.country, 'UNKNOWN') AS country,
    COALESCE(a.cpa_qualified, FALSE) AS has_cpa_qualified,
    COALESCE(a.ftd, 0) AS ftd_count,
    COALESCE(a.cpa_value, 0.0) AS cpa_value,
    s.latest_device_type,
    s.latest_ip_address,
    s.latest_session_start,
    CURRENT_TIMESTAMP() AS _calculated_at
FROM players p
LEFT JOIN affiliate_attr a ON p.player_id = a.player_id
LEFT JOIN latest_sessions s ON p.player_id = s.player_id
