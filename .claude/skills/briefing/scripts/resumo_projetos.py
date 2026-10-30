#!/usr/bin/env python3
"""Resumo de ontem do Oráculo e do Miner, lido do espelho (~/dados), sem IA e só leitura.

Uso: python3 resumo_projetos.py [AAAA-MM-DD]   (padrão: ontem, horário de Brasília)

Os números do Oráculo aqui são APROXIMADOS (soma simples do diario tipo 'oraculo' e da tabela tips):
o número oficial é o do Diário do Oráculo / resumo do Telegram, que tem regras próprias (uma entrada por jogo e placar).
"""
import datetime as dt
import os
import sqlite3
import sys

BR = dt.timezone(dt.timedelta(hours=-3))
DADOS = os.path.expanduser("~/dados")


def abrir(nome):
    caminho = os.path.join(DADOS, nome)
    if not os.path.exists(caminho):
        return None, None
    idade_h = (dt.datetime.now().timestamp() - os.path.getmtime(caminho)) / 3600
    con = sqlite3.connect(f"file:{caminho}?mode=ro", uri=True)
    con.row_factory = sqlite3.Row
    return con, idade_h


def tem_tabela(con, t):
    return con.execute("SELECT 1 FROM sqlite_master WHERE type='table' AND name=?", (t,)).fetchone() is not None


def main():
    dia = dt.date.fromisoformat(sys.argv[1]) if len(sys.argv) > 1 else (dt.datetime.now(BR) - dt.timedelta(days=1)).date()
    ini = dt.datetime.combine(dia, dt.time(0), BR).timestamp()
    fim = ini + 86400
    print(f"# Resumo de {dia.strftime('%d/%m/%Y')} (horário de Brasília)")

    con, idade = abrir("oraculo.db")
    if con is None:
        print("\n## Oráculo\n- espelho ~/dados/oraculo.db não encontrado")
    else:
        print(f"\n## Oráculo (espelho de {idade:.1f} h atrás; números aproximados)")
        if tem_tabela(con, "diario"):
            r = con.execute("SELECT COUNT(*) n, SUM(status!='aberta') fech, ROUND(SUM(COALESCE(lucro,0)),2) u, "
                            "SUM(resultado>0) g, SUM(resultado<0) rd FROM diario WHERE tipo='oraculo' AND ts>=? AND ts<?",
                            (ini, fim)).fetchone()
            print(f"- Gols: {r['n'] or 0} entradas ({r['fech'] or 0} fechadas: {r['g'] or 0} green, {r['rd'] or 0} red), "
                  f"{r['u'] or 0}u")
        if tem_tabela(con, "tips"):
            for r in con.execute("SELECT estrategia, COUNT(*) n, SUM(resultado>0) g, SUM(resultado<0) rd, "
                                 "ROUND(SUM(COALESCE(lucro,0)),2) u FROM tips WHERE ts>=? AND ts<? GROUP BY estrategia",
                                 (ini, fim)):
                print(f"- {r['estrategia']}: {r['n']} tips ({r['g'] or 0} green, {r['rd'] or 0} red), {r['u'] or 0}u")
        if tem_tabela(con, "lab_disparos"):
            n = con.execute("SELECT COUNT(*) FROM lab_disparos WHERE ts>=? AND ts<?", (ini, fim)).fetchone()[0]
            print(f"- LABORATÓRIO: {n} disparo(s) do radar")
        if tem_tabela(con, "jogos"):
            n = con.execute("SELECT COUNT(*) FROM jogos WHERE criado>=? AND criado<?", (ini, fim)).fetchone()[0]
            print(f"- Jogos acompanhados (novos no dia): {n}")
        con.close()

    con, idade = abrir("miner.db")
    if con is None:
        print("\n## The Miner\n- espelho ~/dados/miner.db não encontrado")
    else:
        print(f"\n## The Miner (espelho de {idade:.1f} h atrás)")
        ini_ms, fim_ms = int(ini * 1000), int(fim * 1000)
        linhas = con.execute("SELECT modo, COUNT(*) n, SUM(resultado_usd>0) g, ROUND(SUM(COALESCE(resultado_usd,0)),2) usd, "
                             "ROUND(SUM(COALESCE(resultado_r,0)),2) r FROM trades WHERE fechado_em>=? AND fechado_em<? "
                             "GROUP BY modo", (ini_ms, fim_ms)).fetchall()
        if not linhas:
            print("- Nenhuma operação fechada no dia.")
        for r in linhas:
            print(f"- {r['modo']}: {r['n']} fechadas, {r['g'] or 0} no lucro, US$ {r['usd']}, {r['r']}R")
        abertas = con.execute("SELECT modo, COUNT(*) FROM trades WHERE status='aberto' GROUP BY modo").fetchall()
        if abertas:
            print("- Abertas agora: " + ", ".join(f"{m} {n}" for m, n in abertas))
        erros = con.execute("SELECT COUNT(*) FROM eventos WHERE nivel='erro' AND t>=? AND t<?",
                            (ini_ms, fim_ms)).fetchone()[0]
        if erros:
            print(f"- Eventos de erro no dia: {erros}")
        con.close()


if __name__ == "__main__":
    main()
