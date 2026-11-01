#!/bin/bash
# VIGIA DO TELEGRAM — confere a cada 5 min (jarvis-vigia.timer) se o plugin de cada bot está vivo.
# Bug conhecido do Claude Code: às vezes a sessão sobe sem abrir o plugin do Telegram (ou ele cai) e o bot
# fica surdo com o serviço "active" (visto em 01/11: o Capi ficou das 04:30 às 14:20 sem plugin).
# Se o plugin de um bot ligado sumir em 2 conferências seguidas (~10 min), reinicia só aquele bot e avisa.
# Trava: no máximo 3 reinícios por bot a cada 3 h; depois disso só avisa (uma vez) e para de tentar.
# Roda como root. Não lê token nem conversa: só a lista de processos do usuário jarvis.
# Limite: não percebe o plugin que está vivo mas desistiu de escutar (409 persistente). Esse caso é raro.
set -u
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
EST=/var/lib/jarvis/vigia
install -d -m 700 -o root -g root /var/lib/jarvis "$EST"

avisar() {
  logger -t jarvis-vigia -- "$1" || true
  printf '%s\n' "$1" | runuser -u jarvis -- env HOME=/home/jarvis /opt/jarvis/bin/notificar.sh || true
}

plugin_vivo() {  # $1 = pasta do bot; $2 = 1 se aceita processo sem pasta no ambiente (bot 1, script antigo)
  local pid sd
  for pid in $(pgrep -u jarvis -f 'plugins/cache/claude-plugins-official/telegram' 2>/dev/null); do
    sd="$(tr '\0' '\n' < "/proc/$pid/environ" 2>/dev/null | sed -n 's/^TELEGRAM_STATE_DIR=//p')"
    [ "$sd" = "$1" ] && return 0
    [ "$2" = 1 ] && [ -z "$sd" ] && return 0
  done
  return 1
}

conferir() {  # $1 unidade  $2 pasta do bot  $3 nome  $4 aceita-sem-pasta
  local u="$1" dir="$2" nome="$3" f="$EST/$1" agora inicio n
  # desligado ou parado (kill switch, falha do systemd): não é com o vigia
  if ! systemctl is-enabled --quiet "$u" 2>/dev/null || ! systemctl is-active --quiet "$u" 2>/dev/null; then
    rm -f "$f.falhas"; return 0
  fi
  agora=$(date +%s)
  inicio=$(date -d "$(systemctl show -p ActiveEnterTimestamp --value "$u")" +%s 2>/dev/null || echo 0)
  [ $((agora - inicio)) -ge 180 ] || return 0     # subiu há menos de 3 min (40 s de espera + plugin): dá tempo
  if plugin_vivo "$dir" "$4"; then rm -f "$f.falhas" "$f.desisti"; return 0; fi
  n=$(( $(cat "$f.falhas" 2>/dev/null || echo 0) + 1 ))
  echo "$n" > "$f.falhas"
  [ "$n" -ge 2 ] || return 0
  touch "$f.reinicios"
  awk -v lim=$((agora - 10800)) '$1 >= lim' "$f.reinicios" > "$f.tmp" && mv "$f.tmp" "$f.reinicios"
  if [ "$(wc -l < "$f.reinicios")" -ge 3 ]; then
    if [ ! -e "$f.desisti" ]; then
      touch "$f.desisti"
      avisar "Vigia: o $nome ($u) continua sem o plugin do Telegram depois de 3 reinícios em 3 h. Parei de tentar. Pelo SSH: sudo -iu jarvis tmux -L $u attach e /mcp."
    fi
    return 0
  fi
  rm -f "$f.falhas"
  echo "$agora" >> "$f.reinicios"
  systemctl restart --no-block "$u"
  avisar "Vigia: o $nome estava surdo (plugin do Telegram fora do ar há uns 10 min). Reiniciei o $u às $(TZ=America/Sao_Paulo date +%H:%M) de Brasília; volta em 1 a 2 min. Mensagens desse intervalo devem chegar depois; se ele não responder, mande de novo."
}

conferir jarvis-telegram   /home/jarvis/.claude/channels/telegram   Capi 1
conferir jarvis-telegram-2 /home/jarvis/.claude/channels/telegram-2 Malt 0
exit 0
