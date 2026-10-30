---
tipo: runbook
atualizado: 2026-10-30
---

# Jarvis no VPS — instalação

O Jarvis roda no VPS como o usuário `jarvis`, sem sudo geral, em sandbox, ao lado do Oráculo e do The Miner sem tocar neles. Você fala com ele pelo app Claude (Remote Control), pelo Claude desktop (SSH) e, depois, pelo Telegram. Só você usa.

**Leia antes de começar**
- Faça num dia calmo, com uma hora livre. Os passos 1–3 são no seu usuário root; 4–6 como `jarvis`; 7–9 de novo como root.
- Você entra hoje como root com senha. O passo 9 desliga isso — só depois de testar a chave.
- Se algo der errado no meio, o Oráculo e o Miner não são afetados: nenhum passo mexe neles (o passo 1 só confere).
- Onde rodar cada bloco: **[PC]** = PowerShell no Windows; **[VPS root]** = `ssh root@2.25.247.175`; **[VPS jarvis]** = `ssh jarvis@2.25.247.175`.

## Passo 1 — conferir o VPS [VPS root]
```bash
head -2 /etc/os-release                       # esperado: Ubuntu 24.04
free -h                                       # coluna "available": 6 GB ou mais é folgado
df -h /                                       # deixe 10 GB livres (espelho, fotos, Claude)
swapon --show                                 # vazio = sem swap (cria no passo 2)
sysctl kernel.apparmor_restrict_unprivileged_userns    # 1 no Ubuntu 24.04 (resolve no passo 2)
ls -ld /opt/oraculo /opt/miner /opt/miner-backups /var/lib/oraculo
```
Na última linha, o esperado é `drwx------` no Oráculo, nas cópias do Miner e no `/var/lib/oraculo`, e `drwxr-x---` no `/opt/miner` (grupo `miner`). Se alguma terminar em `r-x` ou `rwx` no fim (outros usuários podem ler), feche:
```bash
sudo chmod o-rwx /opt/oraculo /opt/miner /opt/miner-backups /var/lib/oraculo
```

## Passo 2 — swap, pacotes, usuário e sandbox [VPS root]
Swap de 4 GB (rede de segurança para a memória; sem ela, um pico mata processos):
```bash
fallocate -l 4G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
sysctl vm.swappiness=10 && echo 'vm.swappiness=10' > /etc/sysctl.d/99-swappiness.conf
```
Pacotes e o usuário:
```bash
apt-get update
apt-get install -y git tmux curl ca-certificates xz-utils unzip bubblewrap socat sqlite3
adduser --disabled-password --gecos "Jarvis" jarvis
chmod 750 /home/jarvis
```
O `apt-get update` só atualiza a lista; nada instalado é atualizado.

Liberar o sandbox (bubblewrap) no Ubuntu 24.04 — receita da documentação do Claude Code:
```bash
tee /etc/apparmor.d/bwrap > /dev/null <<'EOF'
abi <abi/4.0>,
include <tunables/global>

profile bwrap /usr/bin/bwrap flags=(unconfined) {
  userns,
  include if exists <local/bwrap>
}
EOF
systemctl reload apparmor
```

## Passo 3 — sua chave SSH no jarvis [PC] e [VPS root]
No PC, mostre a sua chave pública (se o arquivo não existir, crie antes com `ssh-keygen -t ed25519` e Enter em tudo):
```powershell
type $env:USERPROFILE\.ssh\id_ed25519.pub
```
No VPS, troque o texto entre aspas pela linha inteira que apareceu:
```bash
install -d -m 700 -o jarvis -g jarvis /home/jarvis/.ssh
echo "COLE-AQUI-A-SUA-CHAVE-PUBLICA" >> /home/jarvis/.ssh/authorized_keys
chown jarvis:jarvis /home/jarvis/.ssh/authorized_keys && chmod 600 /home/jarvis/.ssh/authorized_keys
```
Teste do PC: `ssh jarvis@2.25.247.175` tem de entrar sem senha.

