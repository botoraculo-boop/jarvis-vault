---
name: wiki-ingest
description: Compila fontes de 30-conhecimento/raw/ em notas de wiki com citação de cada afirmação, pelo subagente bibliotecario. Use com "/wiki-ingest <pasta ou arquivo do raw>" (Fase 2, EducaBet).
---

# /wiki-ingest <alvo>

1. Liste os arquivos do alvo em `30-conhecimento/raw/` (só leitura — nunca escreva ali).
2. Divida em lotes de até ~10 aulas e chame o subagente `bibliotecario` para cada lote, com as regras de `.claude/rules/conhecimento.md`.
3. Junte o que ele devolver nas notas de `30-conhecimento/wiki/<curso>/` (acrescentar antes de criar; um conceito = uma nota), com os índices.
4. Primeiro lote de um curso novo: pare e mostre 2 notas para ele avaliar antes de seguir.
5. Checkpoint com: arquivos lidos, notas criadas ou acrescidas, dúvidas.
