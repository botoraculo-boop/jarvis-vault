---
tipo: runbook
atualizado: 2026-10-30
---

# Espelho (P14)

**O que é:** a cópia só de leitura dos bancos dos robôs, para o Jarvis analisar sem chegar perto da produção.

| Arquivo em `~/dados` | Origem | Frequência | O que fica |
|---|---|---|---|
| `oraculo.db` | `/opt/oraculo/oraculo.db` | de hora em hora (min. 07) | jogos, fotos, mercado, alertas, diario, noticias, arquivo, arquivo_resumo, versoes, ts_*, tips, entradas, apostas, odds_minuto, arquivo_completo, pistas, lab_disparos |
| `estudo.db` | `/opt/oraculo/estudo.db` | 1x por dia, se mudou | inteiro (base histórica, sem contas) |
| `miner.db` | `/opt/miner/dados/miner.db` | de hora em hora | eventos, sinais, trades, patrimonio, backtests, estado |

**Fica de fora:** no Oráculo, `usuarios`, `sessoes`, `tentativas`, `chats`, `contas_telegram`, `ajustes`, `ajustes_log`, `cache`; no Miner, `velas` (cache). As senhas e chaves do Miner (`configuracoes.json`, `.env`) e do Oráculo (`config.json`) nunca são copiadas.

**Lista branca:** só as tabelas listadas entram. Tabela nova numa versão futura fica de fora e o log avisa (`ATENÇÃO: tabela nova fora do espelho`). Para incluir: confira que não é de contas, edite a lista em `vps/bin/espelho.py` no PC e rode o passo 7.

**Como funciona:** `jarvis-espelho.timer` → `espelho.py` como root, com prioridade de disco e CPU mínimas → cópia consistente (API de backup do SQLite) numa pasta só do root → apaga as tabelas fora da lista → `VACUUM` → troca o arquivo em `~/dados` de uma vez. Os arquivos ficam em `/var/lib/jarvis-dados` (`root:jarvis 750`, arquivos `640`), **fora** da casa do `jarvis` — assim ele não consegue trocar a pasta nem plantar atalhos que o root seguiria; `~/dados` é só um atalho para lá. O Jarvis lê, não escreve. Pula se o disco não tiver o dobro do banco + 1 GB livre.

**Log:** `~/dados/espelho.log` (= `/var/lib/jarvis-dados/espelho.log`). Atualizar agora: `receita espelho`.

**Como ler:** sempre `?mode=ro` (procedimento [[analise-de-dados-do-projeto]]).
