#!/bin/bash
# Sessão com o canal do Telegram (roda dentro do tmux -L jarvis-telegram, iniciado pelo jarvis-telegram.service).
export PATH="$HOME/.local/bin:$HOME/.local/node/bin:$HOME/.bun/bin:/usr/local/bin:/usr/bin:/bin"
[ -f "$HOME/.config/jarvis/env" ] && { set -a; . "$HOME/.config/jarvis/env"; set +a; }
MODO="${JARVIS_MODO_PERMISSAO:-auto}"
cd "$HOME/JARVIS" || exit 1
# Na subida o leitor do bot às vezes falha ("failed" no /mcp) e as mensagens não chegam:
# espera o leitor anterior largar o bot e dá mais tempo para o servidor do plugin subir.
export MCP_TIMEOUT=60000
pkill -u "$(id -u)" -f 'plugins/cache/claude-plugins-official/telegram' 2>/dev/null || true
sleep 10
while true; do
  echo "$(date '+%F %T') iniciando a sessão do Telegram (modo $MODO)"
  claude --channels plugin:telegram@claude-plugins-official --permission-mode "$MODO"
  echo "$(date '+%F %T') sessão do Telegram saiu (código $?); voltando em 15 s"
  sleep 15
done