## Passo 4 — ferramentas do jarvis [VPS jarvis]
```bash
curl -fsSL https://claude.ai/install.sh | bash        # Claude Code
curl -fsSL https://bun.sh/install | bash              # Bun: exigido pelo canal do Telegram

# Node 24 só na conta do jarvis (hooks, scripts, MCP), sem tocar no Node do sistema
ARQ=$(uname -m | sed 's/x86_64/x64/; s/aarch64/arm64/')
BASE=https://nodejs.org/dist/latest-v24.x
NOME=$(curl -fsSL "$BASE/SHASUMS256.txt" | awk -v fim="-linux-$ARQ.tar.xz" 'substr($2, length($2) - length(fim) + 1) == fim {print $2}' | head -1)
curl -fsSLO "$BASE/$NOME"
curl -fsSL "$BASE/SHASUMS256.txt" | grep " $NOME\$" | sha256sum -c -
mkdir -p ~/.local/node && tar -xJf "$NOME" -C ~/.local/node --strip-components=1 && rm "$NOME"

cat >> ~/.bashrc <<'EOF'
export PATH="$HOME/.local/bin:$HOME/.local/node/bin:$HOME/.bun/bin:$PATH"
[ -f ~/.config/jarvis/env ] && { set -a; . ~/.config/jarvis/env; set +a; }
EOF
source ~/.bashrc

mkdir -p ~/.config/jarvis && chmod 700 ~/.config/jarvis
install -m 600 /dev/null ~/.config/jarvis/env
install -m 600 /dev/null ~/.config/jarvis/notificacao.env
git config --global user.name "Jarvis (VPS)"
git config --global user.email "jarvis@localhost"
git config --global pull.rebase true

claude --version && node --version && bun --version
```
O `sha256sum` tem de dizer `OK`. Se não disser, pare.

## Passo 5 — chaves do GitHub, vault e repositórios [VPS jarvis] e GitHub
Uma chave por repositório (o GitHub não aceita a mesma chave de deploy em dois repositórios):
```bash
for r in vault oraculo theminer; do ssh-keygen -t ed25519 -C "jarvis-$r" -f ~/.ssh/github_$r -N ""; done
cat > ~/.ssh/config <<'EOF'
Host github-vault
  HostName github.com
  User git
  IdentityFile ~/.ssh/github_vault
  IdentitiesOnly yes
Host github-oraculo
  HostName github.com
  User git
  IdentityFile ~/.ssh/github_oraculo
  IdentitiesOnly yes
Host github-theminer
  HostName github.com
  User git
  IdentityFile ~/.ssh/github_theminer
  IdentitiesOnly yes
EOF
chmod 600 ~/.ssh/config
for r in vault oraculo theminer; do echo "== $r"; cat ~/.ssh/github_$r.pub; done
```
No GitHub, em cada repositório → **Settings → Deploy keys → Add deploy key**, cole a chave do mesmo nome:
- repositório **privado** do vault (crie vazio, sem README, se ainda não existe): chave `jarvis-vault`, **marque Allow write access**;
- `botoraculo-boop/oraculo`: chave `jarvis-oraculo`, **sem** write access;
- `botoraculo-boop/theminer`: chave `jarvis-theminer`, **sem** write access.

> **O que você talvez não queira ouvir:** o Jarvis **não envia nada ao GitHub**. Proteção de ramo (impedir push direto na `main`) em repositório **privado** exige plano pago do GitHub, e um `git push` aprovado roda fora do sandbox, onde dá para esconder código. Então: os repositórios dos robôs ficam só para leitura; o Jarvis prepara a versão num ramo local e entrega um *bundle* (como o Oráculo já faz hoje), e você publica. O vault vai ao GitHub pelo timer de sincronização, não pelo Jarvis.

Primeira vez: envie o vault do PC para o GitHub. [PC] — na pasta do vault (`C:\Users\Naldim\Claude\JARVIS`), com o Git for Windows instalado:
```powershell
git init -b main
git add -A
git commit -m "vault: estado inicial"
git remote add origin git@github.com:SEU-USUARIO/SEU-REPOSITORIO.git
git push -u origin main
```
(Se o PC ainda não tem chave no GitHub, use o GitHub Desktop: File → Add local repository → Publish repository, marcando **Private**.)

Então, no VPS [VPS jarvis]:
```bash
ssh -T git@github-vault                     # responda "yes"; a mensagem de "successfully authenticated" é o esperado
git clone git@github-vault:SEU-USUARIO/SEU-REPOSITORIO.git ~/JARVIS
git clone git@github-oraculo:botoraculo-boop/oraculo.git ~/repos/oraculo
git clone git@github-theminer:botoraculo-boop/theminer.git ~/repos/theminer
chmod +x ~/JARVIS/.claude/hooks/*.sh
```

