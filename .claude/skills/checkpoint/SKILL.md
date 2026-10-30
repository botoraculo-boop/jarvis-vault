---
name: checkpoint
description: Registra na nota do dia o que foi feito ou descoberto (entrada com horário) e confere se as notas mexidas batem com a realidade. Use quando disserem "checkpoint", ao fim de uma tarefa relevante e antes de encerrar.
---

# /checkpoint

1. `date`. Abra (ou crie, do modelo `99-templates/diaria.md`) a nota de hoje.
2. Acrescente no fim da seção **Registro** uma entrada `### HH:MM — <tópico>` com 2 a 6 linhas: o que foi feito, decidido ou descoberto, com links `[[nota]]` para onde está o detalhe. Nunca edite entradas antigas.
3. Atualize o **Índice** no topo: `- HH:MM — <tópico>`.
4. Notas mexidas desde o último checkpoint (use `git -C . log --since=<hora do último checkpoint> --name-only` e o log em `50-jarvis/log/`): para cada uma, confira em uma linha se o que diz ainda é verdade. Corrija o que estiver velho (acrescentar ou consolidar, regra 3).
5. Decisão nova dele → `50-jarvis/decisoes.md`. Lição → `50-jarvis/licoes.md`. Prioridade concluída ou nova → `50-jarvis/prioridades-ativas.md`.
6. O que ficou pela metade → seção **Lacunas** da nota do dia.
7. **Releia** o que gravou (as seções que mudou) e confirme numa frase. Se algo não gravou, diga.
