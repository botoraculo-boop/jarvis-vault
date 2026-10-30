#!/bin/bash
# Sessão com o canal do Telegram (roda dentro do tmux -L jarvis-telegram, iniciado pelo jarvis-telegram.service).
export PATH="$HOME/.local/bin:$HOME/.local/node/bin:$HOME/.bun/bin:/usr/local/bin:/usr/bin:/bin"
[ -f "$HOME/.config/jarvis/env" ] && { set -a; . "$HOME/.config/jarvis/env"; set +a; }
MODO="${JARVIS_MODO_PERMISSAO:-default}"
cd "$HOME/JARVIS" || exit 1
while true; do
  echo "$(date '+%F %T') iniciando a sessão do Telegram (modo $MODO)"
  claude --channels plugin:telegram@claude-plugins-official --permission-mode "$MODO"
  echo "$(date '+%F %T') sessão do Telegram saiu (código $?); voltando em 15 s"
  sleep 15
done
