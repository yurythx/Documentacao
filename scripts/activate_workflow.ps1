param(
  [string]$N8nUrl = "http://localhost:5678",
  [string]$User = "admin",
  [string]$Password = "password",
  [string]$WorkflowName = "Evolution Havoc"
)

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$loginBody = @{ email = $User; password = $Password } | ConvertTo-Json
$headers = @{ "Content-Type" = "application/json" }

try {
  $loginResp = Invoke-WebRequest -Uri "$N8nUrl/rest/login" -Method Post -Body $loginBody -Headers $headers -WebSession $session
} catch {
  Write-Error "Falha ao autenticar no n8n: $($_.Exception.Message)"
  exit 1
}

try {
  $workflows = Invoke-RestMethod -Uri "$N8nUrl/rest/workflows" -Method Get -WebSession $session
} catch {
  Write-Error "Falha ao listar workflows: $($_.Exception.Message)"
  exit 1
}

if (-not $workflows) {
  Write-Error "Nenhum workflow encontrado."
  exit 1
}

$target = $workflows | Where-Object { $_.name -eq $WorkflowName } | Select-Object -First 1
if (-not $target) {
  Write-Error "Workflow não encontrado: $WorkflowName"
  exit 1
}

$workflowId = $target.id
$patchBody = @{ active = $true } | ConvertTo-Json

try {
  $patchResp = Invoke-WebRequest -Uri "$N8nUrl/rest/workflows/$workflowId" -Method Patch -Body $patchBody -Headers $headers -WebSession $session
  Write-Output "Workflow ativado: $WorkflowName ($workflowId)"
} catch {
  Write-Error "Falha ao ativar workflow: $($_.Exception.Message)"
  exit 1
}
