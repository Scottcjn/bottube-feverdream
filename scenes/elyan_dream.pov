// elyan_dream.pov — "Chrome Cathedral at Dusk"
// The quintessential mid-90s fever dream: mirror chrome, refractive glass, a
// glowing ReBoot grid stretching to a fractal horizon under a hot sunset sky.
// Hand-authored for the Elyan Labs vintage-CGI channel. Orbit camera.

#include "retro90s.inc"

// Vivid dusk — bright enough that the chrome has a real sunset to mirror.
Retro_Sky_Gradient(
  rgb <0.22, 0.30, 1.00>,    // top: electric cobalt
  rgb <1.00, 0.66, 0.32>)    // horizon: hot orange sunset

// Strong warm key light so the chrome throws hard mirror highlights.
Retro_Sun(<-0.6, 0.55, -0.45>, rgb <1.0, 0.92, 0.74>)

// The glowing cyan ReBoot grid — the floor of the dream, stretching to the
// sunset horizon. No terrain: the chrome mirrors pure sky and grid, the way the
// iconic mid-90s "infinite grid" renders did.
Retro_Grid_Floor(rgb <0.20, 0.95, 1.0>, rgb <0.02, 0.03, 0.08>, 1.5)

// --- the hero cluster, centered near the origin so it stays framed ----------

// Big mirror-chrome sphere: the altar of the cathedral.
sphere { <0, 2.3, 5.0>, 2.3 Retro_Chrome(rgb <0.86, 0.90, 1.0>) }

// A second, smaller chrome sphere nesting against it.
sphere { <2.6, 1.1, 3.6>, 1.1 Retro_Chrome(rgb <1.0, 0.92, 0.82>) }

// Emerald refractive glass sphere catching the sunset through it.
sphere { <-3.4, 1.5, 6.6>, 1.5 Retro_Glass(rgb <0.15, 0.95, 0.60>) }

// Sapphire glass teardrop, small and bright.
sphere { <-1.2, 0.75, 2.4>, 0.75 Retro_Glass(rgb <0.25, 0.45, 1.0>) }

// The hard-hotspot plastic torus — pure 1994 demo-reel energy.
torus { 1.7, 0.42
  Retro_Plastic(rgb <1.0, 0.15, 0.35>)
  rotate x*68 rotate y*20 translate <3.6, 1.5, 6.8>
}

// A tall thin chrome pillar for vertical interest and long reflections.
cylinder { <-5.0, 0, 8.0>, <-5.0, 5.2, 8.0>, 0.35
  Retro_Chrome(rgb <0.80, 0.85, 0.95>) }

// Slowly orbit the whole altar, pulled back so the composition breathes.
Retro_Orbit_Camera(15, 5.0, <0, 2.0, 5.0>)
