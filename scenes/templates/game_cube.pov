// game_cube.pov — the iconic ReBoot "Game" descending: a giant translucent
// purple cube with a glowing wireframe drops onto the neon-grid city. The cube
// descends via `clock`. Generic tribute.
#include "retro90s.inc"

sky_sphere { pigment { color rgb <0.01,0.02,0.06> } }
Retro_Sun(<-0.3,0.7,-0.4>, rgb <0.35,0.45,0.7>)
Retro_Grid_Floor(rgb <0.1,0.9,1.0>, rgb <0.02,0.03,0.08>, 1.6)

#declare DarkT = texture { pigment { rgb <0.05,0.07,0.12> } finish { ambient 0.18 diffuse 0.4 phong 0.7 phong_size 60 } }
#declare NeonC = texture { pigment { rgb <0.10,0.95,1.0> } finish { ambient 2.2 } }
#declare NeonM = texture { pigment { rgb <1.0,0.15,0.85> } finish { ambient 2.2 } }
#declare Edge  = texture { pigment { rgb <0.3,1.0,0.5> } finish { ambient 2.4 } }

// little skyline under the descending game
#macro Tower(tx,tz,tw,th,td,neon)
  box { <tx-tw,0,tz-td>, <tx+tw,th,tz+td> texture { DarkT } }
  box { <tx-tw-0.03,th*0.55,tz-td-0.03>, <tx+tw+0.03,th*0.55+0.12,tz+td+0.03> texture { neon } }
  box { <tx-tw-0.03,th*0.8,tz-td-0.03>, <tx+tw+0.03,th*0.8+0.12,tz+td+0.03> texture { neon } }
#end
Tower(-3.2, 10, 0.9, 4.0, 0.9, NeonC)
Tower(-1.0, 11, 1.0, 5.5, 1.0, NeonM)
Tower( 1.4, 10, 0.9, 4.5, 0.9, NeonC)
Tower( 3.4, 11, 0.8, 3.5, 0.8, NeonM)

// glowing wireframe edges of a cube centred at C, half-size h
#macro WireCube(C, h, r, etex)
  #local x1=C.x-h; #local x2=C.x+h; #local y1=C.y-h; #local y2=C.y+h; #local z1=C.z-h; #local z2=C.z+h;
  cylinder{<x1,y1,z1>,<x2,y1,z1>,r texture{etex}} cylinder{<x2,y1,z1>,<x2,y1,z2>,r texture{etex}}
  cylinder{<x2,y1,z2>,<x1,y1,z2>,r texture{etex}} cylinder{<x1,y1,z2>,<x1,y1,z1>,r texture{etex}}
  cylinder{<x1,y2,z1>,<x2,y2,z1>,r texture{etex}} cylinder{<x2,y2,z1>,<x2,y2,z2>,r texture{etex}}
  cylinder{<x2,y2,z2>,<x1,y2,z2>,r texture{etex}} cylinder{<x1,y2,z2>,<x1,y2,z1>,r texture{etex}}
  cylinder{<x1,y1,z1>,<x1,y2,z1>,r texture{etex}} cylinder{<x2,y1,z1>,<x2,y2,z1>,r texture{etex}}
  cylinder{<x2,y1,z2>,<x2,y2,z2>,r texture{etex}} cylinder{<x1,y1,z2>,<x1,y2,z2>,r texture{etex}}
#end

// the descending Game cube
#declare CY = 13 - clock*7;       // drops from y13 down toward the city
#declare C = <0.3, CY, 10.5>;
box { <C.x-3,C.y-3,C.z-3>, <C.x+3,C.y+3,C.z+3>
  texture { pigment { rgbf <0.55,0.12,0.85,0.62> } finish { ambient 0.25 diffuse 0.4 phong 1 phong_size 90 reflection { 0.1 } } }
  interior { ior 1.15 }
}
WireCube(C, 3.0, 0.06, Edge)

// energy contact glow where the game lands
cylinder { <0.3,0.01,10.5>, <0.3,0.06,10.5>, 3.0 texture { pigment { rgbf <0.3,1.0,0.5,0.4> } finish { ambient 1.8 } } }

Retro_Camera(<-6.5, 3.2, -3>, <0.3, 5, 10>)
