---
paths:
  - "30-conhecimento/**"
---

# Regras da base de conhecimento (30-conhecimento/)

- `raw/` é sagrado: só leitura. Fonte nova entra pela mão dele (ou do robô de transcrição), nunca pelo Jarvis.
- `wiki/<curso>/` guarda o compilado: um conceito por nota, título igual ao conceito, frontmatter `tipo: wiki`, `fontes: [...]`.
- Toda afirmação tem citação no formato `(<curso> · <aula> @ HH:MM:SS)`; para PDF, `(<arquivo> p. N)`.
- Quando duas aulas divergem, a nota mostra as duas, com as citações, e não escolhe.
- Comentário do Jarvis vem separado, com o rótulo "Comentário do Jarvis".
- Cada pasta da wiki tem o seu índice; o índice do curso lista os módulos e os conceitos principais.
- Ajuste estas regras depois do primeiro módulo (Fase 2, passo 2 do roadmap).
