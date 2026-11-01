#!/bin/bash
# Instala (ou atualiza) as peças do Jarvis que rodam como root: scripts em /opt/jarvis/bin, unidades do systemd,
# a regra do sudo (só as receitas) e as pastas do espelho e das fotos. NÃO liga os serviços (passo 7 do vps.md).
#
# A origem (o vault) é uma pasta que o usuário jarvis consegue escrever. Por isso:
#   1. rode SEMPRE uma cópia deste script que é só do root, nunca o arquivo do vault:
#        install -m 700 /home/jarvis/JARVIS/50-jarvis/sistema/vps/instalar-servicos.sh /root/instalar-servicos.sh
#        bash /root/instalar-servicos.sh
#   2. ele copia o kit para uma pasta só do root, mostra a diferença COMPLETA dessa cópia e instala só dela;
#   3. só aceita os arquivos de uma lista fechada.
set -euo pipefail
umask 022
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
cd /

ORIGEM_PADRAO=/home/jarvis/JARVIS/50-jarvis/sistema/vps
BIN_OK="receita espelho.py remoto.sh telegram.sh rotina.sh notificar.sh git-sync.sh falar.sh mcp-receitas.py"
UNIDADES_OK="jarvis-remoto.service jarvis-telegram.service jarvis-telegram-2.service jarvis-briefing.service jarvis-briefing.timer
jarvis-revisao.service jarvis-revisao.timer jarvis-reinicio.service jarvis-reinicio.timer jarvis-git.service
jarvis-git.timer jarvis-espelho.service jarvis-espelho.timer jarvis-fala.service jarvis-fala.path"

ok()   { printf '  [ok] %s\n' "$*"; }
erro() { printf '  [ERRO] %s\n' "$*" >&2; exit 1; }

principal() {
  [ "$(id -u)" -eq 0 ] || erro "rode como root"
  case "$(readlink -f "$0")" in /home/*) erro "rode a cópia do root (/root/instalar-servicos.sh), não o arquivo do vault: veja o topo deste script" ;; esac
  local SRC="${1:-$ORIGEM_PADRAO}"
  id jarvis >/dev/null 2>&1 || erro "o usuário jarvis não existe (passo 2 do vps.md)"
  command -v tmux >/dev/null || erro "falta o tmux (passo 2)"

  # 1) cópia só do root; daqui em diante nada é lido do vault
  K="$(mktemp -d /root/jarvis-kit.XXXXXX)"
  trap 'rm -rf "$K"' EXIT
  for d in bin systemd sudoers; do [ -d "$SRC/$d" ] || erro "faltou a pasta $SRC/$d"; done
  cp -r --no-dereference "$SRC/bin" "$SRC/systemd" "$SRC/sudoers" "$K/"
  [ -z "$(find "$K" -type l)" ] || erro "há atalhos (symlinks) no kit: recusado"
  # só a lista fechada
  for f in "$K"/bin/*; do case " $BIN_OK " in *" $(basename "$f") "*) ;; *) erro "arquivo inesperado em bin/: $(basename "$f")" ;; esac; done
  for f in "$K"/systemd/*; do echo "$UNIDADES_OK" | tr ' ' '\n' | grep -qx "$(basename "$f")" || erro "unidade inesperada: $(basename "$f")"; done
  [ "$(ls "$K/sudoers")" = "jarvis" ] || erro "em sudoers/ só pode existir o arquivo jarvis"
  # toda unidade de serviço que não é do root precisa dizer User=jarvis
  for f in "$K"/systemd/*.service; do
    case "$(basename "$f")" in jarvis-reinicio.service|jarvis-espelho.service) ;; *)
      grep -qx 'User=jarvis' "$f" || erro "$(basename "$f") não roda como jarvis" ;; esac
  done

  # 2) a diferença completa (arquivo novo aparece inteiro)
  local REL MUDA=0; REL="$(mktemp /root/jarvis-diff.XXXXXX)"
  comparar() {  # novo instalado
    if [ ! -e "$2" ]; then
      { echo "=== NOVO: $2"; sed 's/^/+ /' "$1"; echo; } >> "$REL"; MUDA=1
    elif ! cmp -s "$1" "$2"; then
      { echo "=== MUDA: $2"; diff -u "$2" "$1" || true; echo; } >> "$REL"; MUDA=1
    fi
  }
  for f in "$K"/bin/*; do comparar "$f" "/opt/jarvis/bin/$(basename "$f")"; done
  for f in "$K"/systemd/*; do comparar "$f" "/etc/systemd/system/$(basename "$f")"; done
  comparar "$K/sudoers/jarvis" /etc/sudoers.d/jarvis
  if [ "$MUDA" -eq 0 ]; then
    ok "nada mudou em relação ao que está instalado"
  elif [ "${2:-}" != "--sim" ]; then
    echo "== Vou mostrar a diferença completa ($(grep -c '^=== ' "$REL") arquivo(s)). Setas para rolar, q para sair."
    echo "   Leia tudo: isto vai rodar como root."
    read -r -p "   Enter para abrir... " _
    less "$REL" || cat "$REL"
    read -r -p "Digite sim para instalar: " R
    [ "$R" = "sim" ] || erro "cancelado"
  fi
  rm -f "$REL"

  # 3) instala da cópia
  install -d -m 755 -o root -g root /opt/jarvis /opt/jarvis/bin
  for f in "$K"/bin/*; do install -m 755 -o root -g root "$f" "/opt/jarvis/bin/$(basename "$f")"; done
  ok "scripts em /opt/jarvis/bin"
  for f in "$K"/systemd/*; do install -m 644 -o root -g root "$f" "/etc/systemd/system/$(basename "$f")"; done
  systemctl daemon-reload
  ok "unidades do systemd instaladas"
  visudo -cf "$K/sudoers/jarvis" >/dev/null || erro "a regra do sudo tem erro de sintaxe"
  install -m 440 -o root -g root "$K/sudoers/jarvis" /etc/sudoers.d/jarvis
  ok "sudo: jarvis só pode rodar /opt/jarvis/bin/receita"

  # 4) pastas (nada de root escrevendo dentro de /home/jarvis, a não ser pelo próprio jarvis)
  install -d -m 700 -o root -g root /var/lib/jarvis /var/lib/jarvis/fotos /var/lib/jarvis/espelho /var/lib/jarvis/backups
  install -d -m 750 -o root -g jarvis /var/lib/jarvis-dados
  [ -e /var/log/jarvis-receitas.log ] || install -m 600 -o root -g root /dev/null /var/log/jarvis-receitas.log
  runuser -u jarvis -- mkdir -p /home/jarvis/repos /home/jarvis/.cache/jarvis /home/jarvis/JARVIS/.fala
  if [ ! -e /home/jarvis/dados ]; then runuser -u jarvis -- ln -s /var/lib/jarvis-dados /home/jarvis/dados; fi
  ok "pastas: /var/lib/jarvis (root), /var/lib/jarvis-dados (espelho; ~jarvis/dados aponta para lá), ~jarvis/repos"

  for p in bwrap socat; do command -v "$p" >/dev/null || echo "  [!] falta $p: apt-get install -y bubblewrap socat"; done
  echo
  echo "Pronto. Próximo passo (vps.md, passo 7): ligar os serviços."
}

principal "$@"
