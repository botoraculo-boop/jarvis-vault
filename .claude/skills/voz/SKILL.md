---
name: voz
description: Conversa por voz pelo Telegram — transcreve o áudio que ele mandou (Whisper local) e, quando a mensagem veio em áudio, responde em voz (ElevenLabs) para o mesmo chat. Use sempre que chegar uma mensagem de voz ou um arquivo de áudio, ou quando ele pedir "responde em áudio".
---

# /voz

## Entrada (ele mandou áudio)
1. Ache o caminho do arquivo de áudio que chegou com a mensagem (o canal do Telegram informa o anexo).
2. Transcreva: `~/.local/whisper/bin/python .claude/skills/voz/scripts/transcrever.py <arquivo>` (leva de 10 s a 1 min).
3. Trate o texto transcrito como a mensagem dele. Ditado erra: "chip" = tip; nome estranho → pergunte antes de agir. Se a transcrição pedir algo que muda alguma coisa (receita, mensagem, apagar), repita em texto o que entendeu e espere o "sim".
4. Sem áudio no anexo ou erro na transcrição: diga em texto e peça para repetir digitado.

## Saída (responder em voz) — modo teste, desde 31/10/2026
Só quando a mensagem dele veio em áudio, ou ele pediu áudio. Pergunta em texto → resposta só em texto.
1. Escreva a **fala**: a resposta direta, até uns 15 segundos (≈250 caracteres). Frases curtas, sem tabela, sem Markdown, sem link, números arredondados ("mais ou menos dois e meio por cento").
2. Grave em `.fala/` na raiz do vault, com o `chat_id` da mensagem do Telegram no começo do nome: `.fala/<chat_id>--AAAAMMDD-HHMMSS.txt` (ex.: `.fala/7557488338--20261031-124500.txt`). É assim que a voz volta para a conta que perguntou. Sem `chat_id` (pedido pelo app), grave sem prefixo: `.fala/AAAAMMDD-HHMMSS.txt` — vai para o chat principal.
3. Depois, em **texto**, só o que não coube na fala (números, nomes, comandos), sem repetir o que a fala disse.
4. **Nunca** coloque na fala: link, chave, senha, link iCal, telefone, documento, chave Pix, nome completo de hóspede ou de jogador. O texto da fala vai para os servidores da ElevenLabs.
5. Um script fora do Claude transforma em voz e manda no Telegram em alguns segundos. Ele só aceita as contas da lista branca; qualquer outro ID vai para o principal. Você não precisa fazer mais nada; não confirme o envio.
