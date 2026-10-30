---
name: capturar
description: Guarda rápido uma ideia, tarefa, link ou arquivo no inbox para o /inbox integrar depois. Use para "anota", "lembra de", "guarda isso", mensagens curtas do Telegram e fotos/arquivos mandados sem contexto.
---

# /capturar

1. `date`. Crie `00-inbox/AAAA-MM-DD-HHMM-<3-palavras>.md` com:
   ```
   ---
   tipo: captura
   capturado: AAAA-MM-DD HH:MM
   origem: telegram | app | web
   ---
   <o texto como veio>
   ```
   Arquivo ou foto: salve ao lado com o mesmo prefixo e faça o link na nota.
2. Link de página: guarde o link e o título; não baixe a página agora.
3. Responda em uma linha: "Anotado no inbox." Não organize agora — isso é do `/inbox`.
4. Exceção: se for claramente urgente e de hoje ("me lembra às 15h"), diga que o Jarvis não tem lembrete por horário ainda e sugira o alarme do celular.
