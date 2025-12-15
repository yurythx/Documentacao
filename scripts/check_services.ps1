# Check Services Status
# Agrega verificações de Chatwoot, n8n e Evolution API em um único relatório.

$ErrorActionPreference = 'SilentlyContinue'

# Configurações
$ip = "192.168.29.71"
$chatwootUrl = "http://${ip}:3000"
$n8nUrl = "http://${ip}:5678"
$evolutionUrl = "http://${ip}:8081"

$chatwootToken = "CDuFU9XcuoXTF7uHarDFWCw3"
$evolutionKey = "B8963286-1598-4542-8952-223366998855"

function Print-Header ($title) {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host " $title" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
}

function Print-Result ($service, $status, $details) {
    if ($status -eq "OK") {
        Write-Host "[$service] STATUS: ONLINE" -ForegroundColor Green
    } else {
        Write-Host "[$service] STATUS: ERROR" -ForegroundColor Red
        Write-Host "Erro: $details" -ForegroundColor Yellow
    }
}

# 1. Verificar n8n
Print-Header "Verificando n8n"
try {
    $resp = Invoke-RestMethod -Uri "$n8nUrl/healthz" -Method Get -TimeoutSec 5
    Print-Result "n8n" "OK" "Healthz check passed"
} catch {
    Print-Result "n8n" "ERROR" $_.Exception.Message
}

# 2. Verificar Chatwoot
Print-Header "Verificando Chatwoot"
try {
    $headers = @{ "api_access_token" = $chatwootToken }
    $resp = Invoke-RestMethod -Uri "$chatwootUrl/api/v1/accounts/1" -Method Get -Headers $headers -TimeoutSec 5
    Print-Result "Chatwoot API" "OK" "Account ID 1 accessed"
    
    # Verificar Webhooks
    Write-Host "`nVerificando Webhooks configurados..."
    $hooks = Invoke-RestMethod -Uri "$chatwootUrl/api/v1/accounts/1/webhooks" -Method Get -Headers $headers
    
    # Payload returns { "webhooks": [ ... ] }
    if ($hooks.payload.webhooks) {
        $hookList = @($hooks.payload.webhooks)
        foreach ($h in $hookList) {
            Write-Host " - Webhook (ID: $($h.id)): $($h.url)" -ForegroundColor Gray
        }
    } else {
        Write-Host " - Nenhum webhook encontrado." -ForegroundColor Yellow
    }

} catch {
    Print-Result "Chatwoot API" "ERROR" $_.Exception.Message
}

# 3. Verificar Evolution API
Print-Header "Verificando Evolution API"
try {
    $headers = @{ "apikey" = $evolutionKey }
    $resp = Invoke-RestMethod -Uri "$evolutionUrl/instance/fetchInstances" -Method Get -Headers $headers -TimeoutSec 5
    Print-Result "Evolution API" "OK" "Instances fetched"
    
    if ($resp.Count -gt 0) {
        foreach ($inst in $resp) {
            Write-Host " - Instância: $($inst.name) | Status: $($inst.connectionStatus)" -ForegroundColor Gray
        }
    } else {
        Write-Host " - Nenhuma instância encontrada." -ForegroundColor Yellow
    }
} catch {
    Print-Result "Evolution API" "ERROR" $_.Exception.Message
}

Write-Host "`nDiagnóstico concluído." -ForegroundColor Cyan
