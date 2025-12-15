# Integração n8n com GLPI e Zabbix

## Pré-requisitos
- n8n acessível em `http://192.168.29.71:5678/` com autenticação básica ativa.
- GLPI acessível em `http://192.168.29.71:18080/` e com API habilitada.
- Zabbix Web acessível em `http://192.168.29.71:18081/`.
- Variáveis definidas em `.env`:
  - `GLPI_APP_TOKEN`, `GLPI_USER_TOKEN`
  - `ZABBIX_API_URL`, `ZABBIX_USER`, `ZABBIX_PASSWORD`

## Workflow: GLPI - Create Ticket
- Nó Webhook
  - Method: `POST`
  - Path: `glpi_ticket`
- Nó HTTP Request (GLPI)
  - URL: `http://glpi/apirest.php/Ticket`
  - Method: `POST`
  - Headers:
    - `App-Token`: `={{$env.GLPI_APP_TOKEN}}`
    - `Authorization`: `={{$env.GLPI_USER_TOKEN}}`
    - `Content-Type`: `application/json`
  - Body (JSON):
    - `name`: `={{$json.name || 'Solicitação via WhatsApp'}}`
    - `content`: `={{$json.content || 'Sem descrição'}}`
    - `urgency`: `={{$json.urgency || 3}}`
    - `impact`: `={{$json.impact || 3}}`
    - `priority`: `={{$json.priority || 3}}`

### Teste
- `POST http://192.168.29.71:5678/webhook/glpi_ticket`
- Body exemplo:
```json
{ "name": "Teste", "content": "Criado via n8n" }
```

## Workflow: Zabbix - Problems
- Nó Webhook
  - Method: `POST`
  - Path: `zabbix_problems`
- Nó HTTP Request (Login)
  - URL: `={{$env.ZABBIX_API_URL}}`
  - Method: `POST`
  - Body:
```json
{ "jsonrpc":"2.0", "method":"user.login", "params":{"user":"{{$env.ZABBIX_USER}}","password":"{{$env.ZABBIX_PASSWORD}}"}, "id":1 }
```
- Nó HTTP Request (problem.get)
  - URL: `={{$env.ZABBIX_API_URL}}`
  - Method: `POST`
  - Body:
```json
{ "jsonrpc":"2.0", "method":"problem.get", "params":{"recent":true,"sortfield":"eventid","sortorder":"DESC"}, "auth":"={{$json.result}}", "id":2 }
```

### Teste
- `POST http://192.168.29.71:5678/webhook/zabbix_problems`
- Body: `{}`

## Observações
- Os endpoints de produção (`/webhook/*`) funcionam apenas com o workflow `active = true`.
- Dentro do Docker, use hostnames internos (`glpi`, `zabbix-web`) nos nós HTTP Request.
