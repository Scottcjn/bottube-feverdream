// mainframe_residents_smooth.pov — the Mainframe cast rebuilt with smooth blob
// bodies (1982 metaball technique) + Tier-1 textures. Compare to the stacked-
// primitive mainframe_residents.pov. Panning reveal via clock.
#include "retro90s.inc"
#include "retro90s_characters.inc"

Retro_Sky_Gradient(rgb <0.12,0.22,0.70>, rgb <0.55,0.92,1.0>)
Retro_Sun(<-0.3,0.85,-0.4>, rgb <1.0,0.98,0.92>)
Retro_Grid_Floor(rgb <0.25,1.0,1.0>, rgb <0.10,0.30,0.55>, 0.05)

BlobVirus(-4.6)
BlobGuardian(-1.7, 1.0, rgb <0.93,0.95,1.0>, rgb <0.97,0.55,0.10>)
BlobGuardian(0.4, 0.62, rgb <0.93,0.95,1.0>, rgb <0.15,0.75,0.35>)   // kid sprite
BlobBinome1(2.7, rgb <0.15,0.75,0.35>)
BlobBinome0(4.2, rgb <0.97,0.55,0.10>)

Retro_Camera(<-4.0+clock*8, 3.0, -11.5>, <-2.0+clock*4, 1.6, 0>)
