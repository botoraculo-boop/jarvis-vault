---
name: ocupacao
description: Audita nos calendários iCal do Airbnb e do Booking (só leitura) se cada reserva registrada no vault está bloqueada nos outros canais. Use com "/ocupacao" ou "confere os bloqueios".
---

# /ocupacao

1. Rode `node .claude/skills/ocupacao/scripts/ical.mjs` na raiz do vault. Ele lê os links de `MARELAGO_ICAL_AIRBNB` e `MARELAGO_ICAL_BOOKING` (do ambiente; **nunca** imprima nem escreva os links) e devolve, em JSON, os períodos ocupados de cada canal nos próximos 365 dias.
2. Compare com as notas em `10-projetos/mar-e-lago/reservas/`: para cada reserva, o período tem de aparecer como ocupado nos canais que **não** são o de origem.
3. Resultado: tabela curta "reserva · Airbnb · Booking", com ✔ / ✘. Para cada ✘, a ação: "bloquear DD/MM a DD/MM no <canal>".
4. Períodos ocupados nos iCals que não têm nota de reserva: liste como "reserva sem nota?" (pode ser bloqueio da família).
5. Não marque checklist sozinho: o iCal confirma o bloqueio, mas quem decide é ele. Ofereça marcar.
