---
name: voz
description: Conversa por voz pelo Telegram — transcreve o áudio que ele mandou (Whisper local) e, quando a mensagem veio em áudio, responde também em voz (ElevenLabs) além do texto. Use sempre que chegar uma mensagem de voz ou um arquivo de áudio, ou quando ele pedir "responde em áudio".
---

# /voz

## Entrada (ele mandou áudio)
1. Ache o caminho do arquivo de áudio que chegou com a mensagem (o canal do Telegram informa o anexo).
2. Transcreva: `~/.local/whisper/bin/python .claude/skills/voz/scripts/transcrever.py <arquivo>` (leva de 10 s a 1 min).
3. Trate o texto transcrito como a mensagem dele. Ditado erra: "chip" = tip; nome estranho → pergunte antes de agir. Se a transcrição pedir algo que muda alguma coisa (receita, mensagem, apagar), repita em texto o que entendeu e espere o "sim".
4. Sem áudio no anexo ou erro na transcrição: diga em texto e peça para repetir digitado.

## Saída (responder em voz)
Só quando a mensagem dele veio em áudio, ou ele pediu áudio.
1. Responda primeiro em **texto**, completo, como sempre (números, comandos e decisões ficam escritos).
2. Escreva um **resumo falado** de até 600 caracteres em `.fala/AAAAMMDD-HHMMSS.txt` na raiz do vault: frases curtas, sem tabela, sem Markdown, sem link, números arredondados ("mais ou menos dois e meio por cento").
3. **Nunca** coloque na fala: link, chave, senha, link iCal, telefone, documento, chave Pix, nome completo de hóspede ou de jogador. O texto da fala vai para os servidores da ElevenLabs.
4. Um script fora do Claude transforma em voz e manda no seu Telegram em alguns segundos. Você não precisa fazer mais nada; não confirme o envio.
