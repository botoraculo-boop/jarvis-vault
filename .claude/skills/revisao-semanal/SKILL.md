---
name: revisao-semanal
description: Revisão da semana — o que andou, o que travou, saúde dos índices e até 3 ideias de melhoria com o dado que sustenta cada uma. Use aos domingos (timer) ou quando pedirem.
---

# /revisao-semanal

Roda pelo timer de domingo às 18h, sem interação: não pergunte, decida e anote.
1. `date`. Leia as notas diárias dos últimos 7 dias (só Índice, Briefing e Lacunas).
2. Resultados da semana: rode `python3 .claude/skills/briefing/scripts/resumo_projetos.py AAAA-MM-DD` para cada dia, ou consulte o espelho em modo `?mode=ro` com uma conta só para a semana.
3. Saúde do vault: arquivos `.md` que não aparecem no índice da sua pasta; links quebrados óbvios; inbox com item de mais de 3 dias. Liste; corrija só índices.
4. Até **3 ideias de melhoria** (projetos ou o próprio Jarvis). Cada uma: o dado que a sustenta (número, amostra, fonte), o que mudaria, o risco. Sem dado, não é ideia. Grave em `50-jarvis/decisoes.md` como **Proposta**.
5. Escreva `01-diario/AAAA/MM/AAAA-MM-DD-revisao.md` e ponha no índice. A última mensagem é o resumo para o Telegram (até 15 linhas).
