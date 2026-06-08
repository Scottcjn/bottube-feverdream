// liquid_metal.pov — a chrome humanoid risen from a mirror puddle, 1991-era
// liquid-metal CGI vibe. Slow rotate via `clock`. Reflections do the work.
#include "retro90s.inc"

Retro_Sky_Gradient(rgb <0.10,0.14,0.40>, rgb <0.95,0.45,0.25>)   // sunset to reflect
Retro_Sun(<-0.5,0.7,-0.4>, rgb <1.0,0.9,0.78>)
Retro_Checker_Floor(rgb <0.85,0.85,0.9>, rgb <0.08,0.08,0.12>, 0.55)

#declare Spin = clock*200;

union {
  // mirror puddle
  sphere { 0,1 scale <1.5,0.10,1.5> translate <0,0.06,0> Retro_Chrome(rgb <0.9,0.9,0.95>) }
  // legs
  cylinder { <-0.34,0.05,0>, <-0.30,1.55,0>, 0.22 Retro_Chrome(rgb <0.9,0.9,0.95>) }
  cylinder { < 0.34,0.05,0>, < 0.30,1.55,0>, 0.22 Retro_Chrome(rgb <0.9,0.9,0.95>) }
  // torso
  sphere { 0,1 scale <0.72,0.95,0.5> translate <0,2.35,0> Retro_Chrome(rgb <0.9,0.9,0.95>) }
  // shoulders + arms
  sphere { <-0.66,2.85,0>, 0.24 Retro_Chrome(rgb <0.9,0.9,0.95>) }
  sphere { < 0.66,2.85,0>, 0.24 Retro_Chrome(rgb <0.9,0.9,0.95>) }
  cylinder { <-0.66,2.85,0>, <-1.02,1.45,0.15>, 0.16 Retro_Chrome(rgb <0.9,0.9,0.95>) }
  cylinder { < 0.66,2.85,0>, < 1.02,1.45,0.15>, 0.16 Retro_Chrome(rgb <0.9,0.9,0.95>) }
  // neck + head
  cylinder { <0,3.0,0>, <0,3.25,0>, 0.16 Retro_Chrome(rgb <0.9,0.9,0.95>) }
  sphere { <0,3.6,0>, 0.45 Retro_Chrome(rgb <0.9,0.9,0.95>) }
  rotate y*Spin
}

Retro_Camera(<-3.0,3.0,-6.0>, <0,2.2,0>)
