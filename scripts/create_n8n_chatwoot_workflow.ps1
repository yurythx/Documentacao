# Cria Workflow no n8n escutando em /webhook/n8n

$basicAuth = "admin:password"
$apiKey = "n8n-api-key-here" # Se usar API Key
# Tentativa com X-N8N-API-KEY se Auth basica falhar, mas aqui vamos garantir a senha correta
$encodedAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($basicAuth))
$headers = @{ "Authorization" = "Basic $encodedAuth"; "Content-Type" = "application/json" }

$workflowBody = '{
  "name": "Chatwoot Events Listener",
  "active": true,
  "nodes": [
    {
      "parameters": {
        "path": "n8n",
        "methods": ["POST"],
        "responseMode": "onReceived",
        "options": {}
      },
      "id": "WebhookChatwoot",
      "name": "Webhook Chatwoot",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [300, 300]
    }
  ],
  "connections": {}
}'

try {
  Write-Host "Criando workflow no n8n (Path: /webhook/n8n)..."
  $resp = Invoke-RestMethod -Uri "http://192.168.29.71:5678/rest/workflows" -Method Post -Headers $headers -Body $workflowBody
  Write-Host "Workflow criado e ativado com sucesso!"
  $resp | ConvertTo-Json -Depth 2 | Write-Output
} catch {
  Write-Host "Erro ao criar workflow: $($_.Exception.Message)"
  if ($_.Exception.Response) {
    $stream = $_.Exception.Response.GetResponseStream()
    if ($stream) {
      $reader = New-Object System.IO.StreamReader($stream)
      $responseBody = $reader.ReadToEnd()
      Write-Host "Detalhes do erro (Body): $responseBody"
    }
  }
}
