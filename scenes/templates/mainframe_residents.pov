// mainframe_residents.pov — a cast of generic ReBoot-style "Mainframe" residents:
// binomes (a 1 and a 0), a blue Guardian sprite (Bob-like), a small kid sprite
// (Enzo-like), and a metallic virus (Megabyte-like). 1994 SGI-CGI look. Generic.
#include "retro90s.inc"

Retro_Sky_Gradient(rgb <0.12,0.22,0.70>, rgb <0.55,0.92,1.0>)
Retro_Sun(<-0.3,0.85,-0.4>, rgb <1.0,0.98,0.92>)
Retro_Grid_Floor(rgb <0.25,1.0,1.0>, rgb <0.10,0.30,0.55>, 0.05)

#declare BlueSkin = texture { pigment { rgb <0.22,0.52,0.95> } finish { ambient 0.34 diffuse 0.7 phong 0.7 phong_size 60 } }
#declare Wht  = texture { pigment { rgb <0.93,0.95,1.0> } finish { ambient 0.32 diffuse 0.65 phong 1 phong_size 80 } }
#declare Org  = texture { pigment { rgb <0.97,0.55,0.10> } finish { ambient 0.32 diffuse 0.65 phong 1 phong_size 80 } }
#declare Grn  = texture { pigment { rgb <0.15,0.75,0.35> } finish { ambient 0.32 diffuse 0.65 phong 1 phong_size 80 } }
#declare Steel= texture { pigment { rgb <0.62,0.68,0.78> } finish { ambient 0.25 diffuse 0.4 reflection { 0.35 metallic } phong 1 phong_size 130 metallic } }
#declare DarkM= texture { pigment { rgb <0.18,0.24,0.34> } finish { ambient 0.25 diffuse 0.5 phong 1 phong_size 90 reflection { 0.15 } } }
#declare Teal = texture { pigment { rgb <0.10,0.65,0.72> } finish { ambient 0.34 diffuse 0.62 phong 1 phong_size 90 } }

#macro Googly(ex,ey,ez,r)
  sphere { <ex,ey,ez>, r texture { pigment{rgb 1} finish{phong 0.6 ambient 0.45} } }
  sphere { <ex,ey,ez-r*0.8>, r*0.48 texture { pigment{rgb 0.04} } }
#end

// ---- Binome "1" : tall rounded body with a face, arms, feet ----
#macro Binome1(bx, body)
  union {
    superellipsoid { <0.25,0.18> scale <0.32,0.95,0.30> translate <bx,1.05,0> texture { body } }
    Googly(bx-0.13,1.55,-0.30,0.13) Googly(bx+0.13,1.55,-0.30,0.13)
    torus { 0.10,0.025 rotate x*70 translate <bx,1.30,-0.27> texture { pigment{rgb<0.3,0.1,0.1>} } }
    cylinder { <bx-0.30,1.2,0>, <bx-0.5,0.8,0.05>, 0.06 texture { body } }
    cylinder { <bx+0.30,1.2,0>, <bx+0.5,0.8,0.05>, 0.06 texture { body } }
    superellipsoid { <0.3,0.3> scale <0.16,0.10,0.22> translate <bx-0.15,0.1,-0.04> texture { body } }
    superellipsoid { <0.3,0.3> scale <0.16,0.10,0.22> translate <bx+0.15,0.1,-0.04> texture { body } }
  }
#end

// ---- Binome "0" : standing ring with a face, arms, feet ----
#macro Binome0(bx, body)
  union {
    torus { 0.62, 0.26 rotate x*90 translate <bx,1.05,0> texture { body } }
    Googly(bx-0.18,1.45,-0.30,0.13) Googly(bx+0.18,1.45,-0.30,0.13)
    torus { 0.10,0.025 rotate x*70 translate <bx,1.18,-0.30> texture { pigment{rgb<0.3,0.1,0.1>} } }
    cylinder { <bx-0.55,1.1,0>, <bx-0.78,0.75,0.05>, 0.06 texture { body } }
    cylinder { <bx+0.55,1.1,0>, <bx+0.78,0.75,0.05>, 0.06 texture { body } }
    superellipsoid { <0.3,0.3> scale <0.16,0.10,0.22> translate <bx-0.20,0.1,-0.04> texture { body } }
    superellipsoid { <0.3,0.3> scale <0.16,0.10,0.22> translate <bx+0.20,0.1,-0.04> texture { body } }
  }
#end

