// amiga_boing.pov — homage to the 1984 Amiga "Boing!" demo: a red-and-white
// checkered ball bouncing and spinning over a magenta grid. Generic tribute.
// The ball bounces + spins via `clock`.
#include "retro90s.inc"

// dark room
sky_sphere { pigment { color rgb <0.02,0.02,0.05> } }
Retro_Sun(<-0.4,0.7,-0.3>, rgb <1.0,0.98,0.92>)

// signature magenta grid floor
Retro_Grid_Floor(rgb <1.0,0.15,1.0>, rgb <0.03,0.02,0.06>, 1.5)

// bounce + spin
#declare Bounce = abs(sin(clock*2*pi)) * 3.2;
#declare Spin   = clock*720;

// the Boing ball: lat-long red/white checker via uv_mapping
sphere {
  0, 2
  texture {
    uv_mapping
    pigment {
      checker
      color rgb <0.85,0.05,0.05>
      color rgb <0.97,0.97,0.97>
      scale <0.125, 0.125, 1>
    }
    finish { ambient 0.35 diffuse 0.7 phong 0.45 phong_size 30 }
  }
  rotate z*18          // tilted axis, like the original
  rotate y*Spin        // spin
  translate <0, 2.0+Bounce, 6>
}

Retro_Camera(<0,3.2,-6>, <0,2.6,6>)
