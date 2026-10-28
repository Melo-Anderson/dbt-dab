{{ config(
    materialized='table',
    liquid_clustered_by=['affiliate_id', 'country']
) }}

WITH affiliate_cpa AS (
    SELECT * FROM {{ ref('slv_affiliate_cpa_ftd') }}
)

SELECT
    {{ surrogate_key(['affiliate_id', 'country']) }} AS performance_sk,
    affiliate_id,
    country,
    COUNT(DISTINCT player_id) AS total_referred_players,
    COUNT(DISTINCT CASE WHEN cpa_qualified THEN player_id END) AS total_cpa_qualified_players,
    SUM(clicks) AS total_clicks,
    SUM(registrations) AS total_registrations,
    SUM(ftd) AS total_ftds,
    SUM(cpa_value) AS total_cpa_value,
    CASE 
        WHEN COUNT(DISTINCT player_id) = 0 THEN 0.0
        ELSE COUNT(DISTINCT CASE WHEN cpa_qualified THEN player_id END) / COUNT(DISTINCT player_id)
    END AS cpa_conversion_rate,
    CURRENT_TIMESTAMP() AS _calculated_at
FROM affiliate_cpa
GROUP BY affiliate_id, country
