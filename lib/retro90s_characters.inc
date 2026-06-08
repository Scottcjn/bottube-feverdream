// retro90s_characters.inc — smooth blob/metaball cast for Mainframe scenes,
// combining the 1982 blob technique (fused organic bodies) with Tier-1 textures.
// Reusable macros: Googly, BlobBinome1, BlobBinome0, BlobGuardian, BlobVirus.
#include "retro90s_textures.inc"

#macro Googly(ex,ey,ez,r)
  sphere { <ex,ey,ez>, r texture { pigment{rgb 1} finish{phong 0.6 ambient 0.45} } }
  sphere { <ex,ey,ez-r*0.82>, r*0.5 texture { pigment{rgb 0.04} } }
#end

#macro Smile(sx,sy,sz,r)
  torus { r,0.025 rotate x*72 translate <sx,sy,sz> texture { pigment{rgb<0.25,0.1,0.1>} } }
#end

// ---- Binome "1": one fused vertical blob body + face + stubby arms/feet ----
#macro BlobBinome1(cx, base)
  union {
    blob {
      threshold 0.6
      sphere { <0,1.4,0>, 0.55, 1.1 }
      sphere { <0,0.95,0>, 0.5, 1.0 }
      sphere { <0,0.5,0>, 0.48, 1.0 }
      cylinder { <0,0.5,0>, <0,1.6,0>, 0.34, 0.7 }
      cylinder { <-0.05,0.9,0>, <-0.5,0.7,0.05>, 0.12, 0.7 }
      cylinder { < 0.05,0.9,0>, < 0.5,0.7,0.05>, 0.12, 0.7 }
      Tex_Plastic(base)
    }
    Googly(-0.15,1.55,-0.42,0.14) Googly(0.15,1.55,-0.42,0.14)
    Smile(0,1.28,-0.42,0.11)
    translate <cx,0,0>
  }
#end

// ---- Binome "0": smooth ring body (torus) + face + arms ----
#macro BlobBinome0(cx, base)
  union {
    torus { 0.6, 0.30 rotate x*90 translate <0,1.05,0> Tex_Plastic(base) }
    cylinder { <-0.52,1.05,0>, <-0.78,0.78,0.05>, 0.10 Tex_Plastic(base) }
    cylinder { < 0.52,1.05,0>, < 0.78,0.78,0.05>, 0.10 Tex_Plastic(base) }
    Googly(-0.19,1.42,-0.34,0.14) Googly(0.19,1.42,-0.34,0.14)
    Smile(0,1.16,-0.34,0.10)
    translate <cx,0,0>
  }
#end

// ---- Guardian sprite (Bob-like): smooth blob suit-body + blue head/hands ----
#macro BlobGuardian(cx, sc, suit, accent)
  union {
    blob {
      threshold 0.6
      sphere { <0,1.15,0>, 0.62, 1.15 }
      sphere { <0,0.72,0>, 0.5, 0.95 }
      cylinder { <-0.34,1.32,0>, <-0.6,0.5,0.06>, 0.17, 0.85 }
      cylinder { < 0.34,1.32,0>, < 0.6,0.5,0.06>, 0.17, 0.85 }
      cylinder { <-0.2,0.72,0>, <-0.22,0.05,0>, 0.21, 0.9 }
      cylinder { < 0.2,0.72,0>, < 0.22,0.05,0>, 0.21, 0.9 }
      Tex_Plastic(suit)
    }
    sphere { <0,1.92,0>, 0.34 Tex_Skin(rgb <0.22,0.52,0.95>) }      // blue head
    sphere { <-0.62,0.46,0.10>, 0.15 Tex_Skin(rgb <0.22,0.52,0.95>) } // hands
    sphere { < 0.62,0.46,0.10>, 0.15 Tex_Skin(rgb <0.22,0.52,0.95>) }
    torus { 0.30,0.07 rotate x*90 translate <0,1.05,0> Tex_Plastic(accent) } // belt
    superellipsoid { <0.4,0.4> scale <0.16,0.11,0.16> translate <0,1.45,-0.42> Tex_Plastic(accent) } // emblem
    box { <-0.32,2.12,-0.30>, <0.32,2.24,0.30> Tex_Plastic(accent) }  // visor band
    Googly(-0.12,1.99,-0.30,0.10) Googly(0.12,1.99,-0.30,0.10)
    Smile(0,1.80,-0.29,0.12)
    scale sc translate <cx,0,0>
  }
#end

// ---- Virus (Megabyte-like): bulky brushed-metal blob + spikes + red eyes ----
#macro BlobVirus(cx)
  union {
    blob {
      threshold 0.6
      sphere { <0,1.9,0>, 0.95, 1.2 }
      sphere { <0,1.1,0>, 0.7, 0.95 }
      cylinder { <-0.55,2.0,0>, <-1.0,1.3,0.1>, 0.26, 0.85 }
      cylinder { < 0.55,2.0,0>, < 1.0,1.3,0.1>, 0.26, 0.85 }
      cylinder { <-0.34,1.0,0>, <-0.4,0.2,0>, 0.30, 0.9 }
      cylinder { < 0.34,1.0,0>, < 0.4,0.2,0>, 0.30, 0.9 }
      sphere { <0,2.7,0>, 0.5, 1.0 }
      Tex_BrushedMetal(rgb <0.6,0.66,0.78>)
    }
    cone { <-0.9,2.5,0>, 0.2, <-1.3,3.0,0>, 0.0 Tex_BrushedMetal(rgb <0.6,0.66,0.78>) }
    cone { < 0.9,2.5,0>, 0.2, < 1.3,3.0,0>, 0.0 Tex_BrushedMetal(rgb <0.6,0.66,0.78>) }
    sphere { <-0.17,2.78,-0.42>, 0.09 texture { pigment{rgb<1,0.1,0.05>} finish{ambient 1.8} } }
    sphere { < 0.17,2.78,-0.42>, 0.09 texture { pigment{rgb<1,0.1,0.05>} finish{ambient 1.8} } }
    cone { <-0.12,2.58,-0.46>, 0.05, <-0.12,2.42,-0.46>, 0.0 texture { pigment{rgb 1} } }
    cone { < 0.12,2.58,-0.46>, 0.05, < 0.12,2.42,-0.46>, 0.0 texture { pigment{rgb 1} } }
    translate <cx,0,0>
  }
#end
