// deep_space.pov — "Probe at the Amber Giant"
// The Voyager-reference frame: a huge glowing amber planet hanging in a
// near-black sky with a faint colored horizon glow, a thin tilted ring, a
// scatter of stars, and a little chrome-and-plastic space probe (dish + body +
// antenna) drifting in a slow orbit. The sun sits toward the camera so the
// probe catches a bright rim even against the dark sky. Orbit camera.

#include "retro90s.inc"

// Deep-space sky: near-black overhead fading to a faint amber horizon glow that
// echoes the planet — keeps the frame from going flat black.
Retro_Sky_Gradient(
  rgb <0.01, 0.01, 0.04>,    // top: near-black space
  rgb <0.20, 0.09, 0.03>)    // horizon: dim amber wash

// Key light placed toward the camera side so the chrome/plastic probe gets a
// bright rim even though the sky is dark (chrome reads dark in space — the rim
// is what sells it).
Retro_Sun(<0.35, 0.25, 0.9>, rgb <1.0, 0.9, 0.72>)

// --- starfield: a scatter of tiny emissive spheres flung out on a big shell.
//     Deterministic pseudo-random placement so it renders the same every frame. -
#declare StarTex = texture {
  pigment { color rgb <1, 1, 1> }
  finish { ambient 1.0 diffuse 0 }   // self-lit pin-pricks
}
#declare s = 0;
#while (s < 140)
  #declare sa = mod(s * 47, 360);
  #declare sb = mod(s * 89, 180) - 90;
  #declare sr = 95 + mod(s * 13, 40);
  #declare sx = sr * cos(radians(sb)) * cos(radians(sa));
  #declare sy = sr * sin(radians(sb));
  #declare sz = sr * cos(radians(sb)) * sin(radians(sa));
  sphere { <sx, sy, sz>, 0.30 + mod(s, 3) * 0.14 texture { StarTex } }
  #declare s = s + 1;
#end

// --- the amber giant: a big glowing planet. High ambient makes it read as
//     self-lit; a banded turbulent pigment gives it a gas-giant surface. -------
sphere {
  <-24, 5, -15>, 13
  pigment {
    gradient y
    turbulence 0.35 octaves 4 lambda 2.2
    color_map {
      [0.0 color rgb <0.85, 0.42, 0.10>]
      [0.4 color rgb <1.00, 0.68, 0.28>]
      [0.6 color rgb <0.78, 0.34, 0.08>]
      [1.0 color rgb <1.00, 0.80, 0.42>]
    }
    scale <18, 9, 18>
  }
  finish { ambient 0.85 diffuse 0.35 phong 0.15 phong_size 8 }
}

// A faint tilted ring around the planet — thin torus, gently glowing.
torus {
  17, 0.5
  pigment { color rgbf <0.95, 0.72, 0.4, 0.45> }
  finish { ambient 0.6 diffuse 0.25 }
  scale <1, 0.12, 1>
  rotate <22, 0, -14>
  translate <-24, 5, -15>
}

// --- the space probe: dish + body + antenna, built from primitives and wrapped
//     in a union so it drifts as one. Kept near the origin for the orbit frame. -
union {
  // main body: a stubby chrome octagonal bus (short cylinder)
  cylinder { <0, 0, 0>, <0, 1.1, 0>, 0.55 Retro_Chrome(rgb <0.86, 0.9, 1.0>) }
  // gold-foil cap plate (era loved gold spacecraft foil)
  cylinder { <0, 1.1, 0>, <0, 1.24, 0>, 0.58 Retro_Chrome(rgb <1.0, 0.82, 0.35>) }
  // high-gain dish: a shallow open cone facing forward
  cone { <0, 0.55, 0>, 0.0, <0, 0.55, 1.7>, 1.25
    open Retro_Chrome(rgb <0.92, 0.94, 1.0>) }
  // dish feed on a little rod at the focus
  cylinder { <0, 0.55, 1.7>, <0, 0.55, 0.9>, 0.05 Retro_Plastic(rgb <0.9, 0.9, 0.9>) }
  sphere { <0, 0.55, 0.9>, 0.1 Retro_Plastic(rgb <1.0, 0.25, 0.2>) }
  // long whip antenna out the back with a bright plastic tip
  cylinder { <0, 0.55, 0>, <-0.2, 0.55, -2.4>, 0.04 Retro_Chrome(rgb <0.8, 0.85, 0.95>) }
  sphere { <-0.2, 0.55, -2.4>, 0.09 Retro_Plastic(rgb <0.2, 0.9, 1.0>) }
  // a boxy instrument pod slung under the bus
  box { <-0.35, -0.45, -0.3>, <0.35, 0.0, 0.3> Retro_Plastic(rgb <0.9, 0.85, 0.2>) }
  // two stubby RTG booms out the sides, plastic
  cylinder { <0.55, 0.55, 0>, <1.5, 0.75, 0>, 0.07 Retro_Plastic(rgb <0.75, 0.78, 0.8>) }
  cylinder { <-0.55, 0.55, 0>, <-1.5, 0.35, 0>, 0.07 Retro_Plastic(rgb <0.75, 0.78, 0.8>) }

  // give it a jaunty fixed tilt, then let it slowly tumble/drift with the clock
  rotate <18, 0, 12>
  rotate y * (clock * 220)
  translate <0, 1.0, 0>
}

// Slow orbit around the probe, with the amber giant swinging through frame.
Retro_Orbit_Camera(11, 3.4, <0, 1.0, 0>)
