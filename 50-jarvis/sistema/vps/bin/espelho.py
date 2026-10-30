#!/usr/bin/env python3
"""ESPELHO SÓ DE LEITURA (P14): copia os bancos do Oráculo e do The Miner para ~jarvis/dados, SEM os dados de contas.

Roda como root (jarvis-espelho.timer, de hora em hora), instalado em /opt/jarvis/bin/espelho.py (dono root).
- Cópia consistente com a API de backup do SQLite (os robôs continuam gravando).
- LISTA BRANCA: só as tabelas listadas abaixo ficam. Tabela nova numa versão futura dos robôs fica de fora até
  alguém a acrescentar aqui (e o log avisa). Assim, uma tabela de contas nova nunca vaza por descuido.
- O resultado vai para /var/lib/jarvis-dados (pasta root:jarvis 750, arquivos root:jarvis 640), fora da casa do jarvis
  (ele não consegue trocar a pasta nem plantar atalhos); ~jarvis/dados aponta para lá. O Jarvis lê, não escreve.
- O estudo.db do Oráculo (a base histórica, sem contas) vai 1x por dia, só se mudou.
"""
import os
import shutil
import sqlite3
import sys
import tempfile
import time

DESTINO = "/var/lib/jarvis-dados"   # fora da casa do jarvis; ~jarvis/dados é só um atalho para cá
TRABALHO = "/var/lib/jarvis/espelho"
LOG = os.path.join(DESTINO, "espelho.log")
GRUPO = "jarvis"

FONTES = {
    "oraculo.db": {
        "origem": "/opt/oraculo/oraculo.db",
        "manter": ["jogos", "fotos", "mercado", "alertas", "diario", "noticias", "arquivo", "arquivo_resumo", "versoes",
                   "ts_ids", "ts_mapa", "tips", "entradas", "ts_historico", "ts_historico_de", "ts_prova", "apostas",
                   "odds_minuto", "arquivo_completo", "pistas", "lab_disparos"],
        # as que sabemos que são de contas/segredos (só para o log não chamar de "nova")
        "conhecidas_fora": ["usuarios", "sessoes", "tentativas", "chats", "contas_telegram", "ajustes", "ajustes_log", "cache"],
    },
    "miner.db": {
        "origem": "/opt/miner/dados/miner.db",
        "manter": ["eventos", "sinais", "trades", "patrimonio", "backtests", "estado"],
        "conhecidas_fora": ["velas"],   # cache de mercado: grande e sem valor para análise
    },
    "estudo.db": {
        "origem": "/opt/oraculo/estudo.db",
        "manter": None,                 # base histórica de jogos, sem contas: vai inteira
        "conhecidas_fora": [],
        "intervalo_h": 24,
    },
}


def log(msg):
    linha = f"{time.strftime('%Y-%m-%d %H:%M:%S')} {msg}"
    print(linha)
    try:
        with open(LOG, "a", encoding="utf-8") as f:
            f.write(linha + "\n")
    except OSError:
        pass


def preparar_pastas():
    import grp
    gid = grp.getgrnam(GRUPO).gr_gid
    os.makedirs(TRABALHO, mode=0o700, exist_ok=True)
    os.chmod(TRABALHO, 0o700)
    if os.path.islink(DESTINO):
        raise SystemExit(f"{DESTINO} é um atalho: recusado")
    os.makedirs(DESTINO, exist_ok=True)
    st = os.lstat(DESTINO)
    if not os.path.isdir(DESTINO) or st.st_uid != 0:
        raise SystemExit(f"{DESTINO} não é uma pasta do root: recusado")
    os.chown(DESTINO, 0, gid)
    os.chmod(DESTINO, 0o750)
    if os.path.exists(LOG) and not os.path.islink(LOG):
        os.chown(LOG, 0, gid)
        os.chmod(LOG, 0o640)
    # log com no máximo ~2000 linhas
    try:
        linhas = open(LOG, encoding="utf-8").read().splitlines()
        if len(linhas) > 2000:
            open(LOG, "w", encoding="utf-8").write("\n".join(linhas[-1500:]) + "\n")
    except OSError:
        pass
    return gid


def espaco_ok(origem):
    tam = os.path.getsize(origem)
    livre = shutil.disk_usage(TRABALHO).free
    return tam * 2 + 1024 ** 3 < livre, tam


def copiar(nome, cfg, gid):
    origem = cfg["origem"]
    final = os.path.join(DESTINO, nome)
    if not os.path.isfile(origem) or os.path.islink(origem):
        log(f"{nome}: origem {origem} não encontrada; pulado")
        return
    intervalo = cfg.get("intervalo_h")
    if intervalo and os.path.exists(final):
        if os.path.getmtime(origem) <= os.path.getmtime(final) or time.time() - os.path.getmtime(final) < intervalo * 3600:
            return
    ok, tam = espaco_ok(origem)
    if not ok:
        log(f"{nome}: sem espaço em disco para copiar ({tam / 1e6:.0f} MB); pulado")
        return
    t0 = time.time()
    fd, tmp = tempfile.mkstemp(prefix=nome + ".", dir=TRABALHO)
    os.close(fd)
    try:
        a = sqlite3.connect(f"file:{origem}?mode=ro", uri=True, timeout=60)
        b = sqlite3.connect(tmp)
        a.backup(b, pages=4096, sleep=0.05)
        a.close()
        b.execute("PRAGMA journal_mode=DELETE")
        tabelas = [r[0] for r in b.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")]
        manter = cfg["manter"]
        fora, novas = [], []
        if manter is not None:
            for t in tabelas:
                if t not in manter:
                    b.execute(f'DROP TABLE "{t}"')
                    fora.append(t)
                    if t not in cfg["conhecidas_fora"]:
                        novas.append(t)
        b.commit()
        b.execute("VACUUM")
        b.close()
        os.chown(tmp, 0, gid)
        os.chmod(tmp, 0o640)
        # move para a pasta do jarvis de forma atômica (cópia ao lado + rename)
        lado = os.path.join(DESTINO, f".{nome}.novo")
        shutil.copyfile(tmp, lado)
        os.chown(lado, 0, gid)
        os.chmod(lado, 0o640)
        os.replace(lado, final)
        msg = f"{nome}: ok em {time.time() - t0:.0f}s, {os.path.getsize(final) / 1e6:.1f} MB, {len(tabelas) - len(fora)} tabelas"
        if novas:
            msg += f" · ATENÇÃO: tabela(s) nova(s) fora do espelho: {', '.join(novas)} (conferir e, se não forem de contas, acrescentar à lista em espelho.py)"
        log(msg)
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)


def main():
    if os.geteuid() != 0:
        raise SystemExit("rode como root (o timer jarvis-espelho faz isso)")
    gid = preparar_pastas()
    erros = 0
    for nome, cfg in FONTES.items():
        try:
            copiar(nome, cfg, gid)
        except Exception as e:  # um banco com problema não impede os outros
            erros += 1
            log(f"{nome}: ERRO {e}")
    if os.path.isfile(LOG) and not os.path.islink(LOG):
        os.chown(LOG, 0, gid)
        os.chmod(LOG, 0o640)
    sys.exit(1 if erros else 0)


if __name__ == "__main__":
    main()
