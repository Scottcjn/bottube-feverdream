#include "retro90s.inc"
#include "warcraft_rigged.inc"
Retro_Sky_Gradient(rgb <0.30,0.42,0.72>, rgb <0.75,0.65,0.50>)
Retro_Sun(<-0.45,0.8,-0.4>, rgb <1.0,0.90,0.70>)
Retro_Checker_Floor(rgb <0.30,0.45,0.18>, rgb <0.24,0.36,0.14>, 0.05)
// bigger warhorse, facing +x (-90)
object { Horse(<0,0,0>, -90, 0) scale 1.4 }
// knight seated on the saddle: legs hang forward-down, right arm couches the sword forward
SkeletonFootman(<0.1,1.55,0>, -90, 8, 0,  -48,16,28,  -82,5,6,  40,-48, 40,-48)
Retro_Camera(<-3.8,3.6,-6.0>, <0.4,2.4,0>)
