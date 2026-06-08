// bee_friend.pov — a generic round striped CGI bee in the earliest-Pixar style
// (think the 1984-era bee from the first CG character shorts). No trademarks:
// just a friendly googly-eyed bumblebee, hovering, with flapping wings.
#include "retro90s.inc"

Retro_Sky_Gradient(rgb <0.30,0.55,0.95>, rgb <0.80,0.92,1.0>)   // clear sky
Retro_Sun(<-0.4,0.8,-0.5>, rgb <1.0,0.97,0.88>)
Retro_Checker_Floor(rgb <0.55,0.78,0.35>, rgb <0.35,0.58,0.22>, 0.05)  // grassy ground

#declare Hover = sin(clock*2*pi)*0.30;
#declare Flap  = sin(clock*16*pi)*28;   // fast wingbeat

// striped abdomen texture (bands along the long axis, z)
#declare BeeBody = texture {
  pigment {
    gradient z
    color_map {
      [0.00 rgb <0.97,0.76,0.05>][0.25 rgb <0.97,0.76,0.05>]
      [0.25 rgb <0.10,0.08,0.05>][0.50 rgb <0.10,0.08,0.05>]
      [0.50 rgb <0.97,0.76,0.05>][0.75 rgb <0.97,0.76,0.05>]
      [0.75 rgb <0.10,0.08,0.05>][1.00 rgb <0.10,0.08,0.05>]
    }
    scale 0.62
  }
  finish { ambient 0.35 diffuse 0.75 phong 0.6 phong_size 45 }
}
#declare BeeDark  = texture { pigment { rgb <0.10,0.08,0.06> } finish { ambient 0.3 diffuse 0.7 phong 0.5 } }
#declare EyeWhite = texture { pigment { rgb 1 } finish { phong 0.6 ambient 0.4 } }
#declare EyePupil = texture { pigment { rgb 0.02 } finish { phong 0.7 ambient 0.2 } }
#declare Wing = texture { pigment { rgbf <0.90,0.95,1.0,0.72> } finish { ambient 0.3 phong 0.9 phong_size 90 } }

union {
  // abdomen
  sphere { 0, 1 scale <0.92,0.90,1.35> texture { BeeBody } }
  // head (front, toward camera at -z)
  sphere { <0,0.18,-1.45>, 0.62 texture { BeeDark } }
  // big googly eyes
  sphere { <-0.27,0.34,-1.95>, 0.22 texture { EyeWhite } }
  sphere { < 0.27,0.34,-1.95>, 0.22 texture { EyeWhite } }
  sphere { <-0.27,0.34,-2.12>, 0.11 texture { EyePupil } }
  sphere { < 0.27,0.34,-2.12>, 0.11 texture { EyePupil } }
  // antennae
  cylinder { <-0.16,0.65,-1.6>, <-0.34,1.45,-1.9>, 0.035 texture { BeeDark } }
  cylinder { < 0.16,0.65,-1.6>, < 0.34,1.45,-1.9>, 0.035 texture { BeeDark } }
  sphere { <-0.34,1.45,-1.9>, 0.10 texture { BeeDark } }
  sphere { < 0.34,1.45,-1.9>, 0.10 texture { BeeDark } }
  // stinger
  cone { <0,0,1.25>, 0.14, <0,0,1.75>, 0.0 texture { BeeDark } }
  // wings (flapping via clock)
  sphere { 0,1 scale <0.95,0.07,0.6> rotate z*(22+Flap) translate < 0.35,0.85,0.05> texture { Wing } }
  sphere { 0,1 scale <0.95,0.07,0.6> rotate z*(-22-Flap) translate <-0.35,0.85,0.05> texture { Wing } }
  translate <0, 1.7+Hover, 0>
}

Retro_Camera(<-4.3,2.3,-4.2>, <-0.1,1.55,-0.2>)
