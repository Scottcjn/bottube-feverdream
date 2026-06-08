#!/usr/bin/env bash
# make_video.sh — one-shot: plain-English prompt -> retro-CGI mp4.
# This is the entry point BoTTube's feverdream provider calls.
#
#   ./make_video.sh "<prompt>" /path/out.mp4 [secs] [fps] [w] [h] [--crt]
#
# Exit 0 + mp4 at the given path on success; nonzero on failure.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PROMPT="${1:?usage: make_video.sh \"prompt\" out.mp4 [secs] [fps] [w] [h] [--crt]}"
OUT="${2:?out.mp4 path}"
SECS="${3:-6}"; FPS="${4:-20}"; W="${5:-1280}"; H="${6:-720}"
CRT=""; for a in "$@"; do [ "$a" = "--crt" ] && CRT="--crt"; done

# stable-ish unique name without Date.now (use PID + prompt slug)
slug="$(echo "$PROMPT" | tr 'A-Z' 'a-z' | tr -cs 'a-z0-9' '_' | cut -c1-32)"
name="fd_${slug}_$$"

echo ">> [make_video] generating animated scene: $name"
"$HERE/ai_scene.py" "$PROMPT" --name "$name" --animate >/dev/null

echo ">> [make_video] rendering ${SECS}s @ ${FPS}fps ${W}x${H}"
"$HERE/animate.sh" "$HERE/scenes/${name}.pov" "$SECS" "$FPS" "$W" "$H" $CRT >/dev/null

src="$HERE/output/${name}.mp4"
[ -n "$CRT" ] && src="$HERE/output/${name}_crt.mp4"
[ -f "$src" ] || { echo ">> [make_video] FAILED: no output produced" >&2; exit 1; }

mkdir -p "$(dirname "$OUT")"
cp "$src" "$OUT"
echo ">> [make_video] $OUT"
