// mainframe_city.pov — a ReBoot-style digital city: neon-grid floor, glowing
// wireframe towers, a floating Principal-Office diamond, grid sky. 1994 TV-CGI
// vibe. Camera + diamond animate via `clock`. Generic tribute.
#include "retro90s.inc"

sky_sphere { pigment { color rgb <0.01,0.02,0.06> } }
Retro_Sun(<-0.3,0.7,-0.4>, rgb <0.35,0.45,0.7>)
Retro_Grid_Floor(rgb <0.1,0.9,1.0>, rgb <0.02,0.03,0.08>, 1.6)

#declare DarkT = texture { pigment { rgb <0.05,0.07,0.12> } finish { ambient 0.18 diffuse 0.4 phong 0.7 phong_size 60 reflection { 0.15 } } }
#declare NeonC = texture { pigment { rgb <0.10,0.95,1.0> } finish { ambient 2.2 } }
#declare NeonM = texture { pigment { rgb <1.0,0.15,0.85> } finish { ambient 2.2 } }
#declare NeonG = texture { pigment { rgb <0.2,1.0,0.4> } finish { ambient 2.0 } }

// a glowing wireframe tower: dark block + emissive window bands
#macro Tower(tx, tz, tw, th, td, neon)
  box { <tx-tw,0,tz-td>, <tx+tw,th,tz+td> texture { DarkT } }
  #declare yy = 0.8;
  #while (yy < th-0.3)
    box { <tx-tw-0.03,yy,tz-td-0.03>, <tx+tw+0.03,yy+0.10,tz+td+0.03> texture { neon } }
    #declare yy = yy + 0.75;
  #end
#end

Tower(-6.5, 9,  0.9, 5.0, 0.9, NeonC)
Tower(-4.2, 11, 1.1, 7.5, 1.1, NeonM)
Tower(-1.8, 8,  0.8, 4.0, 0.8, NeonG)
Tower( 0.6, 12, 1.2, 9.0, 1.2, NeonC)
Tower( 3.0, 9,  0.9, 6.0, 0.9, NeonM)
Tower( 5.4, 11, 1.0, 7.0, 1.0, NeonC)
Tower( 7.6, 8,  0.8, 4.5, 0.8, NeonG)

// floating Principal-Office diamond (rotating, glowing)
merge {
  cone { <0,0,0>, 1.1, <0,1.5,0>, 0.0 }
  cone { <0,0,0>, 1.1, <0,-1.5,0>, 0.0 }
  texture { pigment { rgb <0.7,0.9,1.0> } finish { ambient 1.4 phong 1 phong_size 120 reflection { 0.2 } } }
  rotate y*(clock*360)
  translate <0.6, 8.0, 10>
}

// energy beams shooting up from a couple towers
cylinder { <0.6,9,12>, <0.6,16,12>, 0.08 texture { NeonC } }
cylinder { <-4.2,7.5,11>, <-4.2,14,11>, 0.06 texture { NeonM } }

Retro_Orbit_Camera(13, 4.0, <0.5, 4.5, 9>)
