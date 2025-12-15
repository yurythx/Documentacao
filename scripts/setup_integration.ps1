$headers = @{
    "apikey" = "B8963286-1598-4542-8952-223366998855"
    "Content-Type" = "application/json"
}

$jsonBody = '{
    "enabled": true,
    "accountId": "1",
    "token": "CDuFU9XcuoXTF7uHarDFWCw3",
    "url": "http://192.168.29.71:3000",
    "signMsg": true,
    "reopenConversation": true,
    "conversationPending": false,
    "nameInbox": "Havoc",
    "mergeBrazilContacts": true,
    "importContacts": true,
    "importMessages": true,
    "daysLimitImportMessages": 3,
    "signDelimiter": "\\n",
    "autoCreate": false,
    "organization": "Havoc",
    "logo": "https://evolution-api.com/files/evolution-api-favicon.png"
}'

Write-Host "Payload being sent:"
Write-Host $jsonBody

try {
    Write-Host "Enviando requisicao para configurar integracao Chatwoot na instancia Havoc..."
    $response = Invoke-RestMethod -Uri "http://192.168.29.71:8081/chatwoot/set/Havoc" -Method Post -Headers $headers -Body $jsonBody
    Write-Host "Integracao configurada com sucesso!"
    Write-Output $response
} catch {
    Write-Host "Erro ao configurar integracao: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        if ($stream) {
            $reader = New-Object System.IO.StreamReader($stream)
            $responseBody = $reader.ReadToEnd()
            Write-Host "Detalhes do erro (Body): $responseBody"
        }
    } else {
        Write-Host "Sem detalhes adicionais na resposta."
    }
}
