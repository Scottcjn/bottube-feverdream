#include "retro90s.inc"

// Sky gradient
Retro_Sky_Gradient(rgb <0.15,0.2,0.55>, rgb <1.0,0.55,0.25>)

// Sun
Retro_Sun(<-0.6,0.7,-0.4>, rgb <1.0,0.92,0.78>)

// Checkerboard floor
Retro_Checker_Floor(rgb <0.9,0.9,0.95>, rgb <0.08,0.08,0.12>, 0.35)

// Fractal terrain
Retro_Fractal_Terrain(8, 22, Retro_Terrain_Texture())

// Giant chrome dolphin
sphere { <0,5,20>, 5 Retro_Chrome(rgb <0.85,0.88,0.95>) }

// Glass pyramids
box { <-5,1,0>, <5,3,0> scale 1 Retro_Glass(rgb <0.2,0.9,0.6>) }

// Reflective checkerboard floor
Retro_Checker_Floor(rgb <0.9,0.9,0.95>, rgb <0.08,0.08,0.12>, 0.35)

// Camera
Retro_Camera(<0,5,10>, <0,2,0>)