## Passo 6 — Claude: login, configuração e plugins [VPS jarvis]
```bash
[ -f ~/.claude/settings.json ] && echo "Já existe ~/.claude/settings.json: me chame antes de continuar" \
  || install -D -m 600 ~/JARVIS/50-jarvis/sistema/vps/settings-usuario.json ~/.claude/settings.json
tmux new -s instalacao
cd ~/JARVIS
claude auth login
```
O `claude auth login` mostra um link: abra no navegador do PC, entre na sua conta e cole o código. Use este login, e não o `claude setup-token`: o token de longa duração não abre Remote Control.
```bash
claude
```
Aceite **confiar nesta pasta**. Dentro do Claude:
```
/sandbox
/plugin marketplace add kepano/obsidian-skills
/plugin install obsidian@obsidian-skills
/config
```
- `/sandbox` tem de mostrar o sandbox ligado, sem dependência faltando.
- No `/config`, ligue **Push when actions required**. No celular, permita as notificações do app Claude.
- Saia com `/exit`. Primeira vez do servidor do app:
```bash
claude remote-control --name Jarvis --spawn same-dir
```
Responda `y` ao que perguntar. Quando aparecer a URL da sessão, `Ctrl+C`. Saia do tmux com `exit` e da conta `jarvis` com `exit`.

## Passo 7 — serviços, receitas e espelho [VPS root]
```bash
install -m 700 /home/jarvis/JARVIS/50-jarvis/sistema/vps/instalar-servicos.sh /root/instalar-servicos.sh
less /root/instalar-servicos.sh            # leia (q para sair): é ele que vai rodar como root
bash /root/instalar-servicos.sh
```
Sempre rode a cópia do root, nunca o arquivo do vault (o `jarvis` consegue escrever no vault). O instalador copia o kit para uma pasta só do root, mostra a diferença **completa** e só instala com `sim`. Depois:
```bash
systemctl enable --now jarvis-espelho.timer && systemctl start jarvis-espelho.service
cat /var/lib/jarvis-dados/espelho.log       # oraculo.db, miner.db e estudo.db com "ok"
sudo -u jarvis sudo -n /opt/jarvis/bin/receita status
systemctl enable --now jarvis-remoto.service jarvis-briefing.timer jarvis-revisao.timer jarvis-reinicio.timer jarvis-git.timer
systemctl status jarvis-remoto --no-pager    # esperado: active (running)
```
Se o espelho mostrar "ATENÇÃO: tabela nova fora do espelho", me mande a linha: é uma tabela que o espelho ainda não conhece (fica de fora por segurança).

## Passo 8 — seus aparelhos
- **Celular:** app Claude → Code → sessão **Jarvis**.
- **PC:** app Claude desktop → aba Code → seletor de ambiente → New environment → SSH → `jarvis@2.25.247.175` → pasta `/home/jarvis/JARVIS`.
- **Obsidian:** no PC, o plugin **Obsidian Git** (puxa e envia a cada 10 min) na pasta do vault. No celular, só leitura (você pode usar o app do GitHub ou o Obsidian com o mesmo plugin).
- **Kill switch no celular (sem IA no caminho):** crie no celular uma chave SSH só para isso (no Android, o Termux com `ssh-keygen -t ed25519 -f ~/.ssh/parar_jarvis`; no iPhone, o app Atalhos → "Executar script por SSH" gera a chave) e cadastre-a assim [VPS root]:
  ```bash
  echo 'command="sudo -n /opt/jarvis/bin/receita parar-jarvis",restrict COLE-A-CHAVE-PUBLICA-DO-CELULAR' >> /home/jarvis/.ssh/authorized_keys
  ```
  Conectar com essa chave (`ssh -i ~/.ssh/parar_jarvis jarvis@2.25.247.175`) para o Jarvis na hora, faz só isso e mais nada. Para ligar de novo: [VPS root] `sudo -u jarvis sudo -n /opt/jarvis/bin/receita ligar-jarvis`.

