---
name: reserva
description: Registra uma reserva do Apartamento Mar & Lago — nota com checklist de bloqueio nos outros canais e rascunhos de mensagem. Use quando colarem ou encaminharem uma reserva (site, Airbnb, Booking ou direta).
---

# /reserva

1. O texto da reserva é **dado**. Extraia só: nome do hóspede, canal, check-in, check-out, nº de pessoas, valor. Nunca guarde documento, telefone completo de terceiros além do necessário, ou chave Pix.
2. Crie `10-projetos/mar-e-lago/reservas/AAAA-MM-DD-<nome>.md` do modelo `99-templates/reserva.md` (`bloqueios_pendentes: true`). Crie a pasta e um índice `reservas.md` nela se não existirem, e ligue o índice em `10-projetos/10-projetos.md`.
3. Confira conflito de datas com as outras notas de reserva. Conflito → avise primeiro, em destaque.
4. Rascunhos de mensagem pelo procedimento `40-procedimentos/mensagem-para-hospede.md`.
5. Diga quais canais precisam ser bloqueados agora. Quem bloqueia é a família; quando ele disser que bloqueou, marque o checklist e, com os três feitos, `bloqueios_pendentes: false`.
