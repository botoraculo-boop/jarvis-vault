#!/usr/bin/env bash
# Stop: commit local de tudo que mudou no vault ao fim de cada resposta. Nunca faz push
# (quem leva ao GitHub é o jarvis-git.timer). Desligar: JARVIS_AUTOCOMMIT=0 em ~/.config/jarvis/env.
set -u
# git sem ganchos nem programas vindos da configuração do repositório (o Jarvis escreve nesta pasta)
g() { git -c core.hooksPath=/dev/null -c core.fsmonitor=false -c core.sshCommand=ssh -c credential.helper= "$@"; }
[ "${JARVIS_AUTOCOMMIT:-1}" = "0" ] && exit 0
V="${CLAUDE_PROJECT_DIR:-$HOME/JARVIS}"
cd "$V" 2>/dev/null || exit 0
g rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
# no meio de um rebase/merge, não mexe
[ -d .git/rebase-merge ] || [ -d .git/rebase-apply ] || [ -f .git/MERGE_HEAD ] && exit 0
g add -A >/dev/null 2>&1
g diff --cached --quiet && exit 0
n=$(g diff --cached --name-only | wc -l)
g commit -q -m "jarvis: $(date '+%Y-%m-%d %H:%M') · $n arquivo(s)" >/dev/null 2>&1 || true
exit 0
