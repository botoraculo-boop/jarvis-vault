---
tipo: procedimento
gatilho: "/versao"
---

# Preparar versão nova

## Leia antes
- O `CLAUDE.md`/`PROJETO.md` do repositório — as regras de versão de cada projeto mandam (no Oráculo: numeração mística combinada com você, todos os arquivos onde a versão aparece, a ficha em `docs/versoes/`, a linha em `docs/05-versoes.md`, decisões D-NN, testes).
- [[licoes]] do projeto.

## Passos
1. `git -C ~/repos/<projeto> fetch origin main` e crie o ramo `jarvis/<versao>-<assunto>` a partir de `origin/main`.
2. Faça a mudança pedida, com os testes que o projeto manda rodar (em segundo plano, com `nohup`, se passar de 2 min).
3. Documente como o projeto manda.
4. Commit local. Mostre: o resumo, os testes, o diff por arquivo.

## Pausa obrigatória
O Jarvis não envia ao GitHub. Ele entrega o *bundle* e o texto do PR em `~/repos/entregas/`; você publica (PR e merge são seus). Instalar é o botão ATUALIZAR (ou a receita, com "Permitir").
