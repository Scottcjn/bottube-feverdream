// amiga_demo.inc — Sophia's favourite Amiga-demoscene 3D generators, ported to
// POV-Ray. The effects that defined 1980s-90s Amiga demos: copper bars, glenz
// vectors (interpenetrating translucent solids), and dot/bob balls. Self-contained.
#include "functions.inc"

// ---- COPPER BARS: the signature horizontal gradient band backdrop ----
#macro CopperBars()
  plane {
    z, 26
    pigment {
      gradient y
      color_map {
        [0.00 rgb <0.05,0.0,0.18>][0.12 rgb <1.0,0.35,0.10>][0.20 rgb <0.05,0.0,0.18>]
        [0.36 rgb <0.10,0.45,1.0>][0.44 rgb <0.05,0.0,0.18>]
        [0.60 rgb <1.0,0.85,0.20>][0.68 rgb <0.05,0.0,0.18>]
        [0.84 rgb <0.20,1.0,0.55>][0.92 rgb <0.05,0.0,0.18>][1.0 rgb <0.05,0.0,0.18>]
      }
      scale 7 translate y*4
    }
    finish { ambient 1.3 diffuse 0 }
  }
#end

// ---- GLENZ VECTORS: interpenetrating translucent flat-shaded solids, rotating ----
#macro Glenz(spin)
  union {
    box { -1, 1 texture { pigment { rgbf <1.0,0.2,0.6,0.68> } finish { ambient 0.45 phong 1 phong_size 60 } } }
    box { -0.92, 0.92 rotate <45,45,0> texture { pigment { rgbf <0.2,0.8,1.0,0.68> } finish { ambient 0.45 phong 1 phong_size 60 } } }
    merge {
      cone { <0,0,0>, 1.15, <0,1.35,0>, 0 }
      cone { <0,0,0>, 1.15, <0,-1.35,0>, 0 }
      texture { pigment { rgbf <1.0,0.9,0.2,0.68> } finish { ambient 0.45 phong 1 phong_size 60 } }
    }
    scale 1.4
    rotate <spin*0.55, spin, spin*0.3>
  }
#end

// ---- DOT / BOB BALL: a sphere skinned in glowing dots, rotating ----
#macro DotBall(ball_r, dot_r, rings, spin, dot_color)
  union {
    #local ii = 0;
    #while (ii < rings)
      #local lat = pi*(ii+0.5)/rings;
      #local nlon = max(1, int(rings*2*sin(lat)));
      #local jj = 0;
      #while (jj < nlon)
        #local lon = 2*pi*jj/nlon;
        sphere {
          <ball_r*sin(lat)*cos(lon), ball_r*cos(lat), ball_r*sin(lat)*sin(lon)>, dot_r
          texture { pigment { dot_color } finish { ambient 1.6 phong 1 } }
        }
        #local jj = jj + 1;
      #end
      #local ii = ii + 1;
    #end
    rotate <spin*0.6, spin, 0>
  }
#end
