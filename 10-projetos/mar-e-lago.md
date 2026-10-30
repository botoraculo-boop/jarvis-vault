---
tipo: projeto
status: ativo
atualizado: 2026-10-30
aliases: [Mar & Lago, Apartamento Mar & Lago, apartamento na praia, site do apê]
---

# Apartamento Mar & Lago

**Em uma frase:** apartamento de praia da família, 2 quartos, no Condomínio Paraíso das Águas, Guarajuba (BA), alugado no Airbnb e no Booking, com um site de reserva direta em construção.

## Regras da casa conhecidas
- Animais não, exceto cão de assistência.

## Decisões (ver [[decisoes]])
- Sem sincronização automática com Airbnb/Booking: reserva pelo site → a família bloqueia as datas à mão nos outros canais.
- Sem pagamento online por enquanto: Pix pelo WhatsApp, cobrado pela família.
- Site no mesmo VPS da Hostinger, em link separado, sem mexer nos outros programas. Ainda sem domínio.
- WhatsApp não é canal do Jarvis: ele só rascunha, a família envia.

## O que o Jarvis faz aqui
- `/reserva` — nota da reserva, checklist de bloqueio e rascunhos de mensagem.
- `/ocupacao` — confere nos iCals se os bloqueios foram feitos (Fase 4; depois vira script sem IA, P6).
- Procedimento [[mensagem-para-hospede]].

## Falta preencher (por `/entrevista mar-e-lago`)
- Perfil do hóspede, FAQ de Guarajuba, tom de voz, persona do anfitrião, perguntas de hóspedes (literais), check-in/check-out, preços e regras.

## Reservas
- `10-projetos/mar-e-lago/reservas/` (criada pelo `/reserva`) e o painel [[bloqueios-pendentes.base]].
