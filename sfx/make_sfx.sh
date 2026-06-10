#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# make_sfx.sh — synthesize a library of procedural retro sound effects with ffmpeg.
# No samples, no API: pure oscillator/noise math -> sfx/*.wav. The audio analogue
# of the deterministic-raytrace approach. Run once to (re)build the library.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
gen() { ffmpeg -y -f lavfi -i "$1" -ac 1 -ar 44100 "$HERE/$2" -loglevel error; echo "  $2"; }

echo ">> synthesizing retro SFX..."
# laser / gauss zap — descending sine sweep with decay
gen "aevalsrc='sin(2*PI*t*(1500-2600*t))*exp(-7*t)':d=0.30" laser.wav
# explosion — brown-noise burst, low-passed, long decay
gen "anoisesrc=d=0.8:color=brown:amplitude=0.9,lowpass=f=700,afade=t=out:st=0.1:d=0.7" explosion.wav
# sword/clang — band-passed noise ping, fast metallic decay
gen "anoisesrc=d=0.35:color=white:amplitude=0.7,bandpass=f=2600:width_type=h:w=900,afade=t=out:st=0.02:d=0.33" clang.wav
# bow twang — low plucked sine
gen "aevalsrc='sin(2*PI*190*t)*exp(-11*t)*0.6':d=0.3" twang.wav
# arrow whoosh — short filtered noise sweep
gen "anoisesrc=d=0.25:color=pink:amplitude=0.5,highpass=f=600,afade=t=in:st=0:d=0.08,afade=t=out:st=0.12:d=0.13" whoosh.wav
# footstep / thud — low brown thump
gen "anoisesrc=d=0.16:color=brown:amplitude=0.8,lowpass=f=180,afade=t=out:st=0.02:d=0.14" thud.wav
# hammer / build tink — bright short metallic
gen "aevalsrc='sin(2*PI*1400*t)*exp(-20*t)*0.5':d=0.18" tink.wav
# powerup / pylon — rising sine shimmer
gen "aevalsrc='sin(2*PI*t*(400+1300*t))*0.4':d=0.55" powerup.wav
# engine hum — low detuned drone (loopable bed)
gen "aevalsrc='(sin(2*PI*68*t)+sin(2*PI*70.5*t)*0.7)*0.22':d=2.0" enginehum.wav
# spawn / boing — quick rising-then-falling sine
gen "aevalsrc='sin(2*PI*(300+900*abs(sin(PI*t)))*t)*exp(-3*t)*0.5':d=0.5" boing.wav
echo ">> done: $(ls "$HERE"/*.wav | wc -l) SFX in sfx/"
