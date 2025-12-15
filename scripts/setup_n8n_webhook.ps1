$headers = @{
    "apikey" = "B8963286-1598-4542-8952-223366998855"
    "Content-Type" = "application/json"
}

$jsonBody = '{
    "webhook": {
        "enabled": true,
        "url": "http://n8n:5678/webhook/evolution",
        "byEvents": false,
        "base64": false,
        "events": [
            "MESSAGES_UPSERT",
            "MESSAGES_UPDATE",
            "MESSAGES_DELETE",
            "SEND_MESSAGE",
            "CONTACTS_SET",
            "CONTACTS_UPSERT",
            "CONTACTS_UPDATE",
            "PRESENCE_UPDATE",
            "CHATS_SET",
            "CHATS_UPSERT",
            "CHATS_UPDATE",
            "CHATS_DELETE",
            "GROUPS_UPSERT",
            "GROUP_UPDATE",
            "GROUP_PARTICIPANTS_UPDATE",
            "CONNECTION_UPDATE",
            "CALL"
        ]
    }
}'

try {
    Write-Host "Configurando Webhook da Evolution para o n8n (Instancia: Havoc)..."
    # Nota: Endpoint pode variar conforme versao da Evolution. Tentando /webhook/set/Havoc
    $response = Invoke-RestMethod -Uri "http://192.168.29.71:8081/webhook/set/Havoc" -Method Post -Headers $headers -Body $jsonBody
    Write-Host "Webhook configurado com sucesso!"
    Write-Output $response
} catch {
    Write-Host "Erro ao configurar webhook: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        if ($stream) {
            $reader = New-Object System.IO.StreamReader($stream)
            $responseBody = $reader.ReadToEnd()
            Write-Host "Detalhes do erro (Body): $responseBody"
        }
    }
}
