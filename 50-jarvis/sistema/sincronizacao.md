---
tipo: runbook
atualizado: 2026-10-30
---

# Sincronização do vault (Git, opção B)

- **VPS:** a cada resposta do Jarvis, commit local (hook `autocommit.sh`). A cada 10 min, `git-sync.sh`: commit do que sobrou, `fetch`, `rebase` em cima do GitHub, `push` na `main`.
- **PC:** plugin Obsidian Git (puxar e enviar a cada 10 min) ou `git pull` / `git push`.
- **Celular:** leitura.

## Conflito
Acontece se você e o Jarvis mudarem a mesma linha da mesma nota em menos de 10 minutos. O VPS guarda o trabalho dele no ramo `vps-conflito`, avisa (Telegram e começo de sessão) e continua trabalhando; nada se perde. Para resolver, no PC, na pasta do vault:
```powershell
git pull
git merge origin/vps-conflito
```
Abra os arquivos que o Git listar, escolha o texto certo entre `<<<<<<<` e `>>>>>>>`, apague as marcas e:
```powershell
git add -A
git commit --no-edit
git push
```
Em até 10 minutos o VPS percebe que o `vps-conflito` entrou na `main`, reaplica só o que fez depois e volta ao normal (avisa "conflito resolvido").

## Desfazer
Toda mudança tem commit: `git log --oneline -- <arquivo>` e `git restore --source <commit> -- <arquivo>`.
