# Configura webhook do Chatwoot apontando para o n8n (Interno)
# URL: http://n8n:5678/webhook/n8n

$headers = @{
    "api_access_token" = "CDuFU9XcuoXTF7uHarDFWCw3"
    "Content-Type" = "application/json"
}

$jsonBody = '{
    "webhook": {
        "url": "http://n8n:5678/webhook/n8n?api_key=valid_token",
        "subscriptions": [
            "conversation_created",
            "conversation_status_changed", 
            "conversation_updated", 
            "message_created", 
            "message_updated",
            "webwidget_triggered"
        ]
    }
}'

try {
    Write-Host "Criando webhook no Chatwoot (Target: n8n)..."
    $response = Invoke-RestMethod -Uri "http://192.168.29.71:3000/api/v1/accounts/1/webhooks" -Method Post -Headers $headers -Body $jsonBody
    Write-Host "Webhook criado com sucesso!"
    Write-Output $response
} catch {
    Write-Host "Erro ao criar webhook: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        if ($stream) {
            $reader = New-Object System.IO.StreamReader($stream)
            $responseBody = $reader.ReadToEnd()
            Write-Host "Detalhes do erro: $responseBody"
        }
    }
}
