// mainframe_city.pov (v2) — closer to authentic ReBoot "Mainframe": BRIGHT vivid
// sky, glossy COLORFUL buildings with grids of lit windows, an energized neon
// grid, and a floating white Principal-Office structure. 1994 SGI-CGI look.
#include "retro90s.inc"

// bright Mainframe sky: deep blue overhead -> luminous cyan at the horizon
Retro_Sky_Gradient(rgb <0.12,0.22,0.70>, rgb <0.55,0.92,1.0>)
Retro_Sun(<-0.35,0.8,-0.4>, rgb <1.0,0.98,0.92>)
// energized grid floor (lit teal base, bright cyan lines, reflective)
Retro_Grid_Floor(rgb <0.25,1.0,1.0>, rgb <0.10,0.30,0.55>, 1.6)

// glossy SGI plastic in Mainframe colours
#declare Teal   = texture { pigment { rgb <0.10,0.62,0.72> } finish { ambient 0.34 diffuse 0.62 phong 1 phong_size 90 reflection { 0.12 } } }
#declare Wht    = texture { pigment { rgb <0.92,0.94,1.0> } finish { ambient 0.34 diffuse 0.62 phong 1 phong_size 90 reflection { 0.12 } } }
#declare Orange = texture { pigment { rgb <0.95,0.55,0.12> } finish { ambient 0.34 diffuse 0.62 phong 1 phong_size 90 reflection { 0.10 } } }
#declare Violet = texture { pigment { rgb <0.50,0.30,0.78> } finish { ambient 0.34 diffuse 0.62 phong 1 phong_size 90 reflection { 0.10 } } }
#declare WinLit = texture { pigment { rgb <1.0,0.92,0.5> } finish { ambient 1.6 } }
#declare WinCy  = texture { pigment { rgb <0.4,1.0,1.0> } finish { ambient 1.6 } }

// a Mainframe building: glossy colored block + a GRID of lit windows + a cap
#macro Bldg(tx, tz, tw, th, td, body, win, captype)
  box { <tx-tw,0,tz-td>, <tx+tw,th,tz+td> texture { body } }
  // window grid on the front (-z) face
  #local wx = tx-tw+0.28;
  #while (wx < tx+tw-0.22)
    #local wy = 0.7;
    #while (wy < th-0.5)
      box { <wx,wy,tz-td-0.05>, <wx+0.18,wy+0.26,tz-td-0.02> texture { win } }
      #local wy = wy + 0.62;
    #end
    #local wx = wx + 0.52;
  #end
  // roof cap: 0 flat, 1 dome, 2 pyramid
  #if (captype = 1) sphere { <tx,th,tz>, tw*0.95 scale <1,0.6,1> texture { body } } #end
  #if (captype = 2) cone { <tx,th,tz>, tw*1.05, <tx,th+tw*1.4,tz>, 0.0 texture { body } } #end
#end

Bldg(-6.6, 10, 0.95, 5.0, 0.95, Teal,   WinLit, 1)
Bldg(-4.0, 12, 1.15, 8.0, 1.15, Wht,    WinCy,  2)
Bldg(-1.6,  9, 0.85, 4.0, 0.85, Orange, WinLit, 0)
Bldg( 3.0, 10, 0.95, 6.0, 0.95, Violet, WinCy,  1)
Bldg( 5.5, 12, 1.05, 7.5, 1.05, Teal,   WinLit, 2)
Bldg( 7.8,  9, 0.85, 4.5, 0.85, Wht,    WinCy,  0)

// floating white Principal Office: inverted pyramid + dome + glowing eye-core
union {
  cone { <0,0,0>, 1.4, <0,-2.2,0>, 0.2 texture { Wht } }       // inverted pyramid body
  sphere { <0,0.2,0>, 1.45 scale <1,0.55,1> texture { Wht } }  // dome top
  torus { 1.5, 0.12 texture { Teal } }                          // ring
  sphere { <0,-0.3,-1.2>, 0.45 texture { pigment { rgb <0.3,1.0,1.0> } finish { ambient 1.8 } } } // glowing eye
  rotate y*(clock*120)
  translate <0.6, 9.5, 11>
}

Retro_Orbit_Camera(14, 4.5, <0.5, 5.0, 10>)
