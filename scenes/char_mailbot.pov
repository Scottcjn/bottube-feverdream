// AI-generated blob character: mailman
#include "retro90s.inc"
#include "retro90s_textures.inc"
Retro_Sky_Gradient(rgb <0.35,0.5,0.85>, rgb <0.7,0.92,1.0>)
Retro_Sun(<-0.4,0.8,-0.35>, rgb <1.0,0.98,0.92>)
Retro_Checker_Floor(rgb <0.85,0.88,0.95>, rgb <0.3,0.5,0.78>, 0.18)
blob {
  threshold 0.6
  sphere { <0,3.0,0>, 0.8, 1.2 }
  sphere { <0,2.5,0>, 0.6, 1.1 }
  cylinder { <0,3.25,0>, <0,3.75,0>, 0.2, 0.9 }
  cylinder { <-0.5,3.3,0>, <-1.05,2.45,0.1>, 0.28, 0.9 }
  cylinder { <0.5,3.3,0>, <1.05,2.45,0.1>, 0.28, 0.9 }
  sphere { <-1.1,2.55,0.1>, 0.32, 1.0 }
  sphere { <1.1,2.55,0.1>, 0.32, 1.0 }
  cylinder { <-0.3,2.3,0>, <-0.42,1.4,0>, 0.32, 0.9 }
  cylinder { <0.3,2.3,0>, <0.42,1.4,0>, 0.32, 0.9 }
  sphere { <0,1.55,0.1>, 0.32, 1.0 }
  sphere { <0,0.55,0.1>, 0.32, 1.0 }
  cylinder { <-0.2,0.3,0>, <-0.32,0.05,0>, 0.32, 0.9 }
  cylinder { <0.2,0.3,0>, <0.32,0.05,0>, 0.32, 0.9 }
  sphere { <-1.1,-0.25,0.1>, 0.32, 1.0 }
  sphere { <1.1,-0.25,0.1>, 0.32, 1.0 }
  cylinder { <-0.3,-0.4,0>, <-0.42,-0.55,0.1>, 0.32, 0.9 }
  cylinder { <0.3,-0.4,0>, <0.42,-0.55,0.1>, 0.32, 0.9 }
  sphere { <0,-1.25,0.1>, 0.32, 1.0 }
  sphere { <0,-2.25,0.1>, 0.32, 1.0 }
  Tex_Skin(rgb <0.2,0.3,0.4>)
}
sphere { <-0.2,3.35,-0.5>, 0.16 texture { pigment{rgb 1} finish{phong 0.6 ambient 0.45} } }
sphere { <-0.2,3.35,-0.628>, 0.08 texture { pigment{rgb 0.04} } }
sphere { <0.2,3.35,-0.5>, 0.16 texture { pigment{rgb 1} finish{phong 0.6 ambient 0.45} } }
sphere { <0.2,3.35,-0.628>, 0.08 texture { pigment{rgb 0.04} } }
Retro_Camera(<-2.6,2.8,-5.6>, <0,1.7,0>)
