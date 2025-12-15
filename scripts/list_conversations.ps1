$headers = @{ 'api_access_token' = 'CDuFU9XcuoXTF7uHarDFWCw3' }
try {
  $resp = Invoke-RestMethod -Uri 'http://192.168.29.71:3000/api/v1/accounts/1/conversations' -Headers $headers -Method Get
  $resp | ConvertTo-Json -Depth 6 | Write-Output
} catch {
  Write-Host "Erro: $($_.Exception.Message)"
  if ($_.Exception.Response) { $r = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); Write-Host ($r.ReadToEnd()) }
}

