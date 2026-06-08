// warcraft_base.pov — a human town: keep, barracks, farms, catapult, units.
#include "retro90s.inc"
#include "warcraft.inc"
Retro_Sky_Gradient(rgb <0.30,0.42,0.72>, rgb <0.75,0.70,0.55>)
Retro_Sun(<-0.45,0.8,-0.4>, rgb <1.0,0.92,0.75>)
plane { y, 0 Tex_Worn(rgb <0.26,0.44,0.18>, rgb <0.32,0.26,0.13>) }
Keep(-3, 13)
Barracks(4.5, 12)
Farm(-6.5, 8)
Farm(7.0, 7)
Catapult(-1.5)
object { Footman(2.0) rotate y*-10 }
Peon(0.2)
Retro_Camera(<0,4.2,-10>, <0.5,2.2,7>)
