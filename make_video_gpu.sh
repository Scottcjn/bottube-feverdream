#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# make_video_gpu.sh — GPU animation lane: prompt -> Blender orbit mp4 on RTX 5070
#
#   ./make_video_gpu.sh "chrome whale over neon canyon" out.mp4 6 24
#
# Mirrors make_video.sh but renders on GPU via Blender/Cycles (OptiX).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PROMPT="${1:?usage: make_video_gpu.sh \"prompt\" out.mp4 [secs] [fps] [--crt]}"
OUT="${2:?out.mp4 path}"
SECS="${3:-6}"
FPS="${4:-24}"
CRT=""; for a in "$@"; do [ "$a" = "--crt" ] && CRT="--crt"; done

# Validate numeric args
for _v in SECS FPS; do
  case "${!_v}" in (*[!0-9]*|'') echo "error: $_v must be a positive integer (got '${!_v}')" >&2; exit 2;; esac
done
{ [ "$SECS" -ge 1 ] && [ "$SECS" -le 30 ] && [ "$FPS" -ge 1 ] && [ "$FPS" -le 60 ]; } \
  || { echo "error: numeric arg out of range" >&2; exit 2; }

FRAMES=$(( SECS * FPS ))

# Generate Blender scene script from prompt
slug="$(echo "$PROMPT" | tr 'A-Z' 'a-z' | tr -cs 'a-z0-9' '_' | cut -c1-32)"
name="fd_gpu_${slug}_$$"
scene_py="$HERE/scenes/${name}.py"

echo ">> [gpu] generating scene from prompt: \"$PROMPT\""
python3 "$HERE/ai_scene_blender.py" "$PROMPT" --name "$name" --frames "$FRAMES" >/dev/null

echo ">> [gpu] rendering $FRAMES frames on RTX 5070 via render_gpu.sh"
fdir="$HERE/output/anim"
rm -rf "$fdir"
"$HERE/render_gpu.sh" "$scene_py" "$FRAMES" "${RETRO_GPU_NODE:-192.168.0.106}" >/dev/null

echo ">> [gpu] encoding mp4"
mkdir -p "$(dirname "$OUT")"
ffmpeg -y -framerate "$FPS" -pattern_type glob -i "$fdir/f*.png" \
  -c:v libx264 -pix_fmt yuv420p -crf 18 "$OUT" -loglevel error

[ -f "$OUT" ] || { echo ">> [gpu] FAILED: no output" >&2; exit 1; }

# Optional CRT post-process
if [ -n "$CRT" ]; then
  crt_out="${OUT%.mp4}_crt.mp4"
  "$HERE/crt_post.sh" "$OUT" "$crt_out"
  mv "$crt_out" "$OUT"
  echo ">> [gpu] crt pass applied"
fi

echo ">> [gpu] $OUT"
