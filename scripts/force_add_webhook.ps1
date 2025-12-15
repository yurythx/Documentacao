# Script para adicionar Webhook interno no Chatwoot (Bypassing UI Validation)
$chatwootUrl = "http://192.168.29.71:3000"
$token = "CDuFU9XcuoXTF7uHarDFWCw3" # Token do admin (ID 1)
$accountId = "1"
$internalWebhookUrl = "http://n8n:5678/webhook/n8n"

$headers = @{
    "api_access_token" = $token
    "Content-Type" = "application/json"
}

$body = @{
    webhook = @{
        url = $internalWebhookUrl
        subscriptions = @(
            "conversation_created",
            "conversation_status_changed",
            "conversation_updated",
            "message_created",
            "message_updated",
            "webwidget_triggered"
        )
    }
} | ConvertTo-Json -Depth 5

Write-Host "Tentando adicionar Webhook: $internalWebhookUrl via API..."

try {
    $response = Invoke-RestMethod -Uri "$chatwootUrl/api/v1/accounts/$accountId/webhooks" -Method Post -Headers $headers -Body $body
    Write-Host "✅ SUCESSO! Webhook adicionado." -ForegroundColor Green
    Write-Host "ID: $($response.payload.webhook.id)"
    Write-Host "URL: $($response.payload.webhook.url)"
} catch {
    Write-Host "❌ ERRO: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        Write-Host "Detalhes: $($reader.ReadToEnd())" -ForegroundColor Yellow
    }
}
