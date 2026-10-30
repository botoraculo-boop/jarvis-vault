#!/bin/bash
# Sincroniza o vault do VPS com o GitHub (opção B): commit local, fetch, rebase, push. A cada 10 min (jarvis-git.timer).
# Em conflito: guarda o trabalho do VPS no ramo vps-conflito, volta a main ao estado do GitHub + nada perdido, e avisa.
set -u
# git sem ganchos nem programas vindos da configuração do repositório (o Jarvis escreve nesta pasta)
g() { git -c core.hooksPath=/dev/null -c core.fsmonitor=false -c core.sshCommand=ssh -c credential.helper= "$@"; }
V="$HOME/JARVIS"
MARCA="$HOME/.cache/jarvis/conflito-git"
mkdir -p "$HOME/.cache/jarvis"
cd "$V" || exit 1
exec 9>"$V/.git/jarvis-sync.lock"
flock -n 9 || exit 0
[ -d .git/rebase-merge ] || [ -d .git/rebase-apply ] && g rebase --abort >/dev/null 2>&1

g add -A
g diff --cached --quiet || g commit -q -m "vps: sincronização $(date '+%Y-%m-%d %H:%M')"
g fetch -q origin main || { echo "fetch falhou (rede?)"; exit 0; }

# depois de um conflito: se você já juntou o vps-conflito na main pelo PC, reaplica só o que veio depois dele
BASE=origin/main
if [ -f "$MARCA" ]; then
  SHA="$(sed -n 2p "$MARCA")"
  if [ -n "$SHA" ] && g merge-base --is-ancestor "$SHA" origin/main 2>/dev/null; then
    if g rebase -q --onto origin/main "$SHA" >/dev/null 2>&1; then BASE=""; else g rebase --abort >/dev/null 2>&1; fi
  fi
fi

if [ -z "$BASE" ] || g rebase -q origin/main >/dev/null 2>&1; then
  g push -q origin HEAD:main && { [ -f "$MARCA" ] && rm -f "$MARCA" && echo "Vault: conflito resolvido, sincronização normal." | /opt/jarvis/bin/notificar.sh; exit 0; }
  echo "push falhou"; exit 1
fi

g rebase --abort >/dev/null 2>&1
g push -q -f origin HEAD:refs/heads/vps-conflito
if [ -f "$MARCA" ]; then
  { head -1 "$MARCA"; g rev-parse HEAD; } > "$MARCA.novo" && mv "$MARCA.novo" "$MARCA"   # o que está no vps-conflito agora
else
  { date '+%d/%m %H:%M'; g rev-parse HEAD; } > "$MARCA"
  echo "Conflito entre o vault do VPS e o GitHub. O trabalho do VPS está no ramo vps-conflito; o VPS continua trabalhando e tenta de novo a cada 10 min. Resolver no PC: runbook 'sincronizacao'." | /opt/jarvis/bin/notificar.sh
fi
exit 1
