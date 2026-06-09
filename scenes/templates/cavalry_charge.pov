// cavalry_charge.pov — galloping mounted knights with couched lances charge a
// braced orc line. Horse gallop + knight bob driven by clock.
#include "retro90s.inc"
#include "warcraft_rigged.inc"
#include "warcraft.inc"
Retro_Sky_Gradient(rgb <0.26,0.36,0.62>, rgb <0.82,0.62,0.42>)
Retro_Sun(<-0.5,0.8,-0.35>, rgb <1.0,0.88,0.62>)
Retro_Checker_Floor(rgb <0.30,0.45,0.18>, rgb <0.24,0.36,0.14>, 0.05)

// galloping knight charging +x; ph offsets the gait, xb the column
#macro Charger(zp, ph, xb)
  MountedKnight(<-9 + xb + clock*13, 0, zp>, -90, clock*3 + ph)
#end
Charger(5.5, 0.0, 0)
Charger(8.0, 1.3, -1.5)
Charger(10.5, 2.6, -0.5)

// braced orcs awaiting the charge (right side)
object { OrcGrunt(0) rotate y*90 translate <7.5,0,6> }
object { OrcGrunt(0) rotate y*90 translate <8.5,0,9> }

Retro_Camera(<-2.5,4.6,-8.5>, <2.0,2.6,7>)
