---
tipo: projeto
status: ativo
atualizado: 2026-10-30
repositorio: botoraculo-boop/oraculo
aliases: [Oráculo, Oraculo, Oráculos, Método Recovery]
---

# Oráculo

**Em uma frase:** robô de alertas ao vivo de futebol (Método Recovery) com três estratégias — Over gols no asiático, Handicap e Escanteios — que manda tips no Telegram e tem a tela em `https://2-25-247-175.sslip.io`.

## Status (30/10/2026)
- Versão no ar: **9.66** (o LABORATÓRIO), segundo o blueprint de 30/10. O `CLAUDE.md` do repositório, revisado em 22/10, ainda diz "9.44 no ar, 9.66 pronta para instalar": confirmar e anotar a data "no ar" na ficha `docs/versoes/9.66.md` do repositório.
- Servidor: mesmo VPS do Jarvis, `/opt/oraculo`, serviço `oraculo` (usuário `oraculo`), atualizador root `oraculo-atualizar.path`.
- Donos: Culiso e Zinks (a mesma pessoa, duas personalidades), com conta no Oráculo.

## Prioridades (do repositório, `docs/08-pendencias.md`, 22/10)
1. Conferir a 9.66: LABORATÓRIO, radar da P1, primeira madrugada (04:20), Telegram só da pista aprovada.
2. Tirar as ligas de base (sub-19/sub-20) em CONEXÕES → LIGAS DO MÉTODO → THESPORTS — ajuste é seu, o Jarvis não mexe.
3. Decidir a fonte de jogos: a conta da TheSports era de teste até ~30/10; a Sportmonks está no plano grátis desde 08/10.
4. A decidir com os donos: D-70 (escanteios e Handicap) e as decisões marcadas "a confirmar".

## Onde está a verdade técnica (no clone `~/repos/oraculo`)
- `CLAUDE.md` — contexto e "Onde paramos". **Ler antes de qualquer trabalho no Oráculo.**
- `docs/INDICE.md` → estratégia, regras do robô, estudos, versões, servidor, APIs, pendências, decisões (D-NN), pistas.

## Regras de estudo (obrigatórias ao analisar)
Métrica gols depois ÷ M2, bootstrap por jogo, IC 90%; cortes e escolhas só com 2023-25, **2026 é a prova** e só no fim. Bônus no robô sempre menor que o medido. Estudo que vai mudar o robô passa por conferência independente (um subagente refaz os números) antes de virar proposta.

## Dados para o Jarvis
- Espelho só de leitura em `~/dados/oraculo.db` (de hora em hora) e `~/dados/estudo.db` (1x por dia), **sem** `usuarios`, `sessoes`, `tentativas`, `chats`, `contas_telegram`, `ajustes`, `ajustes_log` e `cache`. Ver [[espelho]].
- Tabelas úteis: `alertas` e `diario` (gols), `tips` (Handicap e Escanteios), `apostas` (LABORATÓRIO), `pistas`, `lab_disparos`, `mercado` (arquivo do método), `odds_minuto`/`arquivo_completo` (9.55+), `jogos`.

## O que o Jarvis faz aqui
- Responde perguntas com os dados (`/consultar`), seguindo as regras de estudo.
- Prepara versão nova num ramo do clone (`/versao`), com a ficha e a linha em `docs/05-versoes.md`, e entrega o bundle para você publicar; instalar continua sendo o botão ATUALIZAR (ou a receita `atualizar-oraculo`, com "Permitir").
- **Não:** mexer em ajuste, chave, `/opt/oraculo`, nem disparar ATUALIZAR por conta própria.

## Decisões suas
- 2026-10-30 — O Jarvis vira secretário do Oráculo com espelho só de leitura (P14). Ver [[decisoes]].

## Lições
- [[licoes]]
