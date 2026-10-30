#!/usr/bin/env bash
# SessionStart: o que sai no stdout entra no contexto do Jarvis.
# Só leitura e só avisos curtos. Nunca imprime segredo.
set -u
V="${CLAUDE_PROJECT_DIR:-$HOME/JARVIS}"
DIAS=(domingo segunda-feira terça-feira quarta-feira quinta-feira sexta-feira sábado)
echo "Agora: ${DIAS[$(TZ=America/Sao_Paulo date +%w)]}, $(TZ=America/Sao_Paulo date '+%d/%m/%Y %H:%M') (horário de Brasília). Use esta data ao escrever datas."

# reservas com bloqueio pendente nos outros canais
pend=$(grep -rlE '^bloqueios_pendentes:[[:space:]]*true' "$V/10-projetos/mar-e-lago/reservas" 2>/dev/null | wc -l)
[ "$pend" -gt 0 ] && echo "ALERTA: $pend reserva(s) do Mar & Lago com bloqueio pendente nos outros canais (painel bloqueios-pendentes)."

# conflito da sincronização do vault (marcado pelo git-sync.sh)
[ -f "$HOME/.cache/jarvis/conflito-git" ] && echo "ALERTA: conflito entre o vault do VPS e o GitHub (desde $(head -1 "$HOME/.cache/jarvis/conflito-git")). O trabalho do VPS está no ramo vps-conflito; resolver no PC (runbook: sincronizacao)."

# idade do espelho dos projetos
for db in oraculo miner; do
  f="$HOME/dados/$db.db"
  if [ -f "$f" ]; then
    idade=$(( ( $(date +%s) - $(stat -c %Y "$f") ) / 3600 ))
    [ "$idade" -ge 3 ] && echo "Aviso: o espelho $db.db tem ${idade}h (devia ser de hora em hora)."
  fi
done

# nota de ontem com lacunas
ontem=$(TZ=America/Sao_Paulo date -d yesterday +%Y/%m/%Y-%m-%d)
nota="$V/01-diario/$ontem.md"
if [ -f "$nota" ] && awk '/^## Lacunas/{f=1;next} /^## /{f=0} f && /[^[:space:]]/ && !/^<!--/' "$nota" | grep -q .; then
  echo "Lacunas na nota de ontem ($ontem.md): confira antes de começar."
fi

# itens no inbox
n=$(find "$V/00-inbox" -maxdepth 1 -type f -name '*.md' ! -name '00-inbox.md' 2>/dev/null | wc -l)
[ "$n" -gt 0 ] && echo "Inbox: $n item(ns) esperando o /inbox."
exit 0