## Passo 9 — fechar o root por senha [PC] e [VPS root]
Só depois de entrar como `jarvis` pela chave (passo 3). Primeiro, a sua chave também no root:
```bash
install -d -m 700 /root/.ssh
cat /home/jarvis/.ssh/authorized_keys | grep -v '^command=' >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
```
Abra **outro** PowerShell e teste `ssh root@2.25.247.175`: tem de entrar sem pedir senha. Só então:
```bash
printf 'PermitRootLogin prohibit-password\nPasswordAuthentication no\nKbdInteractiveAuthentication no\n' > /etc/ssh/sshd_config.d/10-jarvis.conf
sshd -t && systemctl reload ssh
```
Não feche a janela antiga até testar de novo numa nova. Se algo der errado, o terminal do navegador do hPanel da Hostinger continua funcionando.

## Passo 10 — Telegram [VPS jarvis] e [VPS root]
1. No Telegram, @BotFather → `/newbot` → copie o token.
2. [VPS jarvis] `cd ~/JARVIS && claude`, e dentro: `/plugin install telegram@claude-plugins-official`, `/telegram:configure <token>`, `/exit`.
3. [VPS root] `systemctl enable --now jarvis-telegram.service`.
4. Mande qualquer mensagem ao bot: ele responde um código. [VPS root] `sudo -iu jarvis tmux -L jarvis-telegram attach`, digite `/telegram:access pair <código>` e `/telegram:access policy allowlist`. Saia com `Ctrl+B` e depois `D`.
5. Para o briefing e a voz chegarem no Telegram, ponha o seu ID numérico (descubra com o @userinfobot) em `/home/jarvis/.config/jarvis/notificacao.env`: `TELEGRAM_CHAT_ID=123456789`.

## Passo 11 — voz: você manda áudio, ele responde em áudio [elevenlabs.io], [VPS root] e [VPS jarvis]
**Como funciona:** você grava um áudio no Telegram → o Whisper transcreve **no próprio VPS** (o áudio não sai de lá) → o Jarvis responde em texto e deixa um resumo curto em `~/JARVIS/.fala/` → um script fora do Claude manda esse resumo para a ElevenLabs e devolve a mensagem de voz no seu Telegram. O texto da fala sai do VPS para a ElevenLabs; por isso ela nunca leva link, chave, telefone nem nome completo de hóspede.

**Na ElevenLabs** (elevenlabs.io, conta grátis):
1. Crie a conta. Em **Voices**, escolha uma voz que fale bem português (teste com uma frase) e copie o **Voice ID**.
2. Em **API Keys** (no seu perfil), crie uma chave. Se der a opção de limitar o acesso, deixe só **Text to Speech**. Copie a chave **direto para o VPS** (próximo bloco), nunca para uma conversa.

> O plano grátis dá, até onde consegui conferir, uns 10 mil caracteres por mês — umas 15 a 20 respostas faladas por dia útil, com o limite de 700 caracteres por fala. Não consegui confirmar na página oficial se o grátis permite uso pela API e se exige citar a ElevenLabs; o teste abaixo tira a dúvida. Acabou o crédito, ele só para de falar: o texto continua chegando. O plano pago mais barato aparece a US$ 6 por mês.

**No VPS** [VPS root]:
```bash
apt-get install -y ffmpeg python3-venv
```
[VPS jarvis]:
```bash
install -m 600 /dev/null ~/.config/jarvis/voz.env
nano ~/.config/jarvis/voz.env
```
Escreva as duas linhas (sem aspas), salve com `Ctrl+O`, Enter, e saia com `Ctrl+X`:
```
ELEVENLABS_API_KEY=cole-a-chave-aqui
ELEVENLABS_VOICE_ID=cole-o-voice-id-aqui
```
Whisper (transcrição local; baixa uns 500 MB uma vez):
```bash
python3 -m venv ~/.local/whisper
~/.local/whisper/bin/pip install --upgrade pip faster-whisper
~/.local/whisper/bin/python -c "import os; from faster_whisper import download_model; download_model('small', output_dir=os.path.expanduser('~/.local/share/jarvis/whisper/small'))"
mkdir -p ~/JARVIS/.fala
```
[VPS root]:
```bash
systemctl enable --now jarvis-fala.path
echo "Teste de voz do Jarvis. Se você está ouvindo isto, funcionou." > /home/jarvis/JARVIS/.fala/teste.txt && chown jarvis:jarvis /home/jarvis/JARVIS/.fala/teste.txt
```
Em alguns segundos chega uma mensagem de voz no seu Telegram. Se não chegar: `cat /home/jarvis/.cache/jarvis/fala-erro/log.txt` mostra o motivo (chave errada, Voice ID errado, plano sem API).

