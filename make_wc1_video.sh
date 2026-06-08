#!/usr/bin/env bash
# make_wc1_video.sh — render a POV-Ray scene as a Warcraft-1-style VGA pixel-art
# clip: render frames, build ONE stable palette across all frames (no flicker),
# nearest-neighbor pixelate + bayer-dither, encode. Synthesized from a tri-brain
# (Codex + Grok) pass on WC1 authenticity.
#
#   ./make_wc1_video.sh scene.pov out.mp4 [secs] [fps] [nativeW] [nativeH] [colors]
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
POV="${1:?usage: make_wc1_video.sh scene.pov out.mp4 [secs] [fps] [nw] [nh] [colors]}"
OUT="${2:?out.mp4}"
SECS="${3:-4}"; FPS="${4:-12}"; NW="${5:-240}"; NH="${6:-138}"; COLORS="${7:-64}"
OW=$((NW*3)); OH=$((NH*3))           # nearest-neighbor upscale x3
N=$((SECS*FPS))
fdir="$HERE/frames/wc1_$(basename "${POV%.pov}")"; rm -rf "$fdir"; mkdir -p "$fdir" "$(dirname "$OUT")"

echo ">> [wc1] rendering $N frames (${OW}x${OH} source)"
povray "+I${POV}" "+O${fdir}/f.png" "+W${OW}" "+H${OH}" +A0.3 \
  "+L${HERE}/lib" "+WT$(nproc)" +KFI1 "+KFF${N}" +KI0.0 +KF1.0 -D

echo ">> [wc1] building stable VGA palette (${COLORS} colours)"
ffmpeg -y -pattern_type glob -i "${fdir}/f*.png" \
  -vf "scale=${NW}:${NH}:flags=neighbor,palettegen=max_colors=${COLORS}:stats_mode=full" \
  "${fdir}/palette.png" -loglevel error

echo ">> [wc1] pixelate + dither + encode"
ffmpeg -y -framerate "$FPS" -pattern_type glob -i "${fdir}/f*.png" -i "${fdir}/palette.png" \
  -lavfi "[0:v]scale=${NW}:${NH}:flags=neighbor,scale=${OW}:${OH}:flags=neighbor[px];[px][1:v]paletteuse=dither=bayer:bayer_scale=2:diff_mode=rectangle" \
  -c:v libx264 -pix_fmt yuv420p -crf 18 "$OUT" -loglevel error
echo ">> [wc1] $OUT"
