#!/bin/bash
# Manda o texto da entrada padrão para o seu chat no Telegram.
# O token NÃO passa pelo ambiente do Claude nem pela linha de comando (vai para o curl pela entrada padrão).
# Sem Telegram configurado, só guarda o aviso em ~/.cache/jarvis/avisos.txt.
set -u
export PATH=/usr/bin:/bin   # só programas do sistema (o curl recebe o token)
TEXTO="$(head -c 3900)"
[ -n "$TEXTO" ] || exit 0
mkdir -p "$HOME/.cache/jarvis"
CHAT=""; TOKEN=""
# um ou mais IDs separados por vírgula (ex.: TELEGRAM_CHAT_ID=111,222 — as suas contas)
[ -f "$HOME/.config/jarvis/notificacao.env" ] && CHAT="$(sed -n 's/^TELEGRAM_CHAT_ID=\([-0-9, ]*\)$/\1/p' "$HOME/.config/jarvis/notificacao.env" | head -1 | tr -d ' ')"
[ -f "$HOME/.claude/channels/telegram/.env" ] && TOKEN="$(sed -n 's/^TELEGRAM_BOT_TOKEN=\(.*\)$/\1/p' "$HOME/.claude/channels/telegram/.env" | head -1 | tr -d '"'"'"' ')"
if [ -z "$CHAT" ] || [ -z "$TOKEN" ]; then
  printf '%s\n%s\n\n' "$(date '+%F %T')" "$TEXTO" >> "$HOME/.cache/jarvis/avisos.txt"
  exit 0
fi
falhou=0
for id in ${CHAT//,/ }; do
  [[ "$id" =~ ^-?[0-9]+$ ]] || continue
  printf 'url = "https://api.telegram.org/bot%s/sendMessage"\n' "$TOKEN" | \
    curl -sS -m 20 -o /dev/null -w '%{http_code}' -K - --data-urlencode "chat_id=$id" --data-urlencode "text=$TEXTO" \
    | grep -q '^200$' || falhou=1
done
[ "$falhou" = 0 ] || printf '%s (falhou no Telegram para algum chat)\n%s\n\n' "$(date '+%F %T')" "$TEXTO" >> "$HOME/.cache/jarvis/avisos.txt"
