---
tipo: estudo
atualizado: 2026-10-30
fonte: Projeto J.A.R.V.I.S no claude.ai, doc claude/estudo-jaredrhod-plano.md (texto completo)
---

# Estudo jaredrhod → plano do Jarvis (resumo)

O texto completo (o que tem no canal, as lives 24, 28, 29, 32 e 33 com os tempos dos vídeos) está no Projeto J.A.R.V.I.S do claude.ai. Aqui fica o que virou decisão — todas aceitas em 30/10 ([[decisoes]]).

| # | Proposta | Onde está no kit |
|---|---|---|
| P1 | Índices em três níveis; boot lendo só índice + memória | `VAULT-INDEX.md`, nota-índice por pasta, `CLAUDE.md` (Boot) |
| P2 | Nota diária com índice no topo + `/checkpoint` | `99-templates/diaria.md`, skill `checkpoint` |
| P3 | 7 regras novas | `CLAUDE.md`, Regras 1–7 |
| P4 | Procedimentos com "AI priming" | `40-procedimentos/` |
| P5 | Importar a memória e consolidar | `00-inbox/importacao/` |
| P6 | Automação sem IA quando for só conta | `resumo_projetos.py` do briefing; `/ocupacao` vira script na Fase 4 |
| P7 | Encher o cofre por entrevista | skill `entrevista` |
| P8 | Conhecimento compartilhado na raiz | `30-conhecimento/` |
| P9 | Kill switch | receita `parar-jarvis` + chave SSH do celular ([[receitas]]) |
| P10 | Sentinela com diagnóstico só leitura | [[roadmap]], Fase 3 |
| P11 | Runbook e lições | `50-jarvis/sistema/`, [[licoes]] |
| P12 | Boot e checkpoint reforçados | [[prioridades-ativas]], hook de início de sessão (lacunas de ontem), skill `checkpoint` |
| P13 | Kit do anfitrião | [[mar-e-lago]], procedimento [[mensagem-para-hospede]], Fase 4 |
| P14 | Espelho só de leitura + secretário dos projetos | [[espelho]], [[oraculo]], [[the-miner]] |

Não adotados: o instalador `fullstack-agent`, voz, visualizador, barehands, o redirecionamento do `MEMORY.md`, correção automática sem aprovação e mensagem a hóspede sem revisão.
