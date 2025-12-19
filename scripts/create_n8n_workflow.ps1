param(
  [string]$Name = "Evolution Webhook",
  [string]$Path = "evolution-havoc",
  [string]$N8NUrl = "http://192.168.29.71:5678",
  [string]$N8NUser = "admin",
  [string]$N8NPassword = "password"
)

$headers = @{ "Content-Type" = "application/json" }
$basicAuth = ("{0}:{1}" -f $N8NUser, $N8NPassword)
$encodedAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($basicAuth))
$headers["Authorization"] = "Basic $encodedAuth"

$functionCode = @"
const data = $input.first().json;
if (data.data && data.data.message && data.data.message.buttonsResponseMessage) {
  const buttonData = data.data.message.buttonsResponseMessage;
  return {
    phone: data.data.key.remoteJid.replace(/@s\.whatsapp\.net/, ''),
    buttonId: buttonData.selectedButtonId,
    buttonText: buttonData.selectedDisplayText,
    timestamp: data.data.messageTimestamp,
    instance: data.instance,
    fullData: data
  };
}
return null;
"@

$sendButtonsBody = @{
  number = "={{$json.data.key.remoteJid.split('@')[0]}}"
  options = @{
    delay = 1200
    presence = "composing"
    mentions = @{ everyOne = $false }
    useNumber = $true
  }
  buttons = @{
    body = @{ text = "Escolha uma opção abaixo:" }
    buttons = @(
      @{ buttonId = "opt1"; buttonText = @{ displayText = "Sim, quero" } },
      @{ buttonId = "opt2"; buttonText = @{ displayText = "Nao, obrigado" } },
      @{ buttonId = "opt3"; buttonText = @{ displayText = "Mais informacoes" } }
    )
  }
} | ConvertTo-Json -Depth 10

$sendTextBodyOpt1 = @{
  number = "={{$json.phone}}"
  textMessage = @{
    text = "Otima escolha! Voce selecionou SIM.\n\nEm que posso te ajudar?\n\n1) Agendar servico\n2) Consultar precos\n3) Falar com atendente"
  }
} | ConvertTo-Json -Depth 10

$sendTextBodyOpt2 = @{
  number = "={{$json.phone}}"
  textMessage = @{
    text = "Tudo bem! Se mudar de ideia, estarei aqui.\n\nTenha um otimo dia!"
  }
} | ConvertTo-Json -Depth 10

$sendTextBodyOpt3 = @{
  number = "={{$json.phone}}"
  textMessage = @{
    text = "Claro! Aqui estao mais informacoes:\n\n- Servico X: R$ 100\n- Servico Y: R$ 200\n- Servico Z: R$ 300\n\nDeseja mais detalhes de algum?"
  }
} | ConvertTo-Json -Depth 10

