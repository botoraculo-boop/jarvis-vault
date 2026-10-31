#!/bin/bash
# Servidor do Remote Control (roda dentro do tmux -L jarvis-remoto, iniciado pelo jarvis-remoto.service).
# Se o claude sair (rede caiu, atualização), volta em 15 s.
export PATH="$HOME/.local/bin:$HOME/.local/node/bin:$HOME/.bun/bin:/usr/local/bin:/usr/bin:/bin"
[ -f "$HOME/.config/jarvis/env" ] && { set -a; . "$HOME/.config/jarvis/env"; set +a; }
# O bot do Telegram só pode ter UM leitor: a sessão jarvis-telegram. Aqui o plugin carrega sem token
# (pasta vazia), para esta sessão não "roubar" as mensagens do Telegram.
export TELEGRAM_STATE_DIR="$HOME/.cache/jarvis/sem-telegram"; mkdir -p "$TELEGRAM_STATE_DIR"
MODO="${JARVIS_MODO_PERMISSAO:-auto}"
cd "$HOME/JARVIS" || exit 1
while true; do
  echo "$(date '+%F %T') iniciando remote-control (modo $MODO)"
  claude remote-control --name "Jarvis" --spawn same-dir --capacity 3 --permission-mode "$MODO"
  echo "$(date '+%F %T') remote-control saiu (código $?); voltando em 15 s"
  sleep 15
done
