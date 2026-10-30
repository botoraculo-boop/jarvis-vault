---
tipo: runbook
atualizado: 2026-10-30
---

# Integrações

Regra: integração só entra com um fluxo que a usa toda semana. Ao ativar uma, mude o **Status** aqui — o Jarvis só usa o que está ativo.

| # | Integração | Para quê | Como | Fase | Status | Proteção |
|---|---|---|---|---|---|---|
| 1 | Vault | memória | nativo | 1 | ativa | git; `raw/` negado |
| 2 | kepano/obsidian-skills | Markdown, Bases e Canvas no formato certo | plugin do Claude Code | 1 | planejada | — |
| 3 | Remote Control | acesso principal pelo app Claude | `jarvis-remoto` | 1 | planejada | só a sua conta |
| 4 | Claude desktop via SSH | trabalho longo pelo PC | ambiente SSH do app | 1 | planejada | chave SSH do `jarvis` |
| 5 | Receitas + espelho | Oráculo e Miner sem acesso à produção | sudo restrito; timer root | 1 | planejada | lista fechada, Permitir, fotos |
| 6 | Clones dos repositórios | ler docs e preparar versões | deploy key só leitura | 1 | planejada | o Jarvis não envia; entrega bundle |
| 7 | Projeto J.A.R.V.I.S no claude.ai | conversas fora do Jarvis | doc do Projeto | 1 | ativa | não é fonte da verdade |
| 8 | Telegram | captura rápida, briefing e voz | Claude Code Channels (prévia de pesquisa), `jarvis-telegram` | 1 (antecipada) | planejada | allowlist |
| 8a | Voz — ida | seu áudio vira texto | Whisper `small` local (faster-whisper), skill `voz` | 1 (antecipada) | planejada | o áudio não sai do VPS |
| 8b | Voz — volta | a resposta vira áudio no Telegram | ElevenLabs (plano grátis), `jarvis-fala.path` + `falar.sh` | 1 (antecipada) | planejada | chave em `~/.config/jarvis/voz.env`, fora do Claude; só para o seu chat; até 700 caracteres por fala e 20 por hora; sem link, chave ou dado de terceiro na fala |
| 9 | Google Agenda | agenda no briefing | conector do claude.ai | 3 | planejada | só leitura; criar evento com "sim" |
| 10 | qmd | busca semântica na EducaBet | MCP stdio | 2 (opcional) | planejada | local |
| 11 | Robô de transcrição | aulas e áudios longos → texto | CLI numa skill (o Whisper do item 8a cobre as mensagens de voz) | 2–3 | planejada | local |
| 12 | iCal Airbnb e Booking | auditoria de bloqueios | `/ocupacao`; depois script sem IA (P6) | 4 | planejada | links só em `~/.config/jarvis/env`; domínios liberados no sandbox |
| 13 | Hostinger API | status do VPS, DNS | MCP `hostinger-api-mcp` | 4 | planejada | `ask` em tudo; cobrança negada |
| 14 | Site Mar & Lago → Jarvis | reserva vira nota | notificação colada no `/reserva`; webhook depois | 4 | planejada | validar a origem |
| — | Obsidian CLI | — | exige o app aberto | — | não se aplica no VPS | — |
| — | Obsidian Headless / Sync | — | trocado pelo Git (decisão de 30/10) | — | descartada por ora | — |
| — | WhatsApp | — | **não** como interface | — | descartada | política da Meta e risco de banir o número dos hóspedes |

## Notas
- **Telegram:** `/plugin install telegram@claude-plugins-official`, `/telegram:configure <token>`, sessão com `claude --channels plugin:telegram@claude-plugins-official`, pareamento com `/telegram:access pair <código>` e `/telegram:access policy allowlist`. O bot só responde com a sessão no ar (o serviço cuida). Prévia de pesquisa: o formato pode mudar.
- **iCal:** links de exportação de cada canal em `~/.config/jarvis/env` (`MARELAGO_ICAL_AIRBNB=...`, `MARELAGO_ICAL_BOOKING=...`), reinicie os serviços e teste com `node .claude/skills/ocupacao/scripts/ical.mjs`. Se o link usar outro domínio, acrescente em `vps/settings-usuario.json` (`sandbox.network.allowedDomains`) e no `~/.claude/settings.json` do VPS.
- **Hostinger:** `npm install -g hostinger-api-mcp`; token em `HOSTINGER_API_TOKEN`; `.mcp.json` na raiz do vault com `"env": { "API_TOKEN": "${HOSTINGER_API_TOKEN}" }`. Comece só com leitura — e lembre que é o servidor onde o próprio Jarvis roda.
- **Claude API direta:** não precisa. Só para algo que outras pessoas usem (ex.: atendente no site).
