param(
  [string]$WebhookUrl = "http://localhost:5678/webhook/evolution-havoc",
  [string]$Phone = "5511999999999",
  [string]$Name = "Cliente Teste"
)

$headers = @{ "Content-Type" = "application/json" }
$payload = @{
  contact = @{
    identifier = "$Phone@whatsapp.net"
    name = $Name
    id = 123
  }
  content = "oi"
  event = "message"
} | ConvertTo-Json -Depth 6

try {
  Invoke-RestMethod -Uri $WebhookUrl -Method Post -Headers $headers -Body $payload | ConvertTo-Json -Depth 6 | Write-Output
} catch {
  $_.ErrorDetails.Message | Write-Output
}
