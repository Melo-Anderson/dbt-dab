# Atalhos para Windows (substitui o Makefile). Uso: .\scripts\dev.ps1 <comando>
param([Parameter(Mandatory = $true)][ValidateSet("setup","load-env","dbt-compile","dbt-build","bundle-validate-dev","bundle-deploy-dev","bundle-run-dev")][string]$Cmd)

$Root = Split-Path $PSScriptRoot -Parent
$Bundle = Join-Path $Root "bundles\domain_analytics"
$Dbt = Join-Path $Bundle "dbt_project"

function Load-Env {
    $f = Join-Path $Root ".env"
    if (Test-Path $f) {
        Get-Content $f | Where-Object { $_ -match '^\s*[^#=\s]+=' } | ForEach-Object {
            $k, $v = $_ -split '=', 2
            Set-Item -Path "Env:$($k.Trim())" -Value $v.Trim()
        }
    }
}

switch ($Cmd) {
    "setup"               { python -m venv "$Root\.venv"; & "$Root\.venv\Scripts\pip" install -r "$Root\requirements.txt" }
    "load-env"            { Load-Env }
    "dbt-compile"         { Load-Env; Push-Location $Dbt; dbt deps; dbt compile --profiles-dir .; Pop-Location }
    "dbt-build"           { Load-Env; Push-Location $Dbt; dbt deps; dbt build --profiles-dir .; Pop-Location }
    "bundle-validate-dev" { Push-Location $Bundle; databricks bundle validate -t dev; Pop-Location }
    "bundle-deploy-dev"   { Push-Location $Bundle; databricks bundle deploy -t dev; Pop-Location }
    "bundle-run-dev"      { Push-Location $Bundle; databricks bundle run -t dev dbt_medallion_job; Pop-Location }
}
