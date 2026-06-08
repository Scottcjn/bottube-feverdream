// bryce_valley.pov — Bryce-style fractal valley at sunset with glass spheres.
// Template for the feverdream generator to re-dress (swap colors/objects).
#include "retro90s.inc"

Retro_Sky_Gradient(rgb <0.10,0.16,0.45>, rgb <1.0,0.50,0.20>)
Retro_Sun(<-0.5,0.6,-0.5>, rgb <1.0,0.9,0.72>)

Retro_Fractal_Terrain(11, 26, Retro_Terrain_Texture())
Retro_Checker_Floor(rgb <0.85,0.86,0.92>, rgb <0.10,0.10,0.16>, 0.3)

sphere { <-3,2,8>, 2.0 Retro_Glass(rgb <0.3,0.7,1.0>) }
sphere { < 3,1.5,7>, 1.5 Retro_Chrome(rgb <0.9,0.9,0.95>) }
sphere { < 0,1.0,5>, 1.0 Retro_Glass(rgb <1.0,0.4,0.6>) }

Retro_Camera(<0,3,-3>, <0,2,7>)
