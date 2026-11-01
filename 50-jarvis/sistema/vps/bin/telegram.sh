#!/bin/bash
# Sessão com o canal do Telegram. Uso: telegram.sh [1|2]
#   1 (padrão) = bot principal: tmux -L jarvis-telegram,   pasta ~/.claude/channels/telegram   (jarvis-telegram.service)
#   2          = segundo bot:   tmux -L jarvis-telegram-2, pasta ~/.claude/channels/telegram-2 (jarvis-telegram-2.service)
# Cada bot tem a sua pasta (token, lista de acesso, anexos recebidos) e a sua sessão: as conversas não se misturam.
# Bot 1 = Capi, bot 2 = Jarviz (mesmo vault, mesmas regras do CLAUDE.md; o nome vem do --append-system-prompt).
export PATH="$HOME/.local/bin:$HOME/.local/node/bin:$HOME/.bun/bin:/usr/local/bin:/usr/bin:/bin"
[ -f "$HOME/.config/jarvis/env" ] && { set -a; . "$HOME/.config/jarvis/env"; set +a; }
MODO="${JARVIS_MODO_PERMISSAO:-auto}"
BOT="${1:-1}"
case "$BOT" in
  1) export TELEGRAM_STATE_DIR="$HOME/.claude/channels/telegram";   NOME="Capi";  OUTRO="Jarviz" ;;
  2) export TELEGRAM_STATE_DIR="$HOME/.claude/channels/telegram-2"; NOME="Jarviz"; OUTRO="Capi"  ;;
  *) echo "bot inválido: $BOT (use 1 ou 2)"; exit 2 ;;
esac
if [ ! -f "$TELEGRAM_STATE_DIR/.env" ]; then
  echo "$(date '+%F %T') falta o token do bot $BOT em $TELEGRAM_STATE_DIR/.env; tentando de novo em 5 min"
  sleep 300; exit 1
fi
cd "$HOME/JARVIS" || exit 1
# Na subida o leitor do bot às vezes falha ("failed" no /mcp) e as mensagens não chegam:
# espera o leitor anterior DESTE bot largar e dá mais tempo para o servidor do plugin subir.
# Só mata o plugin deste bot (pela pasta no ambiente do processo); o do outro bot continua.
export MCP_TIMEOUT=60000
for pid in $(pgrep -u "$(id -u)" -f 'plugins/cache/claude-plugins-official/telegram' 2>/dev/null); do
  sd="$(tr '\0' '\n' < "/proc/$pid/environ" 2>/dev/null | sed -n 's/^TELEGRAM_STATE_DIR=//p')"
  if [ "$sd" = "$TELEGRAM_STATE_DIR" ] || { [ "$BOT" = 1 ] && [ -z "$sd" ]; }; then
    kill "$pid" 2>/dev/null || true
  fi
done
sleep 10
IDENTIDADE="Nesta sessão você se chama $NOME e atende o bot $BOT do Telegram. O Mestre tem dois agentes no mesmo vault, com as mesmas regras do CLAUDE.md: Capi (bot 1) e Jarviz (bot 2); o outro agente agora é o $OUTRO. Onde o CLAUDE.md e as notas dizem Capi, vale para os dois, mas o seu nome é $NOME. Cada um tem a sua conversa; podem existir também sessões do app. Assine com $NOME toda entrada que fizer na nota diária. Antes de começar uma tarefa e antes de cada checkpoint, leia as entradas de hoje do $OUTRO e das outras sessões; se alguém estiver no mesmo assunto ou nos mesmos arquivos, avise o Mestre antes de continuar. Antes de editar memoria.md ou decisoes.md, releia o arquivo. Para resposta em voz, o arquivo em .fala/ se chama <chat_id>--bot$BOT--<assunto>.txt (assim a voz sai pelo seu bot)."
while true; do
  echo "$(date '+%F %T') iniciando a sessão do Telegram $BOT (modo $MODO)"
  claude --channels plugin:telegram@claude-plugins-official --permission-mode "$MODO" --append-system-prompt "$IDENTIDADE"
  echo "$(date '+%F %T') sessão do Telegram $BOT saiu (código $?); voltando em 15 s"
  sleep 15
done
