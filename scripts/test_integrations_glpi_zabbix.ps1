param(
  [string]$N8NBase = "http://192.168.29.71:5678"
)

function Test-Endpoint {
  param([string]$Url, [string]$Method = "POST", [string]$Body = "{}")
  try {
    $resp = Invoke-WebRequest -UseBasicParsing -Method $Method -ContentType "application/json" -Uri $Url -Body $Body
    Write-Host ("[OK] {0} {1} => {2}" -f $Method, $Url, $resp.StatusCode) -ForegroundColor Green
    if ($resp.Content) { Write-Output $resp.Content }
  } catch {
    Write-Host ("[FAIL] {0} {1} => {2}" -f $Method, $Url, $_.Exception.Message) -ForegroundColor Red
    if ($_.Exception.Response) {
      $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
      $details = $reader.ReadToEnd()
      Write-Host $details -ForegroundColor Yellow
    }
  }
}

Write-Host "Verificando n8n..." -ForegroundColor Cyan
try {
  $health = Invoke-WebRequest -UseBasicParsing -Method GET -Uri "$N8NBase/healthz"
  Write-Host "[OK] n8n healthz" -ForegroundColor Green
} catch {
  Write-Host "[FAIL] n8n healthz: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Testando webhook GLPI..." -ForegroundColor Cyan
Test-Endpoint "$N8NBase/webhook/glpi_ticket" "POST" '{"name":"Teste","content":"Criado via n8n"}'

Write-Host "Testando webhook Zabbix..." -ForegroundColor Cyan
Test-Endpoint "$N8NBase/webhook/zabbix_problems" "POST" "{}"

Write-Host "Concluído." -ForegroundColor Cyan
