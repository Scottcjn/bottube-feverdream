// tron_lightcycle.pov — 1982-style light cycles racing on a neon grid, each
// leaving a growing glowing wall (the trail extends via `clock`). Generic tribute.
#include "retro90s.inc"

sky_sphere { pigment { color rgb <0.01,0.01,0.03> } }
Retro_Sun(<-0.3,0.7,-0.4>, rgb <0.5,0.6,0.8>)
Retro_Grid_Floor(rgb <0.1,0.9,1.0>, rgb <0.02,0.02,0.05>, 1.6)

#declare Z = -4 + clock*18;     // cycles race forward
#declare Dark = texture { pigment { rgb <0.04,0.05,0.08> } finish { ambient 0.25 diffuse 0.5 phong 0.8 phong_size 70 reflection { 0.15 } } }
#declare Cyan = texture { pigment { rgb <0.1,0.9,1.0> } finish { ambient 2.4 } }
#declare Orange = texture { pigment { rgb <1.0,0.5,0.05> } finish { ambient 2.4 } }

// a light cycle: dark body + glowing top/bottom edge strips
#macro Cycle(cx, glow)
  union {
    box { <-0.28,0.18,-0.72>, <0.28,0.60,0.72> texture { Dark } }
    box { <-0.30,0.55,-0.74>, <0.30,0.66,0.74> texture { glow } }
    box { <-0.30,0.16,-0.74>, <0.30,0.24,0.74> texture { glow } }
    box { <-0.20,0.60,-0.30>, <0.20,0.85,0.40> texture { Dark } }   // canopy
    translate <cx, 0, Z>
  }
#end

// trails (grow from start to current Z)
box { <-1.12,0,-4>, <-0.88,1.35, Z> texture { Cyan } }
box { < 0.88,0,-4>, < 1.12,1.35, Z> texture { Orange } }

Cycle(-1.0, Cyan)
Cycle( 1.0, Orange)

Retro_Camera(<4.8, 2.3, Z+5.5>, <-0.3, 0.7, Z-2>)
