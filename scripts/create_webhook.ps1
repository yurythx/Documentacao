$headers = @{
    "api_access_token" = "CDuFU9XcuoXTF7uHarDFWCw3"
    "Content-Type" = "application/json"
}

$jsonBody = '{
    "webhook": {
        "url": "http://192.168.29.71:8081/chatwoot/webhook/Havoc",
        "subscriptions": [
            "conversation_status_changed", 
            "conversation_updated", 
            "message_created", 
            "message_updated"
        ]
    }
}'

try {
    Write-Host "Criando webhook no Chatwoot..."
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
