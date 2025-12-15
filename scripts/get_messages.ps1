$ErrorActionPreference = 'Stop'
$headers = @{ 'api_access_token' = 'CDuFU9XcuoXTF7uHarDFWCw3' }
$cid = 2
try {
  $resp = Invoke-RestMethod -Uri "http://192.168.29.71:3000/api/v1/accounts/1/conversations/$cid/messages" -Headers $headers -Method Get
  $resp | ConvertTo-Json -Depth 6 | Write-Output
} catch {
  Write-Host "Erro: $($_.Exception.Message)"
}
