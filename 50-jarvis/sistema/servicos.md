---
tipo: runbook
atualizado: 2026-10-30
---

# Serviços (systemd)

Fontes em `vps/systemd/`; instalados em `/etc/systemd/system` pelo `instalar-servicos.sh`. Scripts em `/opt/jarvis/bin` (dono root).

| Unidade | Como | Faz | Quando |
|---|---|---|---|
| `jarvis-remoto` | jarvis, tmux `-L jarvis-remoto` | `claude remote-control --name Jarvis --spawn same-dir --capacity 3`: atende o app Claude; se sair, volta em 15 s | sempre |
| `jarvis-telegram` | jarvis, tmux `-L jarvis-telegram` | `telegram.sh 1`: **Capi**, bot 1 (`~/.claude/channels/telegram`) | sempre |
| `jarvis-telegram-2` | jarvis, tmux `-L jarvis-telegram-2` | `telegram.sh 2`: **Malt**, bot 2 (`~/.claude/channels/telegram-2`); mesmo vault e mesmas regras, conversa separada | sempre (desde 01/11) |
| `jarvis-vigia.timer` | root | `vigia-telegram.sh`: se o plugin de um bot some por ~10 min, reinicia só aquele bot e avisa; até 3 reinícios por bot em 3 h | a cada 5 min |
| `jarvis-fala.path` | jarvis | quando aparece um texto em `~/JARVIS/.fala/`, roda `falar.sh`: ElevenLabs → mensagem de voz no seu Telegram (até 700 caracteres por fala, 20 por hora) | sob demanda |
| `jarvis-briefing.timer` | jarvis | `rotina.sh briefing`: `claude -p "/briefing"` (modelo leve, `acceptEdits`) e a última mensagem vai para o Telegram | seg a sex, 07:00 de Brasília |
| `jarvis-revisao.timer` | jarvis | `rotina.sh revisao-semanal` | domingo, 18:00 |
| `jarvis-reinicio.timer` | root | `systemctl try-restart` das sessões: contexto limpo, atualizações do Claude aplicadas | todo dia, 04:30 |
| `jarvis-git.timer` | jarvis | `git-sync.sh` ([[sincronizacao]]) | a cada 10 min |
| `jarvis-espelho.timer` | root (`ProtectHome=read-only`) | `espelho.py` ([[espelho]]), grava em `/var/lib/jarvis-dados` | de hora em hora |

**Limites:** `Nice=10` (espelho 15, disco em "idle"); `jarvis-remoto` MemoryHigh 2G / MemoryMax 2,5G; cada Telegram 2G / 2,5G (o Whisper roda dentro dele); rotinas 1G / 1,5G. Os robôs não têm limite: em disputa de memória, quem cede é o Jarvis.

**Modelo:** as sessões usam o modelo padrão da sua conta (o mais forte para estratégia e estudo: troque com `/model` na conversa). As rotinas usam `JARVIS_MODELO_ROTINA` (padrão `sonnet`).

**Avisos sem Telegram:** vão para `~/.cache/jarvis/avisos.txt`.
