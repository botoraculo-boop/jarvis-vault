#!/bin/bash
# Roda uma skill sem interação (claude -p) e manda a última mensagem para o Telegram.
# Uso: rotina.sh briefing | revisao-semanal      (chamado pelos timers jarvis-briefing e jarvis-revisao)
set -u
export PATH="$HOME/.local/bin:$HOME/.local/node/bin:$HOME/.bun/bin:/usr/local/bin:/usr/bin:/bin"
[ -f "$HOME/.config/jarvis/env" ] && { set -a; . "$HOME/.config/jarvis/env"; set +a; }
SKILL="${1:?skill}"
case "$SKILL" in briefing|revisao-semanal) ;; *) echo "skill não permitida: $SKILL"; exit 2 ;; esac
MODELO="${JARVIS_MODELO_ROTINA:-sonnet}"
cd "$HOME/JARVIS" || exit 1
mkdir -p "$HOME/.cache/jarvis"
SAIDA="$HOME/.cache/jarvis/$SKILL.txt"
# acceptEdits: pode criar/editar notas no vault; comandos rodam no sandbox; o resto que pediria aprovação é negado
if timeout 20m claude -p "/$SKILL" --model "$MODELO" --permission-mode acceptEdits --output-format text > "$SAIDA" 2>"$SAIDA.erro"; then
  /opt/jarvis/bin/notificar.sh < "$SAIDA"
else
  cod=$?
  printf 'O %s das %s falhou (código %s). Veja: journalctl -u jarvis-%s -n 50\n%s\n' "$SKILL" "$(date +%H:%M)" "$cod" \
    "$( [ "$SKILL" = briefing ] && echo briefing || echo revisao )" "$(tail -n 5 "$SAIDA.erro")" | /opt/jarvis/bin/notificar.sh
  exit "$cod"
fi
