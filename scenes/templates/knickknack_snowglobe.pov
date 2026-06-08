// knickknack_snowglobe.pov — a generic snowman trapped in a glass snowglobe,
// 1989-era CGI-short vibe. Snow swirls via `clock`. No trademarks.
#include "retro90s.inc"

Retro_Sky_Gradient(rgb <0.20,0.30,0.55>, rgb <0.75,0.80,0.95>)
Retro_Sun(<-0.5,0.8,-0.3>, rgb <1.0,0.97,0.9>)
Retro_Checker_Floor(rgb <0.6,0.45,0.3>, rgb <0.4,0.28,0.18>, 0.2)   // wood shelf

#declare EyeW = texture { pigment { rgb 1 } finish { phong 0.5 ambient 0.4 } }
#declare Coal = texture { pigment { rgb 0.03 } finish { phong 0.6 ambient 0.2 } }
#declare Snow = texture { pigment { rgb <0.98,0.98,1.0> } finish { ambient 0.4 diffuse 0.7 phong 0.3 } }
#declare Bob = sin(clock*2*pi)*0.06;

// red base
cylinder { <0,0,0>, <0,0.55,0>, 1.5 texture { pigment { rgb <0.7,0.1,0.1> } finish { ambient 0.3 diffuse 0.6 phong 0.7 } } }

// snowman inside (bobbing)
union {
  sphere { <0,0.95,0>, 0.85 texture { Snow } }          // body
  sphere { <0,1.95,0>, 0.55 texture { Snow } }          // head
  cone  { <0,1.95,-0.55>, 0.12, <0,1.9,-0.95>, 0.0 texture { pigment { rgb <1,0.5,0.1> } finish { ambient 0.35 } } } // nose
  sphere { <-0.20,2.05,-0.45>, 0.10 texture { EyeW } }
  sphere { < 0.20,2.05,-0.45>, 0.10 texture { EyeW } }
  sphere { <-0.20,2.05,-0.52>, 0.05 texture { Coal } }
  sphere { < 0.20,2.05,-0.52>, 0.05 texture { Coal } }
  sphere { <0,1.4,-0.55>, 0.07 texture { Coal } }       // button
  cylinder { <0.0,1.45,0>, <0.9,1.9,0.1>, 0.04 texture { pigment { rgb <0.4,0.25,0.12> } } }  // stick arm
  cylinder { <0.0,1.45,0>, <-0.9,1.9,0.1>, 0.04 texture { pigment { rgb <0.4,0.25,0.12> } } }
  translate <0, 0.55+Bob, 0>
}

// swirling snow
union {
  #declare i = 0;
  #while (i < 16)
    sphere { <1.0*sin(i*1.3), 1.0+mod(i*0.7,2.2), 1.0*cos(i*2.1)>, 0.045 texture { Snow } }
    #declare i = i + 1;
  #end
  rotate y*(clock*360)
  translate <0,0.55,0>
}

// glass dome
sphere { <0,1.55,0>, 1.65 Retro_Glass(rgb <0.85,0.92,1.0>) }

Retro_Camera(<-2.0,2.4,-4.5>, <0,1.4,0>)
