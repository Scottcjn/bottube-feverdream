// AI-generated blob gremlin — animated idle (bounce + turn) via clock.
#include "retro90s.inc"
#include "retro90s_textures.inc"
Retro_Sky_Gradient(rgb <0.35,0.5,0.85>, rgb <0.7,0.92,1.0>)
Retro_Sun(<-0.4,0.8,-0.35>, rgb <1.0,0.98,0.92>)
Retro_Checker_Floor(rgb <0.85,0.88,0.95>, rgb <0.3,0.5,0.78>, 0.18)

#declare Hop = abs(sin(clock*4*pi))*0.30;
#declare Turn = sin(clock*2*pi)*26;

union {
  blob {
    threshold 0.6
    sphere { <0,2.6,0>, 0.8, 1.1 }
    sphere { <0,2.2,0>, 0.7, 1.0 }
    cylinder { <-0.5,2.5,0>, <-1.05,1.55,0.1>, 0.3, 1.0 }
    cylinder { <0.5,2.5,0>, <1.05,1.55,0.1>, 0.3, 1.0 }
    sphere { <-1.1,1.45,0.1>, 0.32, 1.0 }
    sphere { <1.1,1.45,0.1>, 0.32, 1.0 }
    cylinder { <-0.3,1.2,0>, <-0.42,0.3,0>, 0.32, 0.9 }
    cylinder { <0.3,1.2,0>, <0.42,0.3,0>, 0.32, 0.9 }
    sphere { <-0.42,0.28,0.05>, 0.34, 1.0 }
    sphere { <0.42,0.28,0.05>, 0.34, 1.0 }
    cylinder { <0,2.55,0>, <0,2.95,0>, 0.3, 1.0 }
    Tex_Skin(rgb <0.45,0.62,0.28>)
  }
  // googly eyes (three — it IS a three-eyed gremlin)
  sphere { <-0.26,3.05,-0.52>, 0.16 texture { pigment{rgb 1} finish{phong 0.6 ambient 0.45} } }
  sphere { < 0.26,3.05,-0.52>, 0.16 texture { pigment{rgb 1} finish{phong 0.6 ambient 0.45} } }
  sphere { <0,3.35,-0.42>, 0.14 texture { pigment{rgb 1} finish{phong 0.6 ambient 0.45} } }
  sphere { <-0.26,3.05,-0.66>, 0.08 texture { pigment{rgb 0.04} } }
  sphere { < 0.26,3.05,-0.66>, 0.08 texture { pigment{rgb 0.04} } }
  sphere { <0,3.35,-0.55>, 0.07 texture { pigment{rgb 0.04} } }
  torus { 0.14,0.03 rotate x*74 translate <0,2.75,-0.5> texture { pigment{rgb<0.2,0.1,0.1>} } }
  rotate y*Turn
  translate <0, Hop, 0>
}

Retro_Camera(<-2.6,2.9,-5.6>, <0,1.9,0>)
