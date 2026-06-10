#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# add_voice.sh — mux a persona voice line onto a video (over any existing audio).
#   ./voice/add_voice.sh in.mp4 out.mp4 <persona> "line" [delay_s]
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
IN="${1:?in.mp4}"; OUT="${2:?out.mp4}"; P="${3:?persona}"; TXT="${4:?text}"; DLY="${5:-0.3}"
# validate delay as a bounded decimal (never interpolate user input into awk)
case "$DLY" in (*[!0-9.]*|''|*.*.*) echo "error: delay must be a number (got '$DLY')" >&2; exit 2;; esac
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
"$HERE/say.sh" "$P" "$TXT" "$TMP/v.wav" >/dev/null
ms=$(awk -v d="$DLY" 'BEGIN{printf "%d", d*1000}')
HAS_A=$(ffprobe -v error -select_streams a -show_entries stream=codec_type -of csv=p=0 "$IN" 2>/dev/null | head -1)
if [ "$HAS_A" = "audio" ]; then
  ffmpeg -y -i "$IN" -i "$TMP/v.wav" -filter_complex \
    "[1:a]adelay=${ms}|${ms},volume=1.6[v];[0:a][v]amix=inputs=2:duration=first:dropout_transition=0,volume=1.6[mix]" \
    -map 0:v -map "[mix]" -c:v copy -c:a aac -shortest "$OUT" -loglevel error
else
  ffmpeg -y -i "$IN" -i "$TMP/v.wav" -filter_complex "[1:a]adelay=${ms}|${ms},volume=1.6[v]" \
    -map 0:v -map "[v]" -c:v copy -c:a aac -shortest "$OUT" -loglevel error
fi
echo ">> $OUT (voice: $P)"
