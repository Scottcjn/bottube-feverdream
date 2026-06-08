// space_ranger.pov — a generic space-ranger toy, built with higher-order
// surfaces (superellipsoid bodies, sor jetpack, prism-ish wings) for a properly
// MODELED 1995-toy look — a step above raw primitives. No trademarks.
#include "retro90s.inc"

Retro_Sky_Gradient(rgb <0.45,0.55,0.82>, rgb <0.96,0.88,0.72>)
Retro_Sun(<-0.4,0.8,-0.35>, rgb <1.0,0.97,0.9>)
Retro_Checker_Floor(rgb <0.70,0.50,0.30>, rgb <0.50,0.34,0.18>, 0.12)

#declare White  = texture { pigment { rgb <0.95,0.96,1.0> } finish { ambient 0.3 diffuse 0.7 phong 0.7 phong_size 55 } }
#declare Green  = texture { pigment { rgb <0.10,0.62,0.28> } finish { ambient 0.3 diffuse 0.7 phong 0.7 phong_size 55 } }
#declare Purple = texture { pigment { rgb <0.42,0.18,0.62> } finish { ambient 0.3 diffuse 0.7 phong 0.7 phong_size 55 } }
#declare Red    = texture { pigment { rgb <0.85,0.12,0.10> } finish { ambient 0.3 diffuse 0.7 phong 0.8 phong_size 60 } }
#declare Skin   = texture { pigment { rgb <0.95,0.78,0.62> } finish { ambient 0.35 diffuse 0.7 } }
#declare Bob  = sin(clock*2*pi)*0.10;
#declare Wave = sin(clock*4*pi)*20;

union {
  // boots (white) + purple soles
  superellipsoid { <0.3,0.3> scale <0.30,0.26,0.42> translate <-0.34,0.26,-0.05> texture { White } }
  superellipsoid { <0.3,0.3> scale <0.30,0.26,0.42> translate < 0.34,0.26,-0.05> texture { White } }
  // green legs (chunky)
  superellipsoid { <0.4,0.35> scale <0.27,0.55,0.30> translate <-0.34,0.95,0> texture { Green } }
  superellipsoid { <0.4,0.35> scale <0.27,0.55,0.30> translate < 0.34,0.95,0> texture { Green } }
  // white hips / belt
  superellipsoid { <0.5,0.3> scale <0.62,0.30,0.42> translate <0,1.55,0> texture { White } }
  // chunky white torso
  superellipsoid { <0.45,0.30> scale <0.72,0.78,0.50> translate <0,2.30,0> texture { White } }
  // green chest yoke + control panel
  superellipsoid { <0.5,0.4> scale <0.50,0.34,0.18> translate <0,2.45,-0.42> texture { Green } }
  cylinder { <-0.18,2.5,-0.55>, <-0.18,2.5,-0.50>, 0.05 texture { Red } }
  cylinder { < 0.00,2.5,-0.55>, < 0.00,2.5,-0.50>, 0.05 texture { pigment{rgb<0.2,1,0.3>} finish{ambient 1.4} } }
  cylinder { < 0.18,2.5,-0.55>, < 0.18,2.5,-0.50>, 0.05 texture { pigment{rgb<1,0.8,0.1>} finish{ambient 0.5} } }
  // purple collar ring
  torus { 0.40, 0.10 translate <0,2.95,0> texture { Purple } }
  // shoulders + left arm (down) with purple cuff + white glove
  sphere { <-0.74,2.72,0>, 0.22 texture { White } }
  superellipsoid { <0.4,0.45> scale <0.16,0.5,0.18> rotate z*16 translate <-0.86,2.15,0.05> texture { White } }
  torus { 0.16,0.05 rotate x*90 translate <-0.95,1.72,0.08> texture { Purple } }
  sphere { <-0.99,1.55,0.10>, 0.19 texture { White } }
  // right arm (waving) — superellipsoid forearm + glove, animated
  union {
    sphere { <0,0,0>, 0.22 texture { White } }
    superellipsoid { <0.4,0.45> scale <0.16,0.5,0.18> translate <0.0,-0.55,0> texture { White } }
    torus { 0.16,0.05 rotate x*90 translate <0,-1.0,0> texture { Purple } }
    sphere { <0,-1.18,0>, 0.19 texture { White } }
    rotate z*(150+Wave) translate <0.74,2.72,0>
  }
  // head: skin + chin, purple hood cap
  sphere { <0,3.35,0>, 0.40 texture { Skin } }
  superellipsoid { <0.6,0.7> scale <0.30,0.22,0.30> translate <0,3.05,-0.05> texture { Skin } }   // chin/jaw
  sphere { <-0.14,3.42,-0.32>, 0.055 texture { pigment{rgb 0.05} } }
  sphere { < 0.14,3.42,-0.32>, 0.055 texture { pigment{rgb 0.05} } }
  difference {
    sphere { <0,3.45,0>, 0.46 }
    box { <-0.6,2.9,-0.6>, <0.6,3.45,0.6> }
    texture { Purple }
  }   // purple hood (top half shell)
  // sor jetpack on the back
  sor { 6, <0.0,0.0>,<0.34,0.05>,<0.40,0.4>,<0.40,1.0>,<0.30,1.25>,<0.0,1.3>
        scale 0.85 rotate x*8 translate <0,1.7,0.55> texture { White } }
  // wings (thin superellipsoid fins, red-tipped), angled off the jetpack
  superellipsoid { <0.4,0.7> scale <0.55,0.5,0.05> rotate y*-35 translate <-0.7,2.3,0.7> texture { White } }
  superellipsoid { <0.4,0.7> scale <0.55,0.5,0.05> rotate y*35 translate < 0.7,2.3,0.7> texture { Green } }
  // glass dome helmet
  sphere { <0,3.35,0>, 0.60 Retro_Glass(rgb <0.85,0.95,1.0>) }
  translate <0, Bob, 0>
}

Retro_Camera(<-2.8,2.8,-5.4>, <0,1.9,0>)