// ---- Guardian sprite (Bob-like): blue skin, white+orange suit ----
#macro Guardian(gx, sc)
  union {
    cylinder { <-0.18,0,0>, <-0.16,0.7,0>, 0.16 texture { Wht } }   // legs
    cylinder { < 0.18,0,0>, < 0.16,0.7,0>, 0.16 texture { Wht } }
    superellipsoid { <0.4,0.3> scale <0.42,0.55,0.30> translate <0,1.15,0> texture { Wht } }  // torso
    box { <-0.42,1.05,-0.31>, <0.42,1.25,-0.28> texture { Org } }   // belt
    superellipsoid { <0.4,0.4> scale <0.18,0.12,0.20> translate <0,1.55,-0.28> texture { Org } } // chest emblem
    sphere { <-0.5,1.4,0>, 0.15 texture { Wht } }                   // shoulders
    sphere { < 0.5,1.4,0>, 0.15 texture { Wht } }
    cylinder { <-0.5,1.4,0>, <-0.6,0.85,0.08>, 0.12 texture { Wht } } // arms
    cylinder { < 0.5,1.4,0>, < 0.6,0.85,0.08>, 0.12 texture { Wht } }
    sphere { <-0.62,0.78,0.10>, 0.14 texture { BlueSkin } }          // hands (blue)
    sphere { < 0.62,0.78,0.10>, 0.14 texture { BlueSkin } }
    sphere { <0,1.95,0>, 0.34 texture { BlueSkin } }                 // head (blue)
    Googly(-0.12,2.02,-0.28,0.10) Googly(0.12,2.02,-0.28,0.10)
    torus { 0.12,0.025 rotate x*72 translate <0,1.82,-0.27> texture { pigment{rgb<0.2,0.1,0.1>} } } // smile
    box { <-0.34,2.18,-0.30>, <0.34,2.30,0.30> texture { Org } }     // headband/visor
    scale sc translate <gx,0,0>
  }
#end

// ---- Virus (Megabyte-like): big metallic armored figure, red eyes, fangs ----
#macro Virus(vx)
  union {
    superellipsoid { <0.3,0.2> scale <0.26,0.6,0.30> translate <-0.34,0.65,0> texture { Steel } } // legs
    superellipsoid { <0.3,0.2> scale <0.26,0.6,0.30> translate < 0.34,0.65,0> texture { Steel } }
    superellipsoid { <0.35,0.25> scale <0.85,0.85,0.55> translate <0,1.8,0> texture { Steel } }   // big torso
    superellipsoid { <0.3,0.3> scale <0.45,0.30,0.25> translate <0,1.9,-0.5> texture { DarkM } }   // chest plate
    superellipsoid { <0.3,0.2> scale <0.40,0.30,0.35> rotate z*20 translate <-0.95,2.5,0> texture { Steel } } // spiked shoulders
    superellipsoid { <0.3,0.2> scale <0.40,0.30,0.35> rotate z*-20 translate < 0.95,2.5,0> texture { Steel } }
    cone { <-1.1,2.7,0>, 0.18, <-1.35,3.1,0>, 0.0 texture { Steel } }  // shoulder spikes
    cone { < 1.1,2.7,0>, 0.18, < 1.35,3.1,0>, 0.0 texture { Steel } }
    cylinder { <-0.7,2.4,0>, <-1.0,1.5,0.1>, 0.20 texture { Steel } }  // arms
    cylinder { < 0.7,2.4,0>, < 1.0,1.5,0.1>, 0.20 texture { Steel } }
    sphere { <-1.05,1.4,0.1>, 0.26 texture { DarkM } }                 // fists
    sphere { < 1.05,1.4,0.1>, 0.26 texture { DarkM } }
    superellipsoid { <0.3,0.3> scale <0.40,0.40,0.40> translate <0,2.85,0> texture { Steel } }     // head
    sphere { <-0.16,2.88,-0.34>, 0.09 texture { pigment{rgb<1,0.1,0.05>} finish{ambient 1.8} } }   // red eyes
    sphere { < 0.16,2.88,-0.34>, 0.09 texture { pigment{rgb<1,0.1,0.05>} finish{ambient 1.8} } }
    cone { <-0.12,2.66,-0.40>, 0.05, <-0.12,2.5,-0.40>, 0.0 texture { Wht } }  // fangs
    cone { < 0.12,2.66,-0.40>, 0.05, < 0.12,2.5,-0.40>, 0.0 texture { Wht } }
    translate <vx,0,0>
  }
#end

Virus(-4.6)
Guardian(-1.7, 1.0)
Guardian(0.4, 0.62)        // Enzo = smaller guardian
Binome1(2.7, Grn)
Binome0(4.3, Org)

Retro_Camera(<-4.0+clock*8, 3.0, -11.5>, <-2.0+clock*4, 1.6, 0>)
