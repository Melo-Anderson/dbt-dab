{% docs player_risk_tier %}
Categorization of player fraud risk based on withdrawal velocity, KYC compliance, and rollover multipliers:
- `HIGH_RISK_ROLLOVER_ABUSE`: Significant withdrawals with insufficient gameplay wagering (rollover multiplier < 0.5).
- `HIGH_RISK_KYC_REJECTED`: Player profile failed verification checks.
- `VIP_LOW_RISK`: High cumulative deposits (> $5,000) with compliant turnover.
- `STANDARD`: Normal operational player behavior.
{% enddocs %}

{% docs cpa_commission %}
Monetary commission earned by an affiliate partner upon a player achieving the minimum first-time deposit (FTD) qualification requirements.
{% enddocs %}

{% docs fraud_alert_type %}
Specific fraud security typology identified by automated rule engines:
- `CPA_FARMING_SHARED_DEVICE`: Multiple player identities registered on the same physical hardware fingerprint.
- `ROLLOVER_BONUS_ABUSE`: Exploitation of deposit bonuses by withdrawing without fulfilling minimum game wagering.
- `GEO_VELOCITY_MISMATCH`: Rapid consecutive logins across conflicting geographic countries.
{% enddocs %}
