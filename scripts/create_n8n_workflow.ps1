$basicAuth = "admin:password"
$encodedAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($basicAuth))
$headers = @{ "Authorization" = "Basic $encodedAuth"; "Content-Type" = "application/json" }

$workflowBody = '{
  "name": "Evolution Webhook",
  "active": true,
  "nodes": [
    {
      "parameters": {
        "path": "evolution",
        "methods": ["POST"],
        "responseMode": "onReceived",
        "options": {}
      },
      "id": "Webhook1",
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [300, 300]
    }
  ],
  "connections": {}
}'

try {
  Write-Host "Criando workflow no n8n..."
  $resp = Invoke-RestMethod -Uri "http://192.168.29.71:5678/rest/workflows" -Method Post -Headers $headers -Body $workflowBody
  Write-Host "Workflow criado com sucesso!"
  $resp | ConvertTo-Json -Depth 6 | Write-Output
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

