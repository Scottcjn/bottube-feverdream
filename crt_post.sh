#!/usr/bin/env bash
# crt_post.sh — run a clip through a CRT/VHS degradation pass via ffmpeg.
#   ./crt_post.sh in.mp4 out.mp4
# Adds: mild chroma bleed, scanlines, slight noise, vignette, soft bloom.
# Optional "found on a dusty tape" vibe for the channel — not applied by default.
set -euo pipefail
IN="${1:?usage: crt_post.sh in.mp4 out.mp4}"; OUT="${2:?out.mp4}"
ffmpeg -y -i "$IN" -vf "
  format=yuv444p,
  gblur=sigma=0.4,
  chromashift=cbh=2:crh=-2,
  noise=alls=8:allf=t,
  curves=preset=lighter,
  vignette=PI/5,
  format=yuv420p
" -c:v libx264 -crf 20 "$OUT" -loglevel error
echo ">> $OUT"
