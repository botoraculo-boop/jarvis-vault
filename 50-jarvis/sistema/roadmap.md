---
tipo: runbook
atualizado: 2026-10-30
---

# Roadmap

Regra: a fase seguinte só começa quando a anterior está em uso real há uma semana.

## Fase 0 — Decisões ✔
- [x] Jarvis pessoal, no VPS — 2026-10-30
- [x] Sync: Git (GitHub privado) — 2026-10-30
- [x] RAM: 7,8 GB, 6,3 GB livres com os robôs; swap de 4 GB na instalação — 2026-10-30
- [x] Propostas P1–P14 aceitas; modelo do porteiro — 2026-10-30
- [ ] Confirmar as **Propostas** que ainda estão abertas em [[decisoes]]

## Fase 1 — Fundação no VPS
- [x] Kit montado (vault, `CLAUDE.md`, skills, hooks, permissões, receitas, espelho, serviços) — 2026-10-30
- [ ] [[vps]], passos 1 a 9, e o teste de aceitação
- [ ] App Claude no celular com notificação; Claude desktop por SSH
- [ ] Telegram pareado e **voz** (Whisper na ida, ElevenLabs grátis na volta) — antecipados da Fase 3 a seu pedido em 30/10
- [ ] Plugin kepano/obsidian-skills
- [ ] Consolidar `00-inbox/importacao/` (P5)
- [ ] `/entrevista`: você, Mar & Lago, Poker das Lendas
- [ ] Notas de contexto do Mar & Lago para o procedimento de mensagem (perfil, FAQ, tom de voz)
- [ ] Usar por 7 dias: briefing às 07h, `/capturar` e `/checkpoint` de dia, `/inbox` à noite

**Pronto quando:** de manhã a nota do dia já está lá, certa, e você falou com o Jarvis pelo celular sem abrir o PC.

## Fase 2 — A missão (EducaBet)
- [ ] Transcrições e materiais em `30-conhecimento/raw/educabet/`
- [ ] `/wiki-ingest` de 1 módulo, revisar, ajustar `.claude/rules/conhecimento.md`
- [ ] O resto em lotes; qmd testado com um módulo (manter ou dispensar)

**Pronto quando:** uma pergunta sobre o curso volta com a resposta e a citação da aula certa.

## Fase 3 — Canais
- [ ] Sentinela (P10): timer confere VPS, serviços e site; em falha, `claude -p` em modo só leitura (`--permission-mode plan`) e alerta com causa e correção proposta; corrigir só com "sim"
- [ ] Google Agenda (se usar); skill do robô de transcrição

**Pronto quando:** "anota X" no Telegram aparece no inbox, e o briefing chega sem você fazer nada.

## Fase 4 — Negócio
- [ ] Links iCal; `/ocupacao` e depois a auditoria como script sem IA num timer (P6)
- [ ] Kit do anfitrião (P13): `perguntas-de-hospedes`, `persona-anfitriao`, `licoes`; avaliar gestor de reservas com API
- [ ] Primeira reserva com `/reserva`; primeira noite com `/poker-sessao`
- [ ] Hostinger MCP só leitura, depois do site no ar

**Pronto quando:** nenhuma reserva fica sem bloqueio nos outros canais.

## Depois
- Escrita nos repositórios dos robôs (deploy key com write) — só se a proteção da `main` estiver resolvida.
- Segundo agente (ex.: desenvolvedor do site): nota diária compartilhada, escrita por pasta via `permissions.deny`.
- App próprio do Jarvis (ideia, não decidida).
