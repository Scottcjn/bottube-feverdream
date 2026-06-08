#!/usr/bin/env bash
# make_video_gpu.sh — GPU animation lane: render an orbiting retro-CGI mp4 on the
# RTX 5070 node (Blender/Cycles + OptiX), encode with ffmpeg.
#
#   ./make_video_gpu.sh /path/out.mp4 [secs] [fps] [scene.py]
#
# Companion to make_video.sh (POV-Ray/CPU). Uses scenes/blender_anim.py by
# default. Auth: keyless ssh by default; set RETRO_GPU_PASS to use sshpass.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="${1:?usage: make_video_gpu.sh out.mp4 [secs] [fps] [scene.py]}"
SECS="${2:-3}"; FPS="${3:-24}"
SCENE="${4:-$HERE/scenes/blender_anim.py}"
FRAMES=$(( SECS * FPS ))

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
$SCP $SSHOPTS "$HERE/gpu_enable.py" "$USER@$NODE:~/$RDIR/" >/dev/null
$SCP $SSHOPTS "$HERE/lib/retro90s_blender.py" "$USER@$NODE:~/$RDIR/lib/" >/dev/null
$SCP $SSHOPTS "$SCENE" "$USER@$NODE:~/$RDIR/scenes/" >/dev/null

echo ">> [gpu] rendering $FRAMES frames on RTX 5070 (OptiX)"
$SSH $SSHOPTS "$USER@$NODE" \
  "cd ~/$RDIR && FD_FRAMES=$FRAMES $RBLENDER -b -P gpu_enable.py -P scenes/$(basename "$SCENE") 2>&1 | grep -iE 'OPTIX|Saved|Error' | tail -3"

echo ">> [gpu] pulling frames"
fdir="$HERE/frames/gpu_anim"; rm -rf "$fdir"; mkdir -p "$fdir"
$SCP $SSHOPTS "$USER@$NODE:~/$RDIR/output/anim/*.png" "$fdir/" >/dev/null

echo ">> [gpu] encoding mp4"
mkdir -p "$(dirname "$OUT")"
ffmpeg -y -framerate "$FPS" -pattern_type glob -i "$fdir/*.png" \
  -c:v libx264 -pix_fmt yuv420p -crf 18 "$OUT" -loglevel error
[ -f "$OUT" ] || { echo ">> [gpu] FAILED" >&2; exit 1; }
echo ">> [gpu] $OUT"
