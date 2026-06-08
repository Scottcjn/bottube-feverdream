// glass_city_skyline.pov — a horizon-line of glass-and-chrome skyscrapers
// against a sunset, the canonical late-90s "futuristic city" hero shot
// (think Windows XP Bliss era, or any early DVD-menu backdrop). The city
// is just boxes with Retro_Glass / Retro_Chrome tints, but a couple of
// emissive strips per building make it read as "lit windows at dusk".
// Hand-authored. Re-dress: change the building heights/widths and the
// window-tint colors.
#include "retro90s.inc"

#local SKY_TOP   = rgb <0.08, 0.10, 0.32>;
#local SKY_HORIZ = rgb <0.95, 0.45, 0.30>;
Retro_Sky_Gradient(SKY_TOP, SKY_HORIZ)
Retro_Sun(<0.5, 0.30, -0.7>, rgb <1.15, 0.85, 0.55>)

// Distant haze plane — a thin band of warm gray-blue just above the horizon
// to imply atmospheric scattering.  Cheap fake, but it sells depth.
plane { <0, 1, 0>, -1.4
  texture {
    pigment { color rgb <0.50, 0.45, 0.55> }
    finish  { ambient 0.9 diffuse 0.0 }
    no_shadow
  }
}

// --- Building macros -------------------------------------------------------
#macro GlassTower(cx, base_w, base_d, h, tint)
  box { <cx - base_w/2, 0, 0>, <cx + base_w/2, h, base_d> }
  texture { Retro_Glass(tint) }
#end
#macro ChromeTower(cx, base_w, base_d, h, tint)
  box { <cx - base_w/2, 0, 0>, <cx + base_w/2, h, base_d> }
  texture { Retro_Chrome(tint) }
#end
// Lit "windows" — a series of thin emissive strips that read as
// the building's facade pattern.
#macro Windows(cx, base_w, base_d, h, n_floors, glow_tint)
  #local strip_h = h / (n_floors * 2);
  #local strip_gap = strip_h;
  #local i = 0;
  #while (i < n_floors)
    box { <cx - base_w/2 + 0.05, i * 2 * strip_h, base_d - 0.02>,
          <cx + base_w/2 - 0.05, i * 2 * strip_h + strip_h, base_d> }
    texture { pigment { glow 1 } finish { ambient 2.0 * glow_tint } no_shadow }
    #local i = i + 1;
  #end
#end

// --- The skyline -----------------------------------------------------------
// Three clusters: a tall glass hero in the center, two chrome shoulder
// buildings, and a low glass canyon in front.  All on the same horizon line.

union {
  // Hero (center)
  GlassTower(0.0, 1.4, 1.4, 8.0, rgb <0.75, 0.85, 1.00>)
  Windows(0.0, 1.4, 1.4, 8.0, 24, rgb <1.0, 0.85, 0.55>)

  // Left shoulder — chrome, slightly shorter
  ChromeTower(-3.0, 1.0, 1.0, 6.0, rgb <0.85, 0.90, 0.98>)
  Windows(-3.0, 1.0, 1.0, 6.0, 18, rgb <0.65, 0.85, 1.0>)

  // Right shoulder — glass, a touch taller
  GlassTower(3.2, 1.1, 1.1, 6.8, rgb <0.90, 0.65, 0.80>)
  Windows(3.2, 1.1, 1.1, 6.8, 20, rgb <1.0, 0.55, 0.30>)

  // Foreground canyon — five low glass buildings
  GlassTower(-6.5, 0.7, 0.7, 2.4, rgb <0.55, 0.65, 0.95>)
  GlassTower(-5.0, 0.6, 0.6, 1.8, rgb <0.95, 0.65, 0.55>)
  GlassTower(-3.5, 0.5, 0.5, 1.4, rgb <0.65, 0.95, 0.85>) translate <0,0,2>
  GlassTower(5.5, 0.6, 0.6, 2.0, rgb <0.95, 0.85, 0.55>)
  GlassTower(6.8, 0.5, 0.5, 1.5, rgb <0.55, 0.95, 0.95>)

  translate <0, 0, -8>
}

// Reflective plaza floor — checker, fading to a soft horizon via pigment.
plane { <0, 1, 0>, 0
  texture {
    Retro_Checker_Floor(rgb <0.18, 0.20, 0.35>, rgb <0.05, 0.06, 0.12>, 0.25)
    pigment {
      gradient y
      color_map {
        [0.0 color rgb <0.0, 0.0, 0.0>]
        [0.6 color rgb <0.0, 0.0, 0.0, 0.5>]   // fade to transparent at horizon
      }
    }
  }
}

Retro_Camera(<0, 1.6, 6>, <0, 4.0, -2>)
