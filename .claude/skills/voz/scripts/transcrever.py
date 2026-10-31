#!/usr/bin/env python3
"""Transcreve um áudio (mensagem de voz do Telegram, .oga/.ogg/.mp3/.m4a) para texto, no próprio VPS (Whisper local).

Uso: ~/.local/whisper/bin/python .claude/skills/voz/scripts/transcrever.py <arquivo>
O modelo fica em ~/.local/share/jarvis/whisper (baixado na instalação); nada sai do VPS.
O áudio é decodificado pelo ffmpeg do sistema (16 kHz, mono) e entregue pronto ao Whisper:
assim não dependemos da biblioteca av, cuja versão 19 não conversa com o faster-whisper 1.2.1.
"""
import os
import subprocess
import sys

MODELO = os.path.expanduser(os.environ.get("JARVIS_WHISPER_MODELO", "~/.local/share/jarvis/whisper/small"))


def decodificar(caminho):
    import numpy as np
    r = subprocess.run(
        ["/usr/bin/ffmpeg", "-nostdin", "-loglevel", "error", "-i", caminho,
         "-f", "s16le", "-ac", "1", "-ar", "16000", "-"],
        capture_output=True, timeout=120,
    )
    if r.returncode != 0 or not r.stdout:
        sys.exit("ffmpeg não conseguiu ler o áudio: " + r.stderr.decode(errors="replace")[:300])
    return np.frombuffer(r.stdout, np.int16).astype(np.float32) / 32768.0


def main():
    if len(sys.argv) != 2 or not os.path.isfile(sys.argv[1]):
        sys.exit("uso: transcrever.py <arquivo de áudio>")
    if os.path.getsize(sys.argv[1]) > 25 * 1024 * 1024:
        sys.exit("áudio grande demais (mais de 25 MB)")
    audio = decodificar(sys.argv[1])
    from faster_whisper import WhisperModel
    modelo = WhisperModel(MODELO, device="cpu", compute_type="int8", cpu_threads=2)
    partes, info = modelo.transcribe(audio, language="pt", vad_filter=True, beam_size=1)
    texto = " ".join(p.text.strip() for p in partes).strip()
    print(texto or "(áudio sem fala reconhecível)")


if __name__ == "__main__":
    main()
