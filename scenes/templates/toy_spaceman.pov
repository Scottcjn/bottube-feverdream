// toy_spaceman.pov — a generic spaceman toy in a kid's room, 1995-era
// rendered-toy CGI vibe. Bobs/waves via `clock`. No trademarks.
#include "retro90s.inc"

Retro_Sky_Gradient(rgb <0.45,0.55,0.80>, rgb <0.95,0.85,0.70>)   // warm bedroom
Retro_Sun(<-0.4,0.8,-0.3>, rgb <1.0,0.97,0.9>)
Retro_Checker_Floor(rgb <0.70,0.50,0.30>, rgb <0.50,0.34,0.18>, 0.12)   // wood floor

#declare White = texture { pigment { rgb <0.95,0.96,1.0> } finish { ambient 0.3 diffuse 0.7 phong 0.8 phong_size 60 } }
#declare Red   = texture { pigment { rgb <0.85,0.12,0.10> } finish { ambient 0.3 diffuse 0.7 phong 0.8 phong_size 60 } }
#declare Skin  = texture { pigment { rgb <0.95,0.78,0.62> } finish { ambient 0.35 diffuse 0.7 } }
#declare Bob = sin(clock*2*pi)*0.12;
#declare Wave = sin(clock*4*pi)*22;

union {
  // body (white capsule)
  cylinder { <0,0.5,0>, <0,2.0,0>, 0.62 texture { White } }
  sphere { <0,0.5,0>, 0.62 texture { White } }
  sphere { <0,2.0,0>, 0.62 texture { White } }
  // red chest panel + light
  box { <-0.35,1.25,-0.66>, <0.35,1.75,-0.55> texture { Red } }
  sphere { <0,1.5,-0.64>, 0.09 texture { pigment { rgb <0.2,1,0.3> } finish { ambient 1.5 } } }
  // boots
  cylinder { <-0.30,0,0>, <-0.30,0.55,0>, 0.26 texture { Red } }
  cylinder { < 0.30,0,0>, < 0.30,0.55,0>, 0.26 texture { Red } }
  // left arm (down), right arm (waving, via clock)
  cylinder { <-0.55,1.85,0>, <-0.95,1.0,0.1>, 0.17 texture { White } }
  sphere { <-0.95,1.0,0.1>, 0.20 texture { Red } }
  union {
    cylinder { <0,0,0>, <0.6,1.1,0.1>, 0.17 texture { White } }
    sphere { <0.6,1.1,0.1>, 0.20 texture { Red } }
    rotate z*Wave translate <0.55,1.85,0>
  }
  // head + glass dome helmet
  sphere { <0,2.55,0>, 0.42 texture { Skin } }
  sphere { <-0.14,2.62,-0.34>, 0.06 texture { pigment { rgb 0.05 } } }
  sphere { < 0.14,2.62,-0.34>, 0.06 texture { pigment { rgb 0.05 } } }
  sphere { <0,2.55,0>, 0.58 Retro_Glass(rgb <0.85,0.95,1.0>) }
  translate <0, Bob, 0>
}

Retro_Camera(<-2.6,2.6,-5.2>, <0,1.5,0>)
