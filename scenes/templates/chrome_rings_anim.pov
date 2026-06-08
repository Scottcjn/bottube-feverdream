// chrome_rings.pov — interlocked chrome tori hero shot, the demo-reel classic.
// Template for the feverdream generator to re-dress.
#include "retro90s.inc"

Retro_Sky_Gradient(rgb <0.12,0.14,0.40>, rgb <1.0,0.6,0.3>)
Retro_Sun(<-0.4,0.8,-0.4>, rgb <1.0,0.95,0.8>)
Retro_Checker_Floor(rgb <0.92,0.92,0.96>, rgb <0.07,0.07,0.11>, 0.5)

torus { 2.0,0.45 Retro_Chrome(rgb <0.88,0.90,0.96>) rotate x*80 translate <-1.4,2.2,7> }
torus { 2.0,0.45 Retro_Chrome(rgb <0.88,0.90,0.96>) rotate <80,0,60> translate < 1.4,2.2,7> }
sphere { <0,1.0,4>, 1.0 Retro_Glass(rgb <1.0,0.5,0.2>) }

Retro_Orbit_Camera(8, 3.5, <0,2.2,7>)
