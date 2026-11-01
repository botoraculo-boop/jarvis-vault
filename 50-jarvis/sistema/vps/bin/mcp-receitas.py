#!/usr/bin/env python3
"""CONECTOR DAS RECEITAS (MCP, stdio) — o caminho do Capi até /opt/jarvis/bin/receita.

Por que existe: os comandos de terminal do Claude Code rodam no sandbox (bubblewrap), que liga o
"no new privileges" e impede o sudo. Um conector MCP é um processo à parte, fora desse sandbox, então
o sudo restrito funciona. Cada receita vira uma ferramenta própria, e as permissões do Claude Code
decidem quais rodam direto (status, logs, fotos, ajuda) e quais pedem "Permitir" (todas as que mudam algo).

Instalado em /opt/jarvis/bin/mcp-receitas.py (dono root: o Capi não consegue alterar).
Registrado para o usuário jarvis com:
    claude mcp add --scope user receitas -- /usr/bin/python3 -I /opt/jarvis/bin/mcp-receitas.py
Ele só sabe chamar `sudo -n /opt/jarvis/bin/receita <nome> [argumentos]`, com os nomes da lista abaixo;
a própria receita valida os argumentos de novo.
"""
import json
import os
import re
import subprocess
import sys

RECEITA = "/opt/jarvis/bin/receita"
SAIDA_MAX = 20000

ALVO = {"type": "string", "enum": ["oraculo", "miner"]}
FERRAMENTAS = {
    # nome da ferramenta: (receita, descrição, propriedades, obrigatórios, tempo limite em s)
    "status": ("status", "Situação do VPS: serviços (Oráculo, Miner, Jarvis), versões, memória, disco, idade do espelho e últimas fotos. Só lê.", {}, [], 60),
    "ajuda": ("ajuda", "Lista das receitas e o que cada uma faz. Só lê.", {}, [], 30),
    "fotos": ("fotos", "Lista as fotos guardadas antes de cada mudança (o que pode ser desfeito). Só lê.", {}, [], 30),
    "logs": ("logs", "Últimas linhas do log de um serviço. Só lê.",
             {"alvo": {"type": "string", "enum": ["oraculo", "oraculo-atualizar", "miner", "caddy", "jarvis-remoto",
                                                  "jarvis-telegram", "jarvis-telegram-2", "jarvis-briefing", "jarvis-revisao", "jarvis-git",
                                                  "jarvis-espelho", "jarvis-reinicio", "jarvis-fala"]},
              "linhas": {"type": "integer", "minimum": 1, "maximum": 300}}, ["alvo"], 60),
    "espelho": ("espelho", "Atualiza agora o espelho só de leitura dos bancos do Oráculo e do Miner.", {}, [], 1800),
    "backup": ("backup", "Copia o banco do Oráculo ou do Miner para /var/lib/jarvis/backups (fica 7 dias).", {"alvo": ALVO}, ["alvo"], 1800),
    "reiniciar": ("reiniciar", "Tira uma foto e reinicia o serviço do Oráculo ou do Miner.", {"alvo": ALVO}, ["alvo"], 120),
    "atualizar_oraculo": ("atualizar-oraculo", "Tira uma foto e entrega ao atualizador do Oráculo o pedido de instalar a versão (o mesmo do botão ATUALIZAR).",
                          {"versao": {"type": "string", "pattern": r"^\d+\.\d+(\.\d+)?$"},
                           "commit": {"type": "string", "pattern": r"^[0-9a-f]{40}$"}}, ["versao", "commit"], 300),
    "atualizar_miner": ("atualizar-miner", "Tira uma foto e entrega ao atualizador do Miner o pedido de atualizar (o mesmo do botão do painel).", {}, [], 300),
    "desfazer": ("desfazer", "Volta a mudança da última foto, ou da foto indicada pelo id.",
                 {"id": {"type": "string", "pattern": r"^\d{8}-\d{6}-[a-z-]+$"}}, [], 1800),
    "parar_jarvis": ("parar-jarvis", "KILL SWITCH: para todas as sessões do Jarvis (inclusive esta).", {}, [], 60),
    "ligar_jarvis": ("ligar-jarvis", "Liga de novo as sessões do Jarvis.", {}, [], 60),
}


