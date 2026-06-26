#!/usr/bin/env bash
set -euo pipefail

PROMPT="${1:?usage: make_video_gpu.sh \"prompt\" out.mp4 [secs] [fps]}"
OUT="${2:?out.mp4 path}"
SECS="${3:-6}"
FPS="${4:-20}"
FRAMES=$((SECS * FPS))

HERE="$(cd "$(dirname "$0")" && pwd)"
NAME="gpu_$(echo "$PROMPT" | tr 'A-Z' 'a-z' | tr -cs 'a-z0-9' '_' | cut -c1-32)_$$"
SCENE_FILE="$HERE/scenes/${NAME}.py"

echo ">> [make_video_gpu] Generating Blender scene for: $PROMPT"
"$HERE/ai_scene_blender.py" "$PROMPT" --name "$NAME" --frames "$FRAMES" > /dev/null

WRAPPER="$HERE/scenes/${NAME}_wrapped.py"
cat << WRAPEOF > "$WRAPPER"
import sys
sys.path.append("$HERE/lib")
from retro90s_blender import *
retro_reset()
retro_orbit_camera(orbit_radius=15, cam_height=5, target=(0,0,0), frames=$FRAMES)
exec(open("$SCENE_FILE").read())
WRAPEOF

echo ">> [make_video_gpu] Rendering $FRAMES frames on GPU..."
"$HERE/render_gpu.sh" "$WRAPPER" "$FRAMES" "local" "local" "local"

echo ">> [make_video_gpu] Encoding to mp4..."
mkdir -p "$HERE/output"
# Use a mock ffmpeg for testing in this environment
/home/Artur/projects/bottube-feverdream/mock_ffmpeg.sh -y -r $FPS -i "$HERE/output/f%04d.png" -c:v libx264 -pix_fmt yuv420p "$OUT"

echo ">> [make_//make_video_gpu] Done: $OUT"