$workflowObj = [ordered]@{
  name = $Name
  active = $true
  nodes = @(
    [ordered]@{
      parameters = [ordered]@{
        path = $Path
        methods = @("POST")
        responseMode = "onReceived"
        options = @{}
      }
      id = "Webhook_" + ($Path -replace '[^a-zA-Z0-9]', '')
      name = "Webhook Evolution Havoc"
      type = "n8n-nodes-base.webhook"
      typeVersion = 1
      position = @(200,300)
    },
    [ordered]@{
      parameters = [ordered]@{
        functionCode = $functionCode
      }
      id = "ProcessButtons"
      name = "Processar Respostas de Botões"
      type = "n8n-nodes-base.function"
      typeVersion = 1
      position = @(500,300)
    },
    [ordered]@{
      parameters = [ordered]@{
        value1 = "={{$json.buttonId}}"
        conditions = [ordered]@{
          string = [ordered]@{
            equal = @("opt1","opt2","opt3")
          }
        }
      }
      id = "SwitchButton"
      name = "Switch Botão"
      type = "n8n-nodes-base.switch"
      typeVersion = 1
      position = @(800,300)
    },
    [ordered]@{
      parameters = [ordered]@{
        requestMethod = "POST"
        url = "={{$vars.EVOLUTION_URL}}/message/sendButtons/{{$vars.EVOLUTION_INSTANCE}}"
        jsonParameters = $true
        options = [ordered]@{ timeout = 30000 }
        headerParametersUi = [ordered]@{
          parameter = @(
            [ordered]@{ name = "Content-Type"; value = "application/json" },
            [ordered]@{ name = "apikey"; value = "={{$vars.EVOLUTION_API_KEY}}" }
          )
        }
        bodyParametersJson = $sendButtonsBody
      }
      id = "SendButtons"
      name = "Enviar Botões"
      type = "n8n-nodes-base.httpRequest"
      typeVersion = 3
      position = @(500,550)
    },
    [ordered]@{
      parameters = [ordered]@{
        requestMethod = "POST"
        url = "={{$vars.EVOLUTION_URL}}/message/sendText/{{$vars.EVOLUTION_INSTANCE}}"
        jsonParameters = $true
        headerParametersUi = [ordered]@{
          parameter = @(
            [ordered]@{ name = "Content-Type"; value = "application/json" },
            [ordered]@{ name = "apikey"; value = "={{$vars.EVOLUTION_API_KEY}}" }
          )
        }
        bodyParametersJson = $sendTextBodyOpt1
      }
      id = "SendTextOpt1"
      name = "Resposta opt1"
      type = "n8n-nodes-base.httpRequest"
      typeVersion = 3
      position = @(1100,220)
    },
    [ordered]@{
      parameters = [ordered]@{
        requestMethod = "POST"
        url = "={{$vars.EVOLUTION_URL}}/message/sendText/{{$vars.EVOLUTION_INSTANCE}}"
        jsonParameters = $true
        headerParametersUi = [ordered]@{
          parameter = @(
            [ordered]@{ name = "Content-Type"; value = "application/json" },
            [ordered]@{ name = "apikey"; value = "={{$vars.EVOLUTION_API_KEY}}" }
          )
        }
        bodyParametersJson = $sendTextBodyOpt2
      }
      id = "SendTextOpt2"
      name = "Resposta opt2"
      type = "n8n-nodes-base.httpRequest"
      typeVersion = 3
      position = @(1100,300)
    },
    [ordered]@{
      parameters = [ordered]@{
        requestMethod = "POST"
        url = "={{$vars.EVOLUTION_URL}}/message/sendText/{{$vars.EVOLUTION_INSTANCE}}"
        jsonParameters = $true
        headerParametersUi = [ordered]@{
          parameter = @(
            [ordered]@{ name = "Content-Type"; value = "application/json" },
            [ordered]@{ name = "apikey"; value = "={{$vars.EVOLUTION_API_KEY}}" }
          )
        }
        bodyParametersJson = $sendTextBodyOpt3
      }
      id = "SendTextOpt3"
      name = "Resposta opt3"
      type = "n8n-nodes-base.httpRequest"
      typeVersion = 3
      position = @(1100,380)
    }
  )
  connections = [ordered]@{
    "Webhook Evolution Havoc" = [ordered]@{
      main = @(
        @(
          [ordered]@{ node = "Processar Respostas de Botões"; type = "main"; index = 0 },
          [ordered]@{ node = "Enviar Botões"; type = "main"; index = 0 }
        )
      )
    }
    "Processar Respostas de Botões" = [ordered]@{
      main = @(
        @([ordered]@{ node = "Switch Botão"; type = "main"; index = 0 })
      )
    }
    "Switch Botão" = [ordered]@{
      main = @(
        @([ordered]@{ node = "Resposta opt1"; type = "main"; index = 0 }),
        @([ordered]@{ node = "Resposta opt2"; type = "main"; index = 0 }),
        @([ordered]@{ node = "Resposta opt3"; type = "main"; index = 0 })
      )
    }
  }
}

$workflowBody = ($workflowObj | ConvertTo-Json -Depth 6)

try {
  Write-Host "Criando workflow no n8n (Nome: $Name, Path: $Path)..."
  $resp = Invoke-RestMethod -Uri "$N8NUrl/rest/workflows" -Method Post -Headers $headers -Body $workflowBody
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
