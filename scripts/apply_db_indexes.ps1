param(
  [string]$Container = "postgres_n8n",
  [string]$Database = "n8n_fila",
  [string]$User = "postgres",
  [string]$SqlPath = "scripts/db_indexes.sql"
)

if (!(Test-Path $SqlPath)) {
  Write-Error "Arquivo SQL não encontrado: $SqlPath"
  exit 1
}

docker exec $Container sh -lc "psql -U $User -d $Database -f /tmp/db_indexes.sql" | Write-Output
