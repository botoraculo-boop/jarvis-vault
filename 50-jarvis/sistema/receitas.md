---
tipo: runbook
atualizado: 2026-10-30
---

# Receitas (o porteiro)

**O que é:** o único caminho do Jarvis até a produção. Um script de dono root, `/opt/jarvis/bin/receita` (fonte: `vps/bin/receita`), que o `jarvis` pode rodar com `sudo` e mais nada (`/etc/sudoers.d/jarvis`).

**Como o Capi chama:** pelas ferramentas do conector `receitas` (`mcp__receitas__status`, `reiniciar`, ...), um programa de dono root (`/opt/jarvis/bin/mcp-receitas.py`, fonte `vps/bin/mcp-receitas.py`) que só sabe rodar `sudo -n /opt/jarvis/bin/receita <nome>` com os nomes e argumentos da lista. Por quê: os comandos de terminal do Claude rodam no sandbox, que liga o *no new privileges* e impede o `sudo` (confirmado em 30/10); a regra `excludedCommands`, que deveria tirar a receita do sandbox, não funcionou. O conector roda fora desse sandbox, como o do Telegram. `status`, `logs`, `fotos` e `ajuda` são livres; as outras pedem **Permitir**. O `sudo` pelo terminal é negado de vez.

| Receita | Faz | Foto antes | Desfaz |
|---|---|---|---|
| `status` | serviços, versões, memória, disco, espelho, fotos | — | — |
| `logs <alvo> [n]` | journal do serviço (até 300 linhas) | — | — |
| `fotos` | lista as fotos | — | — |
| `espelho` | atualiza o espelho agora | — | — |
| `backup <oraculo\|miner>` | cópia do banco em `/var/lib/jarvis/backups` (7 dias) | — | — |
| `reiniciar <oraculo\|miner>` | `systemctl restart` | sim | não há o que desfazer |
| `atualizar-oraculo <versão> <commit>` | escreve o pedido ao atualizador do Oráculo — o mesmo do botão ATUALIZAR, que confere se o commit está na `main`, guarda a versão anterior e volta sozinho se a nova não subir | sim (com cópia do banco) | volta para a versão da foto rodando o `atualizar.sh` guardado em `/var/lib/oraculo/versoes/` (o mesmo caminho da volta automática); o banco não é trocado |
| `atualizar-miner` | toca o pedido do atualizador do Miner — o mesmo do botão do painel (testes, cópia em `/opt/miner-backups`, volta sozinho) | sim | descompacta a cópia da versão da foto, mantendo `.env`, `dados/` e `.venv` (o mesmo caminho da volta automática) |
| `desfazer [id]` | volta a última foto de mudança (ou a escolhida) | sim | — |
| `parar-jarvis` | **kill switch**: para as sessões, os timers (briefing, revisão, sincronização) e mata todo processo do `jarvis` | sim | `ligar-jarvis` (ou `desfazer`) |
| `ligar-jarvis` | liga de novo | — | — |

**Fotos:** `/var/lib/jarvis/fotos/<data>-<receita>/` com `meta.json` (receita, alvo, motivo, versões, quem), o status dos serviços e uma cópia do banco do alvo (só nas 3 fotos mais novas; ficam as 15 mais novas). A cópia do banco é para volta manual, com você: o `desfazer` não restaura banco, porque isso apagaria o que os robôs gravaram depois.

**Log:** `/var/log/jarvis-receitas.log` e `journalctl -t jarvis-receita`.

**Proteções do próprio script:** roda a partir de `/` e com `python3 -I` (não carrega nada da pasta de quem chamou); argumentos conferidos por lista e por padrão; se a foto não for gravada, a mudança não acontece; a volta do Miner confere a cópia antes de apagar o código e religa o robô se a extração falhar.

**Atenção:** `logs` é livre e mostra o journal dos robôs. Se um deles imprimir um segredo num erro, o Jarvis vê. Se isso acontecer, troque a chave.

**Receita nova:** o Jarvis propõe (o que faz, por quê, como desfaz, o trecho de código), você aprova, edita `vps/bin/receita` no PC e roda o passo 7 do [[vps]]. Shell de root sem limite: não.

**Kill switch sem IA:** a chave SSH do celular com `command="sudo -n /opt/jarvis/bin/receita parar-jarvis",restrict` ([[vps]], passo 8).
