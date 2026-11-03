---
tipo: licoes
atualizado: 2026-11-03
---

# Lições

O que deu errado (ou certo por pouco) e o que fazer da próxima vez. Uma seção por projeto; lida no priming de qualquer trabalho nele. Formato: `data — o que aconteceu — regra que fica`.

## Jarvis
- 2026-10-30 — O `JARVIS-vault.zip` de 29–30/10 sumiu do PC e o kit teve de ser refeito. — Entregável importante vai para a pasta `C:\Users\Naldim\Claude` e para o GitHub no mesmo dia.
- 2026-10-30 — Dentro do sandbox do Claude Code o `sudo` não deve funcionar (o bubblewrap liga o *no_new_privs*; a documentação do Claude Code não fala disso — confirmar no teste de aceitação). — Receitas de root passam pelo comando `receita`, que fica fora do sandbox por configuração (ver [[receitas]]).
- 2026-10-30 — A revisão independente dos scripts de root achou 3 falhas críticas antes da instalação (Python carregando módulo da pasta de quem chamou; espelho dentro da casa do `jarvis`; instalador lido do vault). — Script que roda como root: revisão por um agente separado antes de instalar, sempre; root nunca escreve nem lê caminho que o `jarvis` controla.
- 2026-10-30 — Reaplicar o `settings-usuario.json` por cima do `~/.claude/settings.json` apagou o registro dos plugins ligados, e o Telegram parou de receber. — O modelo do kit agora traz `enabledPlugins`; plugin novo instalado no VPS entra também no modelo, senão some na próxima reaplicação.
- 2026-10-30 — Confirmado na prática: dentro do sandbox o `sudo` falha ("no new privileges"). — A receita só funciona pela regra `excludedCommands`; conferir no teste de aceitação.
- 2026-10-30 — A chave do vault foi cadastrada no GitHub sem "Allow write access" e a sincronização falhou em silêncio por 1 h. — Depois de cadastrar chave, rodar `systemctl start jarvis-git` e ler o log.
- 2026-10-30 — No modo Manual, o Capi pedia Permitir para cada consulta e cada resposta no Telegram; inviável. — Sessões no modo automático; só as receitas que mudam algo pedem Permitir.

- 2026-11-01 — O Capi ficou sem o plugin do Telegram das 04:30 às 14:20: a sessão subiu no reinício diário sem abrir o plugin (bug conhecido do Claude Code). — Vigia automático: `jarvis-vigia.timer` (a cada 5 min) reinicia o bot que ficar ~10 min sem plugin e avisa no Telegram; até 3 reinícios por bot em 3 h (ver [[servicos]]).
- 2026-11-02 — O Audion (Malt), rodando 5 h seguidas só com `nice 19`, coincidiu com um steal de 50–70% e o site do Miner caiu; voltou ao pausar. — Trabalho pesado de longa duração na VPS só com teto fixo (CPUQuota, MemoryMax). Antes de ligar, medir o steal (`vmstat`) e o CPU por serviço (`/sys/fs/cgroup/system.slice/*/cpu.stat`).
- 2026-11-02 — Malt afirmou ao Mestre que o steal alto era "contenção no host" (porque seguia alto com o Audion parado). A Hostinger mostrou que era o **limite de CPU** que ela aplica depois de horas de uso ~95% (Miner + Audion); o limite aparece como steal e continua depois que a carga cai. A remoção do limite só pode ser feita 1 vez a cada 7 dias. — Steal alto numa VPS da Hostinger: primeiro suspeitar do limite de CPU (conferir no hPanel ou no suporte), não de vizinho. Não afirmar a causa sem a confirmação do provedor. Uso sustentado na VPS (Miner + robôs) tem de ficar bem abaixo de 100%.

- 2026-11-03 — Malt deixou um subagente rodar mais de 3 h de testes pesados na VPS (as suítes do Miner 0.9.9 e 0.9.10, com nice 19), junto com o Miner e o Audion, sem medir o steal. À noite, o steal estava em 36–44% e o painel do Miner não abria; a lição de 02/11 já mandava medir antes. — Teste pesado ou longo não roda na VPS de produção: só fora dela (no PC) ou com teto fixo (`systemd-run --scope -p CPUQuota=`) e medindo o steal a cada 15 min. Nice 19 não basta, porque a Hostinger limita pelo uso total.

## Oráculo
- 2026-10-22 — O ambiente do Claude reiniciou e levou commits que não tinham sido entregues. — Entregar (bundle/push) ao fim de cada etapa, não só no fim do dia.

## The Miner
- 2026-11-01 — Malt somou os trades do modo demo (mercado inventado, datas aceleradas até 14/11) no relatório do dia e o chamou de "ponto fraco". — Antes de analisar o miner.db, ler no PROJETO.md/código o que cada modo é; filtrar `modo != 'demo'`.

## Mar & Lago
