#!/usr/bin/env bash
# PostToolUse (Edit/Write): uma linha por edição em 50-jarvis/log/AAAA-MM.jsonl (fora do git).
set -u
V="${CLAUDE_PROJECT_DIR:-$HOME/JARVIS}"
mkdir -p "$V/50-jarvis/log"
python3 -c '
import json, sys, time
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
ti = d.get("tool_input") or {}
linha = {"ts": time.strftime("%Y-%m-%dT%H:%M:%S%z"), "ferramenta": d.get("tool_name"),
         "arquivo": ti.get("file_path") or ti.get("notebook_path"), "sessao": d.get("session_id")}
print(json.dumps(linha, ensure_ascii=False))
' >> "$V/50-jarvis/log/$(date +%Y-%m).jsonl" 2>/dev/null
exit 0
