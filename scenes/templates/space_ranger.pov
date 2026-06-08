// space_ranger.pov — generic space-ranger toy (v3). Synthesized with Codex+Grok
// input: higher-order surfaces, joint fillets for smooth joins, a real sor helmet
// + steel base ring, bigger red-edged fin wings, gloves with thumbs, a face with
// a smile, rocket nozzles, glossier toy plastic. No trademarks.
#include "retro90s.inc"

Retro_Sky_Gradient(rgb <0.45,0.55,0.82>, rgb <0.96,0.88,0.72>)
Retro_Sun(<-0.4,0.8,-0.35>, rgb <1.0,0.97,0.9>)
Retro_Checker_Floor(rgb <0.70,0.50,0.30>, rgb <0.50,0.34,0.18>, 0.12)

// glossier toy plastic (more spec + a touch of reflection)
#declare White  = texture { pigment { rgb <0.95,0.96,1.0> } finish { ambient 0.28 diffuse 0.65 phong 1.0 phong_size 90 reflection { 0.06 } } }
#declare Green  = texture { pigment { rgb <0.08,0.60,0.26> } finish { ambient 0.28 diffuse 0.65 phong 1.0 phong_size 90 reflection { 0.06 } } }
#declare Purple = texture { pigment { rgb <0.42,0.18,0.62> } finish { ambient 0.28 diffuse 0.65 phong 1.0 phong_size 90 } }
#declare Red    = texture { pigment { rgb <0.85,0.12,0.10> } finish { ambient 0.28 diffuse 0.65 phong 1.0 phong_size 90 } }
#declare Skin   = texture { pigment { rgb <0.95,0.78,0.62> } finish { ambient 0.35 diffuse 0.7 phong 0.4 } }
#declare Steel  = texture { pigment { rgb <0.75,0.78,0.85> } finish { ambient 0.25 diffuse 0.4 reflection { 0.4 metallic } phong 1 phong_size 120 metallic } }
#declare Bob  = sin(clock*2*pi)*0.10;
#declare Wave = sin(clock*4*pi)*20;

