# Plataforma Analytics Engineering: Declarative Automation Bundles (DAB) + dbt + Unity Catalog

Plataforma de Analytics Engineering com arquitetura Medalhão (bronze/silver/gold) em dbt, orquestrada por DAB e CI/CD no GitHub Actions.

## Ambientes
Três ambientes no mesmo workspace: `dev` (desenvolvimento individual), `hml` e `prod` (gerenciados exclusivamente por CI/CD via Service Principals e aprovação manual).

## Estrutura do Repositório
```
bundles/
  domain_analytics/     Bundle do domínio analítico
    databricks.yml      Configuração de targets e recursos DAB
    resources/          Definição declarativa do Workflow e Schemas UC
    dbt_project/        Modelos dbt (bronze, silver, gold) e testes
.github/workflows/      Pipeline de CI/CD (pr-check, deploy-hml, deploy-prod)
scripts/dev.ps1         Utilitários para desenvolvimento local
```

## Arquitetura de Dados
- **Bronze (`analytics_bronze`):** Views de staging com padronização e tipagem dos dados brutos de `prod.default`.
- **Silver (`analytics_silver`):** Modelos incrementais com Delta Merge, desduplicação e Liquid Clustering.
- **Gold (`analytics_gold`):** Modelos dimensionais (dimensões e fatos) e detecção analítica de anomalias/fraude.
