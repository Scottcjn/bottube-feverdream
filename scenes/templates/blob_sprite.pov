// blob_sprite.pov — a smooth organic character built with metaballs (blob),
// the 1982 Blinn technique: weighted spheres/cylinders fuse into ONE continuous
// skin. The old-school, self-contained way to get smooth real geometry — no
// sculpting tool, no mesh-gen API. Generic friendly sprite.
#include "retro90s.inc"
#include "retro90s_textures.inc"

Retro_Sky_Gradient(rgb <0.30,0.45,0.85>, rgb <0.70,0.92,1.0>)
Retro_Sun(<-0.4,0.8,-0.35>, rgb <1.0,0.98,0.92>)
Retro_Checker_Floor(rgb <0.85,0.88,0.95>, rgb <0.25,0.45,0.75>, 0.18)

#declare BlueSkin = rgb <0.25,0.55,0.95>;
#declare Bob = sin(clock*2*pi)*0.10;

// the body — one fused blob skin
blob {
  threshold 0.6
  // torso + belly
  sphere { <0, 2.05, 0>, 1.0, 1.1 }
  sphere { <0, 1.45, 0>, 0.85, 1.0 }
  // neck -> head
  cylinder { <0, 2.4, 0>, <0, 2.85, 0>, 0.32, 1.0 }
  sphere { <0, 3.05, 0>, 0.62, 1.2 }
  // shoulders + arms (fuse smoothly into torso)
  cylinder { <-0.5, 2.45, 0>, <-1.05, 1.55, 0.1>, 0.30, 0.9 }
  cylinder { < 0.5, 2.45, 0>, < 1.05, 1.55, 0.1>, 0.30, 0.9 }
  sphere { <-1.1, 1.45, 0.12>, 0.34, 1.0 }   // hands
  sphere { < 1.1, 1.45, 0.12>, 0.34, 1.0 }
  // hips + legs
  cylinder { <-0.32, 1.2, 0>, <-0.42, 0.3, 0>, 0.34, 0.9 }
  cylinder { < 0.32, 1.2, 0>, < 0.42, 0.3, 0>, 0.34, 0.9 }
  sphere { <-0.42, 0.22, 0.05>, 0.36, 1.0 }  // feet
  sphere { < 0.42, 0.22, 0.05>, 0.36, 1.0 }
  Tex_Skin(BlueSkin)
  translate <0, Bob, 0>
}

// eyes sit on the smooth head
#declare EW = texture { pigment { rgb 1 } finish { phong 0.6 ambient 0.45 } }
sphere { <-0.22, 2.98+Bob, -0.46>, 0.17 texture { EW } }
sphere { < 0.22, 2.98+Bob, -0.46>, 0.17 texture { EW } }
sphere { <-0.22, 2.98+Bob, -0.58>, 0.085 texture { pigment { rgb 0.04 } } }
sphere { < 0.22, 2.98+Bob, -0.58>, 0.085 texture { pigment { rgb 0.04 } } }
torus { 0.16,0.03 rotate x*74 translate <0,2.62+Bob,-0.50> texture { pigment{rgb<0.1,0.2,0.4>} } }

Retro_Camera(<-2.6,2.8,-5.6>, <0,1.9,0>)
