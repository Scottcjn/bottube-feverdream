// amiga_glenz.pov — glenz vectors over copper bars. Amiga-demo classic.
#include "retro90s.inc"
#include "amiga_demo.inc"
sky_sphere { pigment { rgb <0.02,0.0,0.06> } }
Retro_Sun(<-0.3,0.6,-0.5>, rgb <0.6,0.6,0.8>)
CopperBars()
// dark mirror floor
plane { y, 0 pigment { rgb <0.02,0.02,0.05> } finish { ambient 0.1 reflection { 0.5 } } }
object { Glenz(clock*360) translate <0,3.2,6> }
Retro_Camera(<0,3.5,-5>, <0,3.0,6>)
