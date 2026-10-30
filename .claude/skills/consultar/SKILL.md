---
name: consultar
description: Responde perguntas sobre os dados do Oráculo ou do The Miner usando o espelho só de leitura em ~/dados, seguindo as regras de estudo de cada projeto. Use para perguntas como "qual liga mais deu green no Handicap?" ou "como foi a Testnet esta semana?".
---

# /consultar <pergunta>

Siga `40-procedimentos/analise-de-dados-do-projeto.md`. Resumo técnico:
- Bancos: `~/dados/oraculo.db`, `~/dados/estudo.db` (Oráculo, a base histórica) e `~/dados/miner.db`. Abra sempre com `?mode=ro` (`sqlite3 'file:...?mode=ro'` ou Python com `uri=True`).
- Antes de consultar uma tabela, veja o esquema (`.schema tabela`) — não suponha colunas.
- Python com pandas: se não houver, use `sqlite3` puro; não instale nada sem pedir.
- Oráculo: os tempos (`ts`) são segundos desde 1970; Miner: milissegundos (`t`, `aberto_em`, `fechado_em`). Converta para Brasília.
- Resposta: número, intervalo (quando for estimativa), tamanho da amostra, data do espelho e o que não dá para concluir. Se a pergunta pedir o número **oficial** do Diário do Oráculo, diga que o oficial tem regras próprias (`diario.py`, `oficiais`) e que a sua conta é aproximada, ou reproduza a regra lendo o código no clone.
