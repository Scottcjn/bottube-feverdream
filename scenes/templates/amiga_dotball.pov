// amiga_dotball.pov — glowing dot/bob ball over copper bars. Amiga-demo classic.
#include "retro90s.inc"
#include "amiga_demo.inc"
sky_sphere { pigment { rgb <0.02,0.0,0.06> } }
Retro_Sun(<-0.3,0.6,-0.5>, rgb <0.5,0.5,0.7>)
CopperBars()
plane { y, 0 pigment { rgb <0.02,0.02,0.05> } finish { ambient 0.1 reflection { 0.5 } } }
union { DotBall(2.0, 0.14, 16, clock*360, rgb <0.3,1.0,1.0>) translate <0,3.2,6> }
Retro_Camera(<0,3.5,-5>, <0,3.2,6>)
