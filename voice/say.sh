#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# say.sh — voice engine: synthesize a persona-voiced line to a wav (offline,
# espeak-ng — no API). Robotic timbre suits retro game/unit voices.
#   ./voice/say.sh <persona> "line of text" out.wav
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
P="${1:?persona}"; TXT="${2:?text}"; OUT="${3:?out.wav}"
# persona = espeak voice variant : pitch(0-99) : speed(wpm) : gap(ms)
case "$P" in
  boris)    V="en+m4"; PI=20; SP=125; G=8 ;;   # deep, slow, Soviet-commander
  sophia)   V="en+f3"; PI=58; SP=158; G=5 ;;   # warm, measured
  janitor)  V="en+m2"; PI=33; SP=150; G=4 ;;   # flat, robotic sysadmin
  marine)   V="en-us+m3"; PI=42; SP=172; G=3 ;; # gruff trooper "yes sir"
  peon)     V="en+m6"; PI=68; SP=190; G=2 ;;   # high, eager grunt "work work"
  zergling) V="en+f5"; PI=86; SP=230; G=0 ;;   # shrill, fast skitter
  computer) V="en+croak"; PI=50; SP=150; G=6 ;;# AI/announcer
  battlecruiser) V="en+m1"; PI=8; SP=112; G=10 ;; # deep, slow capital-ship AI "operational"
  *)        V="en+m3"; PI=50; SP=160; G=5 ;;
esac
espeak-ng -v "$V" -p "$PI" -s "$SP" -g "$G" -w "$OUT" "$TXT"
echo ">> $OUT  ($P: $V pitch=$PI speed=$SP)"
