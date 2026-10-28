{{ config(
    materialized='table'
) }}

WITH affiliate_data AS (
    SELECT
        affiliate_id,
        country,
        player_id,
        clicks,
        registrations,
        ftd,
        cpa_value,
        cpa_qualified
    FROM {{ ref('slv_affiliate_cpa_ftd') }}
)

SELECT
    {{ surrogate_key(['affiliate_id']) }} AS affiliate_sk,
    affiliate_id,
    COUNT(DISTINCT country) AS total_operating_countries,
    COUNT(DISTINCT player_id) AS total_referred_players,
    COUNT(DISTINCT CASE WHEN cpa_qualified THEN player_id END) AS total_cpa_qualified_players,
    SUM(clicks) AS total_clicks,
    SUM(registrations) AS total_registrations,
    SUM(ftd) AS total_ftds,
    SUM(cpa_value) AS total_cpa_value,
    CASE 
        WHEN COUNT(DISTINCT player_id) = 0 THEN 0.0
        ELSE COUNT(DISTINCT CASE WHEN cpa_qualified THEN player_id END) / COUNT(DISTINCT player_id)
    END AS overall_conversion_rate,
    CURRENT_TIMESTAMP() AS _calculated_at
FROM affiliate_data
GROUP BY affiliate_id
