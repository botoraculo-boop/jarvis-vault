---
tipo: licoes
atualizado: 2026-10-30
---

# Lições

O que deu errado (ou certo por pouco) e o que fazer da próxima vez. Uma seção por projeto; lida no priming de qualquer trabalho nele. Formato: `data — o que aconteceu — regra que fica`.

## Jarvis
- 2026-10-30 — O `JARVIS-vault.zip` de 29–30/10 sumiu do PC e o kit teve de ser refeito. — Entregável importante vai para a pasta `C:\Users\Naldim\Claude` e para o GitHub no mesmo dia.
- 2026-10-30 — Dentro do sandbox do Claude Code o `sudo` não deve funcionar (o bubblewrap liga o *no_new_privs*; a documentação do Claude Code não fala disso — confirmar no teste de aceitação). — Receitas de root passam pelo comando `receita`, que fica fora do sandbox por configuração (ver [[receitas]]).
- 2026-10-30 — A revisão independente dos scripts de root achou 3 falhas críticas antes da instalação (Python carregando módulo da pasta de quem chamou; espelho dentro da casa do `jarvis`; instalador lido do vault). — Script que roda como root: revisão por um agente separado antes de instalar, sempre; root nunca escreve nem lê caminho que o `jarvis` controla.

## Oráculo
- 2026-10-22 — O ambiente do Claude reiniciou e levou commits que não tinham sido entregues. — Entregar (bundle/push) ao fim de cada etapa, não só no fim do dia.

## The Miner

## Mar & Lago
