#!/usr/bin/env bash
# render.sh — render a single POV-Ray scene to a still image.
#   ./render.sh scenes/foo.pov [width] [height] [draft|final]
# CPU raytracer: uses all cores. On POWER8 that's 128 threads of vintage glory.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
POV="${1:?usage: render.sh scene.pov [w] [h] [draft|final]}"
W="${2:-1920}"; H="${3:-1080}"; Q="${4:-final}"
base="$(basename "${POV%.pov}")"
out="$HERE/output/${base}.png"
mkdir -p "$HERE/output"
AA=""; [ "$Q" = "final" ] && AA="+A0.3"
echo ">> rendering $base  ${W}x${H}  ($Q)"
povray "+I${POV}" "+O${out}" "+W${W}" "+H${H}" $AA \
  "+L${HERE}/lib" "+WT$(nproc)" -D
echo ">> $out"
