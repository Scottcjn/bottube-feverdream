#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# render_gpu.sh — Blender Cycles GPU render lane (the "speed" lane).
#
#   ./render_gpu.sh scene.py|scene.blend [frames] [node]
#
# Runs Blender headless with GPU (OptiX/CUDA) forced on. Default target is the
# RTX 5070 node .106; pass "local" to render on this box, or a host to ssh into.
#
# For a .py scene file, Blender builds the scene from your script then renders.
# For a .blend, it renders the file directly. GPU device selection is forced by
# gpu_enable.py so Cycles never silently falls back to CPU.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SCENE="${1:?usage: render_gpu.sh scene.py|scene.blend [frames] [node]}"
FRAMES="${2:-1}"
NODE="${3:-192.168.0.106}"            # RTX 5070 render node (sophia5070node)
SSH_USER="${RETRO_GPU_USER:-sophia5070node}"
# Blender binaries. The 50-series (Blackwell/sm_120) needs Blender 4.3+ with
# OptiX — the distro 4.0.2 apt build can't drive it.
LOCAL_BLENDER="${RETRO_BLENDER_BIN:-blender}"
REMOTE_BLENDER="${RETRO_REMOTE_BLENDER:-/mnt/data/blender44}"

run_blender() {
  local scene="$1"
  if [[ "$scene" == *.blend ]]; then
    "$LOCAL_BLENDER" -b "$scene" -P "$HERE/gpu_enable.py" -a
  else
    "$LOCAL_BLENDER" -b -P "$HERE/gpu_enable.py" -P "$scene"
  fi
}

if [ "$NODE" = "local" ]; then
  echo ">> GPU render (local, $LOCAL_BLENDER)"
  run_blender "$SCENE"
else
  echo ">> GPU render on $SSH_USER@$NODE (RTX 5070, $REMOTE_BLENDER)"
  # ship scene + helpers, render remotely, pull frames back
  ssh "$SSH_USER@$NODE" 'mkdir -p ~/feverdream'
  scp -q "$SCENE" "$HERE/gpu_enable.py" "$SSH_USER@$NODE:~/feverdream/"
  ssh "$SSH_USER@$NODE" "cd ~/feverdream && $REMOTE_BLENDER -b -P gpu_enable.py -P $(basename "$SCENE")"
  scp -q "$SSH_USER@$NODE:~/feverdream/output/*" "$HERE/output/" 2>/dev/null || true
fi
echo ">> done"
