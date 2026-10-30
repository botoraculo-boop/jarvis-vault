---
name: versao
description: Prepara uma versão nova do Oráculo ou do The Miner num ramo próprio do clone em ~/repos, com testes e documentação, e entrega um bundle para ele publicar. Use com "/versao <projeto> <o que mudar>".
---

# /versao <projeto> <pedido>

Siga `40-procedimentos/preparar-versao.md` e as regras de versão do repositório (que mandam sobre as daqui).
1. `cd ~/repos/<oraculo|theminer>`; `git status` limpo; `git fetch origin main`; `git switch -c jarvis/<versao>-<assunto> origin/main`.
2. No Oráculo, o número da versão se combina com ele ("numeração mística") — pergunte antes de escrever.
3. Mude o código; rode os testes que o projeto manda (longos: `nohup ... &` e acompanhe o log).
4. Documente (Oráculo: ficha `docs/versoes/X.YY.md`, linha em `docs/05-versoes.md`, D-NN em `docs/decisoes.md`; Miner: `NOVIDADES.md`).
5. Commit local. Mostre o resumo, os testes e o diff.
6. Entrega: `mkdir -p ~/repos/entregas && git bundle create ~/repos/entregas/<repo>-<versao>.bundle origin/main..<ramo>` e o texto do Pull Request em `~/repos/entregas/<repo>-<versao>-PR.md`. Você não faz `git push` (é negado). Ele pega os arquivos pelo Claude desktop (SSH) e publica como já faz no Oráculo (bundle + texto no chat do repositório → PR → merge). Instalar é o botão ATUALIZAR (ou a receita, com "Permitir").
