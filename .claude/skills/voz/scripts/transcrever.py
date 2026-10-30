#!/usr/bin/env python3
"""Transcreve um áudio (mensagem de voz do Telegram, .oga/.ogg/.mp3/.m4a) para texto, no próprio VPS (Whisper local).

Uso: ~/.local/whisper/bin/python .claude/skills/voz/scripts/transcrever.py <arquivo>
O modelo fica em ~/.local/share/jarvis/whisper (baixado na instalação); nada sai do VPS.
"""
import os
import sys

MODELO = os.path.expanduser(os.environ.get("JARVIS_WHISPER_MODELO", "~/.local/share/jarvis/whisper/small"))


def main():
    if len(sys.argv) != 2 or not os.path.isfile(sys.argv[1]):
        sys.exit("uso: transcrever.py <arquivo de áudio>")
    if os.path.getsize(sys.argv[1]) > 25 * 1024 * 1024:
        sys.exit("áudio grande demais (mais de 25 MB)")
    from faster_whisper import WhisperModel
    modelo = WhisperModel(MODELO, device="cpu", compute_type="int8", cpu_threads=2)
    partes, info = modelo.transcribe(sys.argv[1], language="pt", vad_filter=True, beam_size=1)
    texto = " ".join(p.text.strip() for p in partes).strip()
    print(texto or "(áudio sem fala reconhecível)")


if __name__ == "__main__":
    main()
