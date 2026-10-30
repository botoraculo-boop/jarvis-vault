#!/bin/bash
# VOZ DO JARVIS: transforma em áudio (ElevenLabs) os textos que o Jarvis deixa em ~/JARVIS/.fala/ e manda
# como mensagem de voz no SEU chat do Telegram. Roda como jarvis, fora do Claude (jarvis-fala.path).
# A chave da ElevenLabs e o token do Telegram nunca passam pelo Claude nem pela linha de comando.
#   ~/.config/jarvis/voz.env:  ELEVENLABS_API_KEY=...  ELEVENLABS_VOICE_ID=...  [ELEVENLABS_MODEL=eleven_multilingual_v2]
set -u
export PATH=/usr/bin:/bin
FILA="$HOME/JARVIS/.fala"
ERRO="$HOME/.cache/jarvis/fala-erro"
CONTA="$HOME/.cache/jarvis/fala-contagem"
MAX_CARACTERES=700          # cada fala; o resto fica só no texto (o plano grátis conta caracteres)
MAX_POR_HORA=20             # trava contra repetição
mkdir -p "$ERRO"

valor() { sed -n "s/^$1=\(.*\)$/\1/p" "$2" 2>/dev/null | head -1 | tr -d '"'"'"' \r'; }
KEY="$(valor ELEVENLABS_API_KEY "$HOME/.config/jarvis/voz.env")"
VOZ="$(valor ELEVENLABS_VOICE_ID "$HOME/.config/jarvis/voz.env")"
MODELO="$(valor ELEVENLABS_MODEL "$HOME/.config/jarvis/voz.env")"; MODELO="${MODELO:-eleven_multilingual_v2}"
CHAT="$(valor TELEGRAM_CHAT_ID "$HOME/.config/jarvis/notificacao.env")"
TOKEN="$(valor TELEGRAM_BOT_TOKEN "$HOME/.claude/channels/telegram/.env")"
[[ "$VOZ" =~ ^[A-Za-z0-9]{10,40}$ ]] || VOZ=""
[[ "$MODELO" =~ ^[a-z0-9_]{3,60}$ ]] || MODELO=eleven_multilingual_v2

for f in "$FILA"/*; do
  [ -e "$f" ] || continue
  nome="$(basename "$f")"
  if [ -L "$f" ] || [ ! -f "$f" ]; then rm -rf "$f"; continue; fi     # só arquivo comum; atalho ou pasta sai
  texto="$(head -c 4000 "$f" | tr -d '\000' | head -c "$MAX_CARACTERES")"
  rm -f "$f"
  [ -n "${texto//[[:space:]]/}" ] || continue
  if [ -z "$KEY" ] || [ -z "$VOZ" ] || [ -z "$CHAT" ] || [ -z "$TOKEN" ]; then
    echo "$(date '+%F %T') voz não configurada (voz.env / notificacao.env / Telegram): $nome" >> "$ERRO/log.txt"; continue
  fi
  # limite por hora
  hora="$(date +%Y%m%d%H)"; n=0
  [ -f "$CONTA" ] && [ "$(cut -d' ' -f1 "$CONTA")" = "$hora" ] && n="$(cut -d' ' -f2 "$CONTA")"
  if [ "$n" -ge "$MAX_POR_HORA" ]; then echo "$(date '+%F %T') limite de $MAX_POR_HORA falas por hora" >> "$ERRO/log.txt"; continue; fi
  echo "$hora $((n + 1))" > "$CONTA"

  tmp="$(mktemp -d)"
  corpo="$(python3 -I -c 'import json,sys; print(json.dumps({"text": sys.stdin.read(), "model_id": sys.argv[1]}))' "$MODELO" <<<"$texto")"
  codigo="$(printf 'header = "xi-api-key: %s"\n' "$KEY" | curl -sS -m 60 -K - -o "$tmp/fala.mp3" -w '%{http_code}' \
      -H 'Content-Type: application/json' -H 'Accept: audio/mpeg' \
      --data-binary "$corpo" "https://api.elevenlabs.io/v1/text-to-speech/$VOZ?output_format=mp3_44100_128")"
  if [ "$codigo" != "200" ]; then
    echo "$(date '+%F %T') ElevenLabs respondeu $codigo: $(head -c 300 "$tmp/fala.mp3" 2>/dev/null)" >> "$ERRO/log.txt"
    rm -rf "$tmp"; continue
  fi
  # o Telegram só mostra como "mensagem de voz" em OGG/Opus
  if ffmpeg -loglevel error -y -i "$tmp/fala.mp3" -c:a libopus -b:a 48k "$tmp/fala.ogg" 2>>"$ERRO/log.txt"; then
    arq="$tmp/fala.ogg"; metodo=sendVoice; campo=voice
  else
    arq="$tmp/fala.mp3"; metodo=sendAudio; campo=audio
  fi
  r="$(printf 'url = "https://api.telegram.org/bot%s/%s"\n' "$TOKEN" "$metodo" | \
       curl -sS -m 60 -K - -o /dev/null -w '%{http_code}' -F "chat_id=$CHAT" -F "$campo=@$arq")"
  [ "$r" = "200" ] || echo "$(date '+%F %T') Telegram respondeu $r ao mandar a voz" >> "$ERRO/log.txt"
  rm -rf "$tmp"
done
exit 0
