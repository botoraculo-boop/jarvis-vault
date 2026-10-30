---
tipo: projeto
status: ativo
atualizado: 2026-10-30
repositorio: botoraculo-boop/theminer
aliases: [The Miner, theminer, Miner]
---

# The Miner

**Em uma frase:** robô de trading didático em perpétuos de cripto na Hyperliquid, com estratégias em checklist, gestão de risco por área e painel web; hoje em **Testnet** (dinheiro fictício, mercado real), validando métodos.

## Status (30/10/2026)
- Versão no repositório: **0.5.4** (28/10, atualizar pelo painel). Confirmar a que está rodando no VPS (receita `status`).
- Servidor: mesmo VPS, `/opt/miner`, serviço `miner`, painel só em `127.0.0.1:8777`. Atualizador `/opt/miner/ferramentas/atualizar.sh`, cópias em `/opt/miner-backups/` (as 5 últimas).
- Estratégias: referência (Surfista, Caçador, Elástico), Vela Trader (4 setups do curso) e Inner Circle/ICT (Vassoura, Bala de Prata — **sem vantagem comprovada**, só no papel até o teste em cripto). G.M.I só informativa.

## Prioridades
1. Validar os métodos na Testnet antes de qualquer coisa no real (caminho: Simulação → Testnet → Real).
2. Teste das estratégias do ICT em cripto (falta).
3. O backtest não conta o funding ainda.

## Onde está a verdade técnica (no clone `~/repos/theminer`)
- `PROJETO.md` (arquitetura, decisões, como estender), `LEIA-ME.md` (uso), `NOVIDADES.md` (versões), `conhecimento/` (cursos).

## Dados para o Jarvis
- Espelho só de leitura em `~/dados/miner.db` (de hora em hora), **sem** a tabela `velas` (cache de mercado). As senhas e chaves do Miner ficam em `dados/configuracoes.json` e `.env`, que o espelho **não** copia. Ver [[espelho]].
- Tabelas úteis: `trades` (por `modo`: testnet, simulacao...), `sinais`, `patrimonio`, `eventos`, `backtests`, `estado` (pico, início do dia, risco por área).

## O que o Jarvis faz aqui
- Lê resultados e compara estratégias (`/consultar`); propõe melhoria com o dado que a sustenta.
- Prepara versão num ramo e entrega o bundle para você publicar; instalar é o botão Atualizar do painel ou a receita `atualizar-miner`, com "Permitir".
- **Nunca:** chave da corretora, `.env`, ordens, mudar modo para Real.

## Decisões suas
- 2026-10-30 — Espelho só de leitura; o robô (com chave de corretora) fica fora do alcance do Jarvis. Ver [[decisoes]].

## Lições
- [[licoes]]
