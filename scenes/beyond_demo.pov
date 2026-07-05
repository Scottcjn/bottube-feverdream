// ============================================================
//  beyond_demo.pov — exercises every macro in beyond90s.inc
//  A dusk desert product-viz tableau: three-stop sunset sky,
//  mesa silhouettes, early stars, a glowing amber planet, and
//  a gold hero figure on a "3D PERSPECTIVE VIEW" plinth.
// ============================================================
#include "retro90s.inc"
#include "beyond90s.inc"

// --- the signature three-stop sunset sky -------------------
Beyond_Sunset_Sky(rgb <0.10, 0.05, 0.35>, rgb <1.00, 0.30, 0.45>, rgb <1.00, 0.85, 0.30>)

// --- early stars coming out at dusk ------------------------
Beyond_Starfield(0.20, rgb <1.00, 0.95, 0.85>)

// --- dark buttes ringing the far horizon -------------------
Beyond_Mesa_Ring(rgb <0.09, 0.04, 0.10>, 14, 260, 26)

// --- desert floor -------------------------------------------
plane { y, 0 Retro_Plastic(rgb <0.50, 0.28, 0.15>) }

// --- glowing amber planet hanging in the sky ---------------
object { Beyond_Planet(9, rgb <1.00, 0.62, 0.20>, rgb <1.00, 0.45, 0.15>) translate <-26, 32, 70> }

// --- turntable plinth standing on the floor (top at y=1.8) --
object { Beyond_Plinth(6, rgb <0.15, 0.45, 0.90>) }

// --- gold hero figure posing on the plinth top --------------
union {
  cone   { <0, 0, 0>, 1.4, <0, 4.4, 0>, 0.6 }   // body
  sphere { <0, 6.2, 0>, 2.0 }                    // head/orb
  torus  { 3.1, 0.45 translate <0, 6.2, 0> }     // halo ring
  Beyond_Gold(rgb <1, 1, 1>)
  translate <0, 6*0.30, 0>                       // up onto the plinth top
}

// --- low warm sun raking in from behind the mesas ----------
Retro_Sun(<0.4, 0.15, 1.0>, rgb <1.00, 0.72, 0.45>)

// --- hero camera --------------------------------------------
Retro_Orbit_Camera(25, 6.0, <0, 4.0, 0>)
