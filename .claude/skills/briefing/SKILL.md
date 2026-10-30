---
name: briefing
description: Briefing da manhã — cria ou completa a nota do dia com foco, prioridades, resultados de ontem do Oráculo e do Miner, reservas, bloqueios pendentes e inbox. Use quando pedirem "briefing" ou no timer das 07h.
---

# /briefing

Roda às 07h (dias úteis) pelo timer, em modo sem interação: não pergunte nada, decida e anote o que decidiu.

1. `date` (horário de Brasília). Caminho da nota: `01-diario/AAAA/MM/AAAA-MM-DD.md`. Se não existe, crie a partir de `99-templates/diaria.md` (troque os `{{date...}}` pela data) e ponha no índice `01-diario/01-diario.md`.
2. Rode `python3 .claude/skills/briefing/scripts/resumo_projetos.py` (sem IA, lê o espelho). Use a saída como está; não recalcule.
3. Leia `50-jarvis/prioridades-ativas.md` e escolha **um foco** para o dia (o item mais alto que não está travado).
4. Reservas: frontmatter das notas em `10-projetos/mar-e-lago/reservas/` com check-in nos próximos 7 dias e as com `bloqueios_pendentes: true`.
5. Inbox: quantos itens em `00-inbox/` (só a contagem e os títulos).
6. Agenda: se o conector do Google Agenda estiver disponível, os eventos de hoje (só leitura). Se não, pule sem comentar.
7. Escreva na seção **Briefing** da nota (substitua só o conteúdo dessa seção, se já existir de hoje):
   ```
   **Foco:** ...
   **Prioridades:** 1. ... 2. ... 3. ...
   **Oráculo ontem:** ... (aproximado)
   **Miner ontem:** ...
   **Mar & Lago:** chegadas/saídas · bloqueios pendentes
   **Inbox:** N itens
   **Alertas:** (os do início de sessão, se houver)
   ```
8. Atualize o índice no topo da nota (`- 07:00 — briefing`).
9. Sua **última mensagem** é o resumo que vai para o Telegram: até 12 linhas, texto simples, sem tabela, começando por "Bom dia." e terminando com o foco.
