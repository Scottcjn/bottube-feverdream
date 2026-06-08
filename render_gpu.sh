#!/usr/bin/env bash
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
NODE="${3:-192.168.0.106}"            # RTX 5070 render node
SSH_USER="${RETRO_GPU_USER:-sophia}"

run_blender() {
  local scene="$1"
  if [[ "$scene" == *.blend ]]; then
    blender -b "$scene" -P "$HERE/gpu_enable.py" -a
  else
    blender -b -P "$HERE/gpu_enable.py" -P "$scene"
  fi
}

if [ "$NODE" = "local" ]; then
  echo ">> GPU render (local)"
  run_blender "$SCENE"
else
  echo ">> GPU render on $SSH_USER@$NODE (RTX 5070)"
  # ship scene + helpers, render remotely, pull frames back
  ssh "$SSH_USER@$NODE" 'mkdir -p ~/feverdream'
  scp -q "$SCENE" "$HERE/gpu_enable.py" "$SSH_USER@$NODE:~/feverdream/"
  ssh "$SSH_USER@$NODE" "cd ~/feverdream && blender -b -P gpu_enable.py -P $(basename "$SCENE")"
  scp -q "$SSH_USER@$NODE:~/feverdream/output/*" "$HERE/output/" 2>/dev/null || true
fi
echo ">> done"
