// glass_city.pov — refractive glass skyline on a reflective checkerboard.
// Template for the feverdream generator to re-dress.
#include "retro90s.inc"

Retro_Sky_Gradient(rgb <0.08,0.10,0.30>, rgb <0.9,0.45,0.7>)
Retro_Sun(<0.6,0.7,-0.3>, rgb <1.0,0.95,0.85>)
Retro_Checker_Floor(rgb <0.9,0.9,0.95>, rgb <0.06,0.06,0.10>, 0.45)

// Retro_Glass already emits texture{} + interior{}, so apply it inline per box.
box { <-6,0,6>, <-4,7,8>    Retro_Glass(rgb <0.4,0.9,0.8>) }
box { <-3,0,9>, <-1,11,11>  Retro_Glass(rgb <0.4,0.9,0.8>) }
box { < 0,0,7>, < 2,9,9>    Retro_Glass(rgb <0.5,0.8,1.0>) }
box { < 3,0,10>,< 5,6,12>   Retro_Glass(rgb <0.4,0.9,0.8>) }
box { < 5.5,0,7>,<7.5,13,9> Retro_Glass(rgb <0.6,0.9,0.7>) }
sphere { <0,5,3>, 1.4 Retro_Chrome(rgb <0.9,0.9,1.0>) }

Retro_Camera(<0,4,-4>, <0,5,8>)