union {
  // boots + purple soles
  superellipsoid { <0.3,0.3> scale <0.31,0.27,0.44> translate <-0.34,0.28,-0.06> texture { White } }
  superellipsoid { <0.3,0.3> scale <0.31,0.27,0.44> translate < 0.34,0.28,-0.06> texture { White } }
  superellipsoid { <0.2,0.3> scale <0.32,0.07,0.46> translate <-0.34,0.05,-0.06> texture { Purple } }
  superellipsoid { <0.2,0.3> scale <0.32,0.07,0.46> translate < 0.34,0.05,-0.06> texture { Purple } }
  // green legs + knee fillets (smooth join)
  superellipsoid { <0.4,0.35> scale <0.28,0.58,0.31> translate <-0.34,0.98,0> texture { Green } }
  superellipsoid { <0.4,0.35> scale <0.28,0.58,0.31> translate < 0.34,0.98,0> texture { Green } }
  sphere { <-0.34,1.46,0.02>, 0.27 texture { Green } }
  sphere { < 0.34,1.46,0.02>, 0.27 texture { Green } }
  // white hips + chunky torso + green side panels
  superellipsoid { <0.5,0.3> scale <0.62,0.32,0.43> translate <0,1.58,0> texture { White } }
  superellipsoid { <0.45,0.30> scale <0.74,0.80,0.52> translate <0,2.32,0> texture { White } }
  superellipsoid { <0.4,0.4> scale <0.18,0.62,0.40> translate <-0.66,2.30,0> texture { Green } }
  superellipsoid { <0.4,0.4> scale <0.18,0.62,0.40> translate < 0.66,2.30,0> texture { Green } }
  // green chest yoke + comm panel (dark) with buttons
  superellipsoid { <0.5,0.4> scale <0.52,0.40,0.18> translate <0,2.45,-0.40> texture { Green } }
  superellipsoid { <0.3,0.3> scale <0.30,0.20,0.10> translate <0,2.42,-0.52> texture { pigment { rgb <0.10,0.10,0.13> } finish { ambient 0.3 phong 1 } } }
  sphere { <-0.16,2.46,-0.60>, 0.05 texture { Red } }
  sphere { < 0.00,2.46,-0.60>, 0.05 texture { pigment{rgb<0.2,1,0.3>} finish{ambient 1.4} } }
  sphere { < 0.16,2.46,-0.60>, 0.05 texture { pigment{rgb<1,0.8,0.1>} finish{ambient 0.6} } }
  // purple collar ring
  torus { 0.40, 0.10 translate <0,2.95,0> texture { Purple } }
  // shoulders (fillets) + left arm down: upper, forearm, cuff, glove + thumb
  sphere { <-0.78,2.74,0>, 0.24 texture { White } }
  superellipsoid { <0.4,0.5> scale <0.17,0.42,0.19> rotate z*14 translate <-0.88,2.30,0.03> texture { White } }
  sphere { <-0.95,1.95,0.05>, 0.18 texture { White } }
  superellipsoid { <0.4,0.5> scale <0.16,0.40,0.18> translate <-0.99,1.55,0.07> texture { White } }
  torus { 0.16,0.06 rotate x*90 translate <-0.99,1.74,0.08> texture { Purple } }
  sphere { <-1.01,1.18,0.10>, 0.20 texture { White } }
  sphere { <-0.84,1.22,0.12>, 0.10 texture { White } }
  // right arm waving (animated): upper, forearm, cuff, glove + thumb
  union {
    sphere { <0,0,0>, 0.24 texture { White } }
    superellipsoid { <0.4,0.5> scale <0.17,0.42,0.19> translate <0.0,-0.44,0> texture { White } }
    sphere { <0,-0.78,0>, 0.18 texture { White } }
    superellipsoid { <0.4,0.5> scale <0.16,0.40,0.18> translate <0,-1.12,0> texture { White } }
    torus { 0.16,0.06 rotate x*90 translate <0,-0.95,0> texture { Purple } }
    sphere { <0,-1.45,0>, 0.20 texture { White } }
    sphere { <0.17,-1.40,0.02>, 0.10 texture { White } }
    rotate z*(150+Wave) translate <0.78,2.74,0>
  }
  // head: skin + chin, eyes, smile
  sphere { <0,3.35,0>, 0.40 texture { Skin } }
  superellipsoid { <0.6,0.7> scale <0.31,0.24,0.31> translate <0,3.04,-0.04> texture { Skin } }
  sphere { <-0.15,3.42,-0.31>, 0.075 texture { pigment{rgb 1} finish{phong 0.6 ambient 0.4} } }
  sphere { < 0.15,3.42,-0.31>, 0.075 texture { pigment{rgb 1} finish{phong 0.6 ambient 0.4} } }
  sphere { <-0.15,3.42,-0.37>, 0.035 texture { pigment{rgb 0.03} } }
  sphere { < 0.15,3.42,-0.37>, 0.035 texture { pigment{rgb 0.03} } }
  torus { 0.10,0.018 rotate x*72 translate <0,3.18,-0.34> texture { pigment{rgb <0.5,0.2,0.18>} } }
  // purple hood (top shell) + ear flaps
  difference {
    sphere { <0,3.42,0>, 0.47 }
    box { <-0.6,2.95,-0.62>, <0.6,3.42,0.62> }
    texture { Purple }
  }
  sphere { <-0.38,3.18,0>, 0.16 texture { Purple } }
  sphere { < 0.38,3.18,0>, 0.16 texture { Purple } }
  // sor jetpack + red rocket nozzles
  sor { 6, <0.0,0.0>,<0.34,0.05>,<0.42,0.4>,<0.42,1.0>,<0.30,1.25>,<0.0,1.3>
        scale 0.9 rotate x*8 translate <0,1.7,0.6> texture { White } }
  cone { <-0.18,1.35,0.62>, 0.12, <-0.18,1.05,0.66>, 0.16 texture { Red } }
  cone { < 0.18,1.35,0.62>, 0.12, < 0.18,1.05,0.66>, 0.16 texture { Red } }
  // wings (bigger fins, angled up/out, red leading edge)
  superellipsoid { <0.3,0.7> scale <0.62,0.58,0.05> rotate z*18 rotate y*-38 translate <-0.78,2.5,0.78> texture { White } }
  superellipsoid { <0.3,0.7> scale <0.62,0.58,0.05> rotate z*-18 rotate y*38 translate < 0.78,2.5,0.78> texture { White } }
  // glass dome helmet (sor profile) + steel base ring
  sor { 5, <0.0,0.0>,<0.46,0.0>,<0.52,0.35>,<0.40,0.78>,<0.0,0.92>
        translate <0,2.95,0> Retro_Glass(rgb <0.85,0.95,1.0>) }
  torus { 0.50, 0.06 translate <0,2.97,0> texture { Steel } }
  translate <0, Bob, 0>
}

Retro_Camera(<-2.7,2.9,-5.6>, <0,1.95,0>)