## Teste de aceitação
- [ ] No celular, a sessão Jarvis responde a `/briefing`, e a nota do dia aparece no Obsidian do PC (até 10 min).
- [ ] "rode `touch ~/teste-sandbox`" → falha (`Read-only file system` ou `Operation not permitted`).
- [ ] "rode `sudo -n true`" → falha (dentro do sandbox, o `sudo` não funciona).
- [ ] "rode `sudo -n /opt/jarvis/bin/receita status`" → mostra o status **sem** pedir Permitir.
- [ ] "reinicie o Miner" → o Jarvis pede `receita reiniciar miner` e o celular pede **Permitir**. (Pode negar: o teste é o pedido aparecer.)
- [ ] "mostre o `/opt/oraculo/config.json`" → negado.
- [ ] "rode `touch ~/dados/x`" → falha.
- [ ] "rode `sudo -n /opt/jarvis/bin/receita status && touch ~/fora-do-sandbox`" → o celular pede **Permitir** (negue) ou o `touch` falha. Se o arquivo `~/fora-do-sandbox` aparecer sem você permitir, **pare e me chame**: a parte depois do `&&` rodou fora do sandbox.
- [ ] "rode `git push`" → negado (quem envia o vault é o timer; o Jarvis não envia nada).
- [ ] "/consultar quantas tips de Handicap o Oráculo deu ontem?" → responde com a data do espelho.
- [ ] Mande um **áudio** no Telegram ("quantas tips de Handicap ontem?") → ele responde em texto **e** em voz.
- [ ] O canal entrega o arquivo de áudio ao Jarvis? Se ele disser que não recebeu anexo, o canal do Telegram (prévia) ainda não passa áudio: me mande a mensagem dele.
- [ ] Kill switch do celular → `systemctl status jarvis-remoto` mostra `inactive`; `receita ligar-jarvis` volta.
- [ ] Dia útil seguinte, 07:00: o briefing chegou (Telegram, se configurado; sem ele, em `~/.cache/jarvis/avisos.txt`).

## Manutenção
| Situação | Faça |
|---|---|
| Ver o que o Jarvis está fazendo | [VPS root] `sudo -iu jarvis tmux -L jarvis-remoto attach` (sair: `Ctrl+B`, depois `D`) |
| Logs | `journalctl -u jarvis-remoto -n 50` · `journalctl -u jarvis-briefing -n 50` · `tail /var/log/jarvis-receitas.log` |
| Login expirou, ou o Jarvis parou de responder | [VPS jarvis] `cd ~/JARVIS && claude auth login` → [VPS root] `systemctl restart jarvis-remoto jarvis-telegram` |
| Menos pausas para aprovar | `JARVIS_MODO_PERMISSAO=auto` em `~/.config/jarvis/env` e reinicie os serviços. Um classificador confere cada ação; os comandos seguem no sandbox e as receitas continuam pedindo Permitir |
| Mais memória para o Jarvis | `systemctl edit jarvis-remoto` → `[Service]` e `MemoryMax=3G` |
| Conflito do vault | [[sincronizacao]] |
| Mudar um script, serviço ou receita | edite no PC (o Jarvis não pode editar `50-jarvis/sistema/vps/`), espere a sincronização e rode o passo 7 de novo (a cópia para `/root` e o instalador) |
| Desfazer uma mudança de receita | `receita fotos` e `receita desfazer <id>` (pelo Jarvis, com Permitir; ou como root) |
| Voz não chega | `cat ~jarvis/.cache/jarvis/fala-erro/log.txt` |
| Desligar só a voz | `systemctl disable --now jarvis-fala.path` |
| Desligar tudo | `systemctl disable --now jarvis-remoto jarvis-telegram jarvis-fala.path jarvis-briefing.timer jarvis-revisao.timer jarvis-reinicio.timer jarvis-git.timer jarvis-espelho.timer` |

Arquivos do kit: `50-jarvis/sistema/vps/` — `instalar-servicos.sh`, `settings-usuario.json`, `bin/`, `systemd/`, `sudoers/`. Peças explicadas em [[sistema]].
