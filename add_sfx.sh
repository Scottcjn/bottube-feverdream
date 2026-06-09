#!/usr/bin/env bash
# add_sfx.sh — compose a procedural soundscape (engine-hum bed + timed SFX) onto a
# video. Self-contained: all sound from sfx/*.wav (synthesized, no samples/API).
#   ./add_sfx.sh in.mp4 out.mp4 [battle|build|space]
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; S="$HERE/sfx"
IN="${1:?in.mp4}"; OUT="${2:?out.mp4}"; THEME="${3:-battle}"
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$IN")
case "$THEME" in
  battle) BED=enginehum.wav
    EV=( "laser:0.4:0.5" "laser:1.3:0.5" "laser:2.2:0.5" "laser:3.5:0.5" "laser:4.6:0.5"
         "explosion:1.6:0.7" "explosion:3.3:0.7" "clang:0.9:0.6" "clang:2.7:0.6" "boing:0.2:0.4" ) ;;
  build) BED=enginehum.wav
    EV=( "tink:0.5:0.7" "tink:1.1:0.7" "tink:1.8:0.7" "tink:2.6:0.7" "tink:3.4:0.7" "tink:4.2:0.7"
         "thud:0.8:0.6" "thud:2.2:0.6" "powerup:3.0:0.5" ) ;;
  space) BED=enginehum.wav
    EV=( "powerup:0.6:0.5" "laser:1.8:0.4" "laser:3.6:0.4" "boing:2.4:0.4" ) ;;
esac
# build ffmpeg inputs + filtergraph
ARGS=( -y -i "$IN" -stream_loop -1 -t "$DUR" -i "$S/$BED" )
FC="[1:a]volume=0.4,atrim=0:${DUR}[bed];"; MIX="[bed]"; idx=2
for e in "${EV[@]}"; do IFS=: read -r snd t vol <<<"$e"
  ARGS+=( -i "$S/$snd.wav" )
  ms=$(awk "BEGIN{printf \"%d\", $t*1000}")
  FC+="[${idx}:a]adelay=${ms}|${ms},volume=${vol}[e${idx}];"; MIX+="[e${idx}]"; idx=$((idx+1))
done
N=$((idx-1))
FC+="${MIX}amix=inputs=${N}:duration=first:dropout_transition=0,volume=2.4[mix]"
ffmpeg "${ARGS[@]}" -filter_complex "$FC" -map 0:v -map "[mix]" -c:v copy -c:a aac -shortest "$OUT" -loglevel error
echo ">> $OUT (theme=$THEME, $((N-1)) sfx hits + hum bed)"
