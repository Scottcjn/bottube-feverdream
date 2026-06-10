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
"$HERE/ai_scene_blender.py" "$PROMPT" --name "$name" --frames "$FRAMES" >/dev/null

# Render node config (same as existing gpu lane)
NODE="${RETRO_GPU_NODE:-192.168.0.106}"
USER="${RETRO_GPU_USER:-sophia5070node}"
RBLENDER="${RETRO_REMOTE_BLENDER:-/mnt/data/blender44}"
RDIR="feverdream"

SSH="ssh"; SCP="scp"
if [ -n "${RETRO_GPU_PASS:-}" ]; then
  SSH="sshpass -p $RETRO_GPU_PASS ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no"
  SCP="sshpass -p $RETRO_GPU_PASS scp -o PreferredAuthentications=password -o PubkeyAuthentication=no"
fi
SSHOPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=10"

echo ">> [gpu] staging on $USER@$NODE"
$SSH $SSHOPTS "$USER@$NODE" "mkdir -p ~/$RDIR/lib ~/$RDIR/scenes ~/$RDIR/output/anim && rm -f ~/$RDIR/output/anim/*.png"
$SCP $SSHOPTS "$HERE/gpu_enable.py"                    "$USER@$NODE:~/$RDIR/" >/dev/null
$SCP $SSHOPTS "$HERE/lib/retro90s_blender.py"           "$USER@$NODE:~/$RDIR/lib/" >/dev/null
$SCP $SSHOPTS "$scene_py"                               "$USER@$NODE:~/$RDIR/scenes/" >/dev/null

echo ">> [gpu] rendering $FRAMES frames on RTX 5070 (OptiX)"
$SSH $SSHOPTS "$USER@$NODE" \
  "cd ~/$RDIR && FD_FRAMES=$FRAMES $RBLENDER -b -P gpu_enable.py -P scenes/$(basename "$scene_py") 2>&1 | grep -iE 'OPTIX|Saved|Error|rendered' | tail -5"

echo ">> [gpu] pulling frames"
fdir="$HERE/frames/gpu_anim"; rm -rf "$fdir"; mkdir -p "$fdir"
$SCP $SSHOPTS "$USER@$NODE:~/$RDIR/output/anim/*.png" "$fdir/" >/dev/null

echo ">> [gpu] encoding mp4"
mkdir -p "$(dirname "$OUT")"
ffmpeg -y -framerate "$FPS" -pattern_type glob -i "$fdir/*.png" \
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
