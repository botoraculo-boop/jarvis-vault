---
tipo: procedimento
gatilho: "/consultar", ou uma pergunta sobre resultados do Oráculo ou do Miner
---

# Análise de dados do projeto

## Leia antes
- A nota do projeto: [[oraculo]] ou [[the-miner]].
- No clone do repositório (`~/repos/<projeto>`): o `CLAUDE.md` (Oráculo) ou o `PROJETO.md` (Miner), e no Oráculo a seção de estudos do `CLAUDE.md` e o `docs/03-estudos.md` quando a pergunta for de método.
- [[licoes]] do projeto.

## Passos
1. Reescreva a pergunta numa frase com o recorte (período, liga/moeda, estratégia, modo).
2. Abra o espelho em **modo só leitura**: `sqlite3 'file:/home/jarvis/dados/oraculo.db?mode=ro'` ou, em Python, `sqlite3.connect('file:...?mode=ro', uri=True)`. Nunca o banco de produção.
3. Confira a data do espelho (`ls -l ~/dados` ou a linha em `~/dados/espelho.log`) e diga qual é.
4. Conte o tamanho da amostra antes do resultado. Amostra pequena: diga.
5. **Oráculo:** siga o método obrigatório do repositório (gols depois ÷ M2, bootstrap por jogo, IC 90%, escolher com 2023-25, provar com 2026 só no fim). **Miner:** separe por `modo` (testnet ≠ simulação ≠ real) e diga em R e em US$.
6. Responda: o número, o intervalo, a amostra, a data dos dados e o que **não** dá para concluir.
7. Se virar proposta de mudança no robô: conferência independente (um subagente refaz a conta sem ver a sua) antes de propor; e grave em [[decisoes]] como **Proposta**.

## Pausa obrigatória
Nenhum ajuste no robô. A análise sugere; quem muda é você (ou os donos, no Oráculo).

## Pegadinhas
- Em pandas, montar filtros e máscaras depois de ordenar e reindexar.
- Profecias do Oráculo não se cortam só pela régua M2 (regra do repositório).
