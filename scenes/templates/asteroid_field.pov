// asteroid_field.pov — chrome/glass asteroids tumbling through deep space.
// Generic: just spherical rocks with an irregular displacement and a couple
// of emission-bands so they read as "alien" instead of "balls". The look is
// the 1998 "asteroid belt flythrough" trope (Goldeneye, Starsiege, you name
// it). Hand-authored. Re-dress: change the displacement, the rock tint, the
// starfield density.
#include "retro90s.inc"

// --- Starfield -------------------------------------------------------------
// 200 background points on the far sphere. Cheap on CPU, fine for the
// "non-blank space" feel.
#local STAR_R = 50;
sphere { <0, 0, 0>, STAR_R
  texture {
    pigment {
      granite
      color_map {
        [0.0 rgb <0, 0, 0>]
        [0.9 rgb <0, 0, 0>]
        [1.0 rgb <0.9, 0.95, 1.0>]
      }
      scale 0.6
    }
    finish { ambient 1.0 diffuse 0 }
    no_shadow
    inverse
  }
}

// A pair of distant nebula "clouds" — a big gradient plane far behind the
// action to add color and avoid the pitch-black void.  Placed far enough
// that they always read as background, not as a wall.
plane { <0, 0, 1>, -45
  texture {
    pigment {
      gradient <0.3, 0.4, 0>
      color_map {
        [0.00 rgb <0.05, 0.02, 0.12>]
        [0.40 rgb <0.30, 0.05, 0.25>]   // magenta cloud
        [0.55 rgb <0.04, 0.04, 0.18>]
        [0.80 rgb <0.10, 0.22, 0.45>]   // blue cloud
        [1.00 rgb <0.02, 0.02, 0.10>]
      }
      scale 8
    }
    finish { ambient 0.9 diffuse 0 }
    no_shadow
  }
}

// --- Asteroids -------------------------------------------------------------
#macro Rock(cx, cy, cz, r, tint)
  sphere { <cx, cy, cz>, r
    texture {
      Retro_Chrome(tint)
      pigment {
        granite
        color_map {
          [0.0 rgb tint * 0.45]
          [0.7 rgb tint]
          [1.0 rgb tint * 1.30]
        }
        scale 0.35 * r
      }
    }
    scale <1.0, 0.85, 1.0>   // squashed — reads as "tumbling rock" not "ball"
    rotate <clock * 18, clock * 35, 0>
  }
#end

// 9 asteroids scattered through the camera frustum, in 3 depth layers.
union {
  // Foreground (large, very close)
  Rock( -2.5,  1.2,  2.0, 1.0, rgb <0.70, 0.50, 0.40>)
  Rock(  3.0, -0.8,  1.5, 0.8, rgb <0.55, 0.60, 0.75>)

  // Mid-ground
  Rock(  0.5,  0.3, -1.0, 0.6, rgb <0.85, 0.85, 0.95>)
  Rock( -1.5, -1.5, -1.5, 0.7, rgb <0.45, 0.55, 0.45>)
  Rock(  2.5,  2.0, -2.0, 0.5, rgb <0.95, 0.70, 0.55>)
  Rock( -3.5,  0.0, -2.5, 0.4, rgb <0.60, 0.60, 0.85>)

  // Background (small, distant)
  Rock(  1.0,  3.0, -8.0, 0.3, rgb <0.80, 0.80, 0.80>)
  Rock( -2.0, -2.5, -9.0, 0.4, rgb <0.50, 0.65, 0.85>)
  Rock(  4.0,  1.0, -10.0, 0.35, rgb <0.85, 0.65, 0.55>)

  // Subtle "alien" emission bands wrapping the mid-ground rocks, so they
  // don't read as plain chrome balls in deep space.
  object {
    Rock(0.5, 0.3, -1.0, 0.62, rgb <0.0, 0.0, 0.0>)
    texture { pigment { glow 1 } finish { ambient rgb <0.0, 0.6, 0.9> * 1.2 } no_shadow }
  }
}

Retro_Camera(<0, 0, 6>, <0, 0, -1>)
