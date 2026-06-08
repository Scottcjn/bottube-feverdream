// warcraft_orc.pov — a generic hulking green orc grunt with a battle-axe, in the
// chunky early-90s fantasy-CGI style (Warcraft 1 era, 1994). No trademarks.
#include "retro90s.inc"
#include "retro90s_textures.inc"

Retro_Sky_Gradient(rgb <0.22,0.26,0.36>, rgb <0.62,0.55,0.40>)   // moody dusk
Retro_Sun(<-0.5,0.7,-0.4>, rgb <1.0,0.85,0.6>)

// grassy/dirt ground (flat — the orc stands on it)
plane { y, 0 Tex_Worn(rgb <0.24,0.42,0.16>, rgb <0.30,0.24,0.12>) }
#declare Steel = Tex_BrushedMetal(rgb <0.60,0.63,0.70>)

// --- the orc grunt (hulking hunched blob body) ---
union {
  blob {
    threshold 0.6
    sphere { <0,2.05,0.05>, 0.98, 1.25 }    // broad shoulders / upper torso
    sphere { <0,1.45,0>, 0.82, 1.0 }        // gut
    sphere { <-0.9,2.15,0>, 0.52, 1.0 }     // shoulder bulges
    sphere { < 0.9,2.15,0>, 0.52, 1.0 }
    cylinder { <-0.9,2.0,0>, <-1.18,0.85,0.2>, 0.33, 0.9 }   // left arm
    cylinder { < 0.9,2.0,0>, < 1.05,1.05,0.3>, 0.35, 0.9 }   // right arm
    sphere { <-1.22,0.72,0.24>, 0.37, 1.0 } // fists
    sphere { < 1.08,0.95,0.34>, 0.38, 1.0 }
    cylinder { <-0.42,1.0,0>, <-0.48,0.12,0>, 0.36, 0.9 }    // legs
    cylinder { < 0.42,1.0,0>, < 0.48,0.12,0>, 0.36, 0.9 }
    Tex_Worn(rgb <0.32,0.52,0.22>, rgb <0.22,0.40,0.15>)     // worn green orc hide
  }
  // brown loincloth + shoulder pad
  superellipsoid { <0.4,0.3> scale <0.7,0.34,0.5> translate <0,1.05,0> Tex_Worn(rgb <0.35,0.22,0.10>, rgb <0.25,0.15,0.07>) }
  sphere { <-0.95,2.45,0>, 0.42 Tex_Worn(rgb <0.40,0.26,0.13>, rgb <0.28,0.17,0.08>) } // rounded shoulder pad
  sphere { < 0.95,2.45,0>, 0.40 Tex_Worn(rgb <0.40,0.26,0.13>, rgb <0.28,0.17,0.08>) }
  // head (low, hunched), heavy brow, red eyes, tusks
  sphere { <0,2.55,-0.1>, 0.5 Tex_Skin(rgb <0.34,0.54,0.24>) }
  superellipsoid { <0.5,0.4> scale <0.45,0.12,0.2> translate <0,2.72,-0.42> Tex_Skin(rgb <0.30,0.48,0.20>) } // brow ridge
  sphere { <-0.17,2.55,-0.46>, 0.07 texture { pigment{rgb<1,0.7,0.1>} finish{ambient 1.4} } }  // glowing eyes
  sphere { < 0.17,2.55,-0.46>, 0.07 texture { pigment{rgb<1,0.7,0.1>} finish{ambient 1.4} } }
  cone { <-0.16,2.34,-0.46>, 0.06, <-0.18,2.62,-0.5>, 0.0 texture { pigment{rgb 0.95} } } // tusks up
  cone { < 0.16,2.34,-0.46>, 0.06, < 0.18,2.62,-0.5>, 0.0 texture { pigment{rgb 0.95} } }
  // --- battle-axe in the right fist ---
  cylinder { <1.45,0.2,0.34>, <1.45,3.0,0.34>, 0.08 Tex_Worn(rgb <0.35,0.22,0.10>, rgb <0.2,0.12,0.06>) } // haft
  // chunky double-bladed axe head: wide slab + tapered cutting edges
  box { <1.05,2.45,0.18>, <1.85,3.05,0.5> texture { Steel } }
  cone { <1.05,2.75,0.34>, 0.30, <0.78,2.75,0.34>, 0.0 texture { Steel } }   // left blade point
  cone { <1.85,2.75,0.34>, 0.30, <2.12,2.75,0.34>, 0.0 texture { Steel } }   // right blade point
  cone { <1.45,3.05,0.34>, 0.10, <1.45,3.35,0.34>, 0.0 texture { Steel } }   // top spike
  translate <0,0,0>
}

Retro_Camera(<-3.6,2.6,-5.4>, <0.1,1.6,0>)
