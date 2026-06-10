#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# animate.sh — render a POV-Ray scene as an animation and mux to mp4.
#
#   ./animate.sh scenes/foo.pov [seconds] [fps] [width] [height] [--crt]
#
# The scene should drive motion off the built-in `clock` variable (0..1),
# e.g. via Retro_Orbit_Camera(...). POV-Ray renders the frame sequence
# (+KFI/+KFF), ffmpeg encodes it, and --crt adds the VHS/CRT degrade pass.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
POV="${1:?usage: animate.sh scene.pov [secs] [fps] [w] [h] [--crt]}"
SECS="${2:-6}"; FPS="${3:-24}"; W="${4:-1280}"; H="${5:-720}"
CRT=0; for a in "$@"; do [ "$a" = "--crt" ] && CRT=1; done

base="$(basename "${POV%.pov}")"
fdir="$HERE/frames/$base"; out="$HERE/output/${base}.mp4"
rm -rf "$fdir"; mkdir -p "$fdir" "$HERE/output"
NFRAMES=$(( SECS * FPS ))

echo ">> rendering $NFRAMES frames (${SECS}s @ ${FPS}fps, ${W}x${H})"
povray "+I${POV}" "+O${fdir}/f.png" "+W${W}" "+H${H}" +A0.3 \
  "+L${HERE}/lib" "+WT$(nproc)" \
  +KFI1 "+KFF${NFRAMES}" +KI0.0 +KF1.0 -D

echo ">> encoding mp4"
ffmpeg -y -framerate "$FPS" -pattern_type glob -i "${fdir}/f*.png" \
  -c:v libx264 -pix_fmt yuv420p -crf 18 "$out" -loglevel error

if [ "$CRT" = 1 ]; then
  echo ">> applying CRT/VHS degrade pass"
  "$HERE/crt_post.sh" "$out" "${out%.mp4}_crt.mp4"
  out="${out%.mp4}_crt.mp4"
fi
echo ">> $out"