def argumentos(nome, args):
    """Monta a lista de argumentos da receita, conferindo cada um (a receita confere de novo)."""
    receita, _, props, obrig, _ = FERRAMENTAS[nome]
    args = args or {}
    for k in args:
        if k not in props:
            raise ValueError(f"argumento desconhecido: {k}")
    for k in obrig:
        if k not in args:
            raise ValueError(f"falta o argumento: {k}")
    saida = [receita]
    for k, esp in props.items():
        if k not in args:
            continue
        v = args[k]
        if esp.get("type") == "integer":
            if not isinstance(v, int) or isinstance(v, bool) or not (esp["minimum"] <= v <= esp["maximum"]):
                raise ValueError(f"valor inválido para {k}")
            saida.append(str(v))
            continue
        if not isinstance(v, str):
            raise ValueError(f"valor inválido para {k}")
        if "enum" in esp and v not in esp["enum"]:
            raise ValueError(f"valor inválido para {k}")
        if "pattern" in esp and not re.fullmatch(esp["pattern"], v):
            raise ValueError(f"valor inválido para {k}")
        saida.append(v)
    return saida


def rodar(nome, args):
    try:
        lista = argumentos(nome, args)
    except ValueError as e:
        return f"ERRO: {e}", True
    tempo = FERRAMENTAS[nome][4]
    try:
        r = subprocess.run(["/usr/bin/sudo", "-n", RECEITA] + lista, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                           stderr=subprocess.STDOUT, timeout=tempo, cwd="/",
                           env={"PATH": "/usr/sbin:/usr/bin:/sbin:/bin", "LANG": "C.UTF-8"})
    except subprocess.TimeoutExpired:
        return f"ERRO: a receita passou de {tempo} s", True
    texto = r.stdout.decode("utf-8", "replace")
    if len(texto) > SAIDA_MAX:
        texto = texto[:SAIDA_MAX] + "\n... (cortado)"
    return texto or "(sem saída)", r.returncode != 0


def responder(id_, resultado=None, erro=None):
    msg = {"jsonrpc": "2.0", "id": id_}
    if erro is not None:
        msg["error"] = erro
    else:
        msg["result"] = resultado
    sys.stdout.write(json.dumps(msg, ensure_ascii=False) + "\n")
    sys.stdout.flush()


def lista_ferramentas():
    out = []
    for nome, (_, desc, props, obrig, _) in FERRAMENTAS.items():
        out.append({"name": nome, "description": desc,
                    "inputSchema": {"type": "object", "properties": props, "required": obrig, "additionalProperties": False}})
    return out


def main():
    os.chdir("/")
    for linha in sys.stdin:
        linha = linha.strip()
        if not linha:
            continue
        try:
            msg = json.loads(linha)
        except json.JSONDecodeError:
            continue
        metodo, id_ = msg.get("method"), msg.get("id")
        if id_ is None:  # notificação (ex.: notifications/initialized): não responde
            continue
        if metodo == "initialize":
            versao = (msg.get("params") or {}).get("protocolVersion") or "2025-06-18"
            responder(id_, {"protocolVersion": versao, "capabilities": {"tools": {}},
                            "serverInfo": {"name": "receitas", "version": "1.0"}})
        elif metodo == "ping":
            responder(id_, {})
        elif metodo == "tools/list":
            responder(id_, {"tools": lista_ferramentas()})
        elif metodo == "tools/call":
            p = msg.get("params") or {}
            nome = p.get("name")
            if nome not in FERRAMENTAS:
                responder(id_, {"content": [{"type": "text", "text": f"ERRO: ferramenta desconhecida: {nome}"}], "isError": True})
                continue
            texto, falhou = rodar(nome, p.get("arguments"))
            responder(id_, {"content": [{"type": "text", "text": texto}], "isError": falhou})
        else:
            responder(id_, erro={"code": -32601, "message": f"método não suportado: {metodo}"})


if __name__ == "__main__":
    main()
