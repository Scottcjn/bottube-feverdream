// demo_chrome_sunset.pov — proof scene for the retro90s library.
// The quintessential mid-90s raytrace: chrome spheres + glass,
// infinite checker floor, fractal terrain, sunset gradient sky.

#include "retro90s.inc"

Retro_Sky_Gradient(
  rgb <0.15,0.20,0.55>,   // top: deep twilight blue
  rgb <1.00,0.55,0.25>)   // horizon: hot sunset orange

Retro_Sun(<-0.6, 0.7, -0.4>, rgb <1.0,0.92,0.78>)

// Fractal Bryce-style mountains in the distance
Retro_Fractal_Terrain(14, 22, Retro_Terrain_Texture())

// Iconic reflective checkerboard, pushed back behind the terrain edge
plane {
  y, 0.01
  pigment { checker color rgb <0.9,0.9,0.95> color rgb <0.08,0.08,0.12> }
  finish { ambient 0.12 diffuse 0.6 reflection { 0.35 } phong 0.4 phong_size 60 }
  clipped_by { box { <-60,-1,-2>, <60,1,40> } }
}

// Hero chrome sphere
sphere { <0,2.2,6>, 2.2 Retro_Chrome(rgb <0.85,0.88,0.95>) }

// Colored glass sphere
sphere { <-4,1.6,9>, 1.6 Retro_Glass(rgb <0.2,0.9,0.6>) }

// Glossy red plastic torus — that hard hotspot
torus { 1.6, 0.5
  Retro_Plastic(rgb <0.9,0.12,0.12>)
  rotate x*70 translate <4.5,1.4,8>
}

Retro_Orbit_Camera(11, 4.5, <0,2,5>)
