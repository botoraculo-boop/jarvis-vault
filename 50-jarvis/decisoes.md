---
tipo: decisoes
atualizado: 2026-10-31
---

# Decisões

Formato: data — decisão — porquê. **Proposta** = sugestão do Jarvis esperando o seu "sim"; vira decisão quando você confirma (ou sai daqui quando você recusa). Decisão não se apaga: revogada ganha "(revogada em DATA: ...)".

## Mar & Lago / site
- 2026-10 — Sem sincronização automática com Airbnb/Booking: reserva pelo site → a família bloqueia as datas à mão nos outros canais.
- 2026-10 — Sem pagamento online por enquanto: o hóspede reserva e a família cobra o Pix pelo WhatsApp.
- 2026-10 — O site fica no VPS da Hostinger que já existe, em link separado, sem mexer nos outros programas.

## Sistema Jarvis
- 2026-10-30 — As receitas passam a ser chamadas por um conector próprio (`mcp-receitas.py`, dono root), não pelo terminal. Porquê: o `sudo` não roda dentro do sandbox (confirmado) e a regra `excludedCommands` não funcionou nessa configuração. Substitui a proposta de "receita fora do sandbox por excludedCommands".
- 2026-10-30 — O assistente se chama **Capi** em tudo que fala com você (app, Telegram, voz). "Jarvis" fica como nome do sistema: usuário, pastas, serviços e notas técnicas não mudam. Porquê: escolha sua; trocar o nome do sistema quebraria caminhos sem ganho.
- 2026-10-31 — Tratamento: o Capi nunca chama você pelo nome; chama de **Mestre**, em texto e em voz. Porquê: pedido seu (regra permanente).
- 2026-10-30 — Voz já na instalação, sem esperar a semana de uso (mudança pedida por você: o roadmap mandava esperar). Ida: Whisper local no VPS. Volta: ElevenLabs, plano grátis, só quando a mensagem veio em áudio ou você pedir, sempre com o texto junto. Porquê: você quer testar a conversa por voz já. O Telegram sobe junto, porque é por ele que a voz vai e volta. (alterada em 2026-10-31: ver modo teste da voz)
- 2026-10-30 — **Proposta (montagem do kit):** o porteiro usa `sudo` restrito a um arquivo só (`/opt/jarvis/bin/receita`), e esse comando roda fora do sandbox por configuração (`excludedCommands`), com Permitir para tudo que muda algo. Porquê: dentro do sandbox (bubblewrap) o `sudo` não funciona — deduzido do funcionamento do bubblewrap, a confirmar no teste de aceitação. Alternativa descartada: fila de pedidos vigiada pelo systemd, porque o Jarvis conseguiria escrever o pedido sem passar pelo Permitir.
- 2026-10-30 — **Proposta (montagem do kit):** o espelho grava em `/var/lib/jarvis-dados` (fora da casa do `jarvis`), e o instalador roda de uma cópia do root. Porquê: a revisão de segurança mostrou que, com a pasta dentro da casa dele, o `jarvis` poderia plantar atalhos que o root seguiria (ler a chave do Miner, sobrescrever o banco do Oráculo).
- 2026-10-30 — **Proposta (montagem do kit):** o espelho usa **lista branca** de tabelas, não lista negra. Porquê: tabela de contas que surgir numa versão nova dos robôs fica de fora sozinha; o log avisa para você decidir.
- 2026-10-30 — **Proposta (montagem do kit):** o Jarvis **não faz `git push`**; deploy keys só de leitura nos repositórios do Oráculo e do Miner; a versão nova sai como *bundle* em `~/repos/entregas/` e você publica. Porquê: proteger a `main` de repositório privado exige plano pago do GitHub, e um push aprovado roda fora do sandbox, onde a configuração do git pode esconder código (achado da revisão de segurança). O vault vai ao GitHub só pelo timer.
- 2026-10-30 — **Proposta (montagem do kit):** kill switch por uma chave SSH do celular presa ao comando `receita parar-jarvis`, em vez de comando no Telegram. Porquê: o Telegram passa pelo próprio Jarvis (IA no caminho do botão de emergência) e o token do bot já é usado pelo canal.
- 2026-10-30 — **Proposta (montagem do kit):** procedimentos em `40-procedimentos/` (pasta numerada, na raiz). Porquê: segue a numeração do vault e fica à vista no Obsidian.
- 2026-10-30 — Aceito o estudo do canal jaredrhod ([[estudo-jaredrhod-plano]]), propostas P1 a P5: índices em três níveis; nota diária com índice + `/checkpoint`; regras novas no `CLAUDE.md`; pasta de procedimentos; importação da memória consolidada em uma nota por assunto. Não adotados: o instalador `fullstack-agent`, voz, visualizador, barehands e o redirecionamento do `MEMORY.md`.
- 2026-10-30 — Aceitas P6 a P13: automação sem IA quando for só conta; `/entrevista`; conhecimento compartilhado em `30-conhecimento/`; kill switch; sentinela com diagnóstico só leitura; runbook e lições; boot e checkpoint reforçados; kit do anfitrião. Fica de fora: correção automática sem aprovação e mensagem a hóspede sem revisão.
- 2026-10-30 — P14 aceita: espelho só de leitura dos bancos do Oráculo e do Miner, sem dados de contas. O Jarvis é o secretário dos dois projetos, sem acesso à produção. Porquê: precisa dos dados para ser útil, e os robôs (um com chave de corretora) não podem ficar ao alcance de um agente.
- 2026-10-30 — Acesso ao VPS pelo modelo do porteiro, não root total: ações na produção por receitas com Permitir no celular, foto antes de cada mudança e `desfazer`. Porquê: o VPS guarda chave de corretora e dados de usuários.
- 2026-10-30 — Regras novas do `CLAUDE.md`: só afirmar o conferido; auditoria completa; consolidar em vez de acumular; uma pergunta por vez; conferir a data; decisão registrada só muda com aviso; nunca escrever segredo em nota.
- 2026-10-30 — O Jarvis é pessoal: só você usa. Porquê: assinatura Claude é individual.
- 2026-10-30 — O Jarvis roda no VPS. Porquê: sempre ligado, sem depender do PC.
- 2026-10-30 — Sync pelo Git (GitHub privado), com o Obsidian do celular para leitura. Porquê: grátis e leva tudo, inclusive a `.claude/`. Troca para o Obsidian Sync se editar no celular fizer falta.
- 2026-10-30 — Pasta única do Claude no PC: `C:\Users\Naldim\Claude` (fora do OneDrive).
- 2026-10-30 — **Proposta:** acesso principal pelo app Claude (Remote Control); Telegram como canal rápido; Claude desktop por SSH para trabalho longo. Porquê: Remote Control é estável e permite aprovar pelo celular; Channels ainda é prévia.
- 2026-10-30 — **Proposta:** usuário `jarvis` sem sudo geral, sandbox obrigatório, teto de memória e scripts de dono root. Porquê: o mesmo VPS roda o Oráculo e o Miner.
- 2026-10-29 — **Proposta:** o vault é a única fonte da verdade; auto memory do Claude Code desligada.
- 2026-10-29 — **Proposta:** o Claude Code é o único motor de IA; nenhum plugin de IA dentro do Obsidian.
- 2026-10-29 — **Proposta:** WhatsApp fora como interface; o canal é o Telegram.
- 2026-10-29 — **Proposta:** segredos nunca no vault.
- 2026-10-29 — **Proposta:** commit automático a cada resposta do Jarvis (desligável com `JARVIS_AUTOCOMMIT=0`).
- 2026-10-29 — **Proposta:** `/ocupacao` audita os iCals (só leitura) para confirmar os bloqueios manuais.
- 2026-10-31 — Modo teste da voz; trocar por modo melhor depois. Áudio só em resposta a áudio; fala de até ~15 s com a resposta direta; texto depois só com o detalhe que não coube, sem repetir. Porquê: economizar créditos da ElevenLabs. Muda em parte a decisão de 30/10 sobre voz ("sempre com o texto junto").
