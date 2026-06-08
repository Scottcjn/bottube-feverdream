// grid_tunnel.pov — ReBoot-style neon grid floor receding to a twilight horizon.
// Template for the feverdream generator to re-dress.
#include "retro90s.inc"

Retro_Sky_Gradient(rgb <0.02,0.02,0.10>, rgb <0.6,0.1,0.8>)
Retro_Sun(<0.0,0.6,-0.6>, rgb <0.8,0.85,1.0>)
Retro_Grid_Floor(rgb <0.2,1.0,0.9>, rgb <0.03,0.03,0.08>, 2.0)

sphere { <-3,1.6,9>, 1.6 Retro_Chrome(rgb <0.9,0.9,1.0>) }
sphere { < 3,1.6,9>, 1.6 Retro_Glass(rgb <1.0,0.2,0.8>) }
box { <-1,0,12>, <1,3,13> Retro_Plastic(rgb <0.1,0.9,1.0>) }

Retro_Orbit_Camera(9, 3.2, <0,1.4,10>)
