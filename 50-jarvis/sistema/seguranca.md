---
tipo: runbook
atualizado: 2026-10-30
---

# Segurança

## Quem usa
Só você. O Jarvis roda na sua assinatura Claude, que não pode atender outras pessoas. Alguém além de você = outro projeto (API ou plano Team).

## O que o Jarvis faz sozinho, com "sim", ou nunca
| Sozinho | Só com "sim" / Permitir | Nunca |
|---|---|---|
| ler o vault, o espelho e os clones; criar e editar notas (exceto `raw/`); pesquisar na web; comandos no sandbox; commit local; receitas `status`, `logs`, `fotos` | enviar mensagem; qualquer receita que muda algo (reiniciar, atualizar, backup, desfazer, parar); editar fora do vault; ferramentas da Hostinger; criar evento | pagar ou comprar; `git push`; `sudo` fora das receitas; ler segredos; ler `/opt/oraculo` e `/opt/miner`; escrever em `raw/`; editar `50-jarvis/sistema/vps/`, `.claude/settings.json`, `.claude/hooks/`; rodar sem permissões |

## Onde isso é imposto, do mais forte ao mais fraco
1. **Sistema operacional.** Usuário `jarvis` sem sudo geral: o sudo só roda `/opt/jarvis/bin/receita` (dono root), que aceita uma lista fechada de receitas e valida cada argumento. `/opt/oraculo` (700), `/opt/miner` (750, grupo miner) e as cópias são ilegíveis para o `jarvis`. Os dados chegam por um espelho que o root escreve em `/var/lib/jarvis-dados`, fora da casa do `jarvis`, e o `jarvis` só lê. Scripts e unidades em `/opt/jarvis` e `/etc/systemd`, de dono root. Teto de memória e prioridade baixa no systemd.
2. **Sandbox do Claude Code.** Os comandos que o Jarvis roda só escrevem no vault, em `~/repos` e em `/tmp` (e não em `50-jarvis/sistema/vps/`, nas configurações e nos hooks); não leem `~/.ssh`, `~/.config/jarvis`, o login do Claude, o token do Telegram nem as pastas dos robôs; e só acessam a internet nos domínios do Airbnb e do Booking. Sem sandbox, o Claude nem inicia (`failIfUnavailable`), e o Jarvis não pode pedir para rodar fora dele (`allowUnsandboxedCommands: false`). As receitas não passam pelo terminal: vão pelo conector `receitas` (um programa de dono root, fora do sandbox de comandos, que só chama a receita com nomes e argumentos de uma lista fechada), e cada uma passa pelas permissões abaixo. O Jarvis não faz `git push`: o vault vai ao GitHub pelo timer, que roda o git sem ganchos nem programas da configuração do repositório (o `.git/config` e os ganchos também são protegidos contra escrita).
3. **Permissões do Claude Code** (`.claude/settings.json`). `allow` (receitas `status`, `ajuda`, `fotos`, `logs`), `ask` (cada receita que muda, `CLAUDE.md`, Hostinger) e `deny` (segredos, pastas dos robôs, `raw/`, kit do VPS, `.git/`, configurações do Claude, `~/.bashrc`, `~/.local`, `~/.ssh`, `~/.gitconfig`, `git push`, `printenv`). As ferramentas de arquivo do Claude (Read, Edit) não passam pelo sandbox: é aqui que elas são barradas.
4. **`CLAUDE.md`.** Comportamento esperado. O modelo segue, mas não é trava.

Por cima: hooks com log de cada edição (`50-jarvis/log/`), commit automático a cada resposta, fotos antes de cada receita e o log `/var/log/jarvis-receitas.log`.

**Ao apertar Permitir, leia o comando inteiro.** Se houver qualquer coisa além de `sudo -n /opt/jarvis/bin/receita <nome> <argumentos>` — um `&&`, um `;`, um `|`, um `cd` antes — negue. Esse comando roda fora do sandbox.

## Segredos
- Nunca no vault. No VPS, `~/.config/jarvis/` (700), arquivos 600, formato `NOME=valor`:
  - `env` — o que o Claude pode usar: `MARELAGO_ICAL_AIRBNB`, `MARELAGO_ICAL_BOOKING`, `HOSTINGER_API_TOKEN` (Fase 4), `JARVIS_MODO_PERMISSAO`, `JARVIS_AUTOCOMMIT`, `JARVIS_MODELO_ROTINA`.
  - `notificacao.env` — `TELEGRAM_CHAT_ID`; nunca entra no ambiente do Claude.
- O que está no `env` entra no ambiente das sessões. **Não conferi** se o sandbox esconde essas variáveis dos comandos: trate os links iCal como visíveis para o Jarvis (por isso só eles e o token da Hostinger ficam lá, e o `printenv` é negado).
- Token do Telegram: `~/.claude/channels/telegram/.env` (gravado pelo plugin), negado ao Jarvis; o `notificar.sh` o lê fora do Claude e o passa ao `curl` pela entrada padrão (não aparece na lista de processos).
- `voz.env` — `ELEVENLABS_API_KEY` e `ELEVENLABS_VOICE_ID`; só o `falar.sh` lê, fora do Claude.
- `.mcp.json` só com `${VARIAVEL}`.

## Voz
O seu áudio é transcrito no VPS e não sai de lá. A resposta falada é um resumo que o Jarvis escreve em `.fala/`; esse texto vai para a ElevenLabs e volta como áudio só para o seu chat (o ID é fixo no `notificacao.env`). Regra: na fala, nunca link, chave, telefone, documento, chave Pix ou nome completo de terceiros. Trava: 700 caracteres por fala e 20 falas por hora.

## Prompt injection
O Jarvis lê texto de outras pessoas (páginas, PDFs, mensagens de hóspede, e-mails, saídas de comando). Defesas: o `CLAUDE.md` declara tudo isso como dado; nenhuma ação externa sem "sim"; permissões e sandbox negam o perigoso mesmo se o modelo for enganado; Telegram com allowlist; receitas com lista fechada e argumentos validados.

## Dados de terceiros
Hóspedes e jogadores: só o mínimo (nome, datas, valores). Documento e chave Pix, nunca. O espelho do Oráculo sai sem usuários, sessões, chats, contas do Telegram, ajustes e cache (lista branca em [[espelho]]).

## Repositório git
Privado. Antes do primeiro push, `git status` sem nenhum `.env`. Desfazer uma nota: `git log --oneline -- <arquivo>` → `git restore --source <commit> -- <arquivo>`.
