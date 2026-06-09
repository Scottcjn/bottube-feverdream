// sc_skirmish.pov — generic StarCraft-style skirmish: marines + siege tank hold,
// zerglings rush, a pylon powers, a battlecruiser passes over. Sci-fi iso, VGA-ify.
#include "retro90s.inc"
#include "starcraft.inc"
global_settings { ambient_light rgb 0.5 }
background { rgb <0.05,0.05,0.10> }
light_source { <-50,80,-50> color rgb <0.9,0.9,1.0> }
light_source { <40,30,-60> color rgb <0.25,0.28,0.4> shadowless }
plane { y, 0 texture { pigment { checker color rgb <0.22,0.20,0.18> color rgb <0.28,0.26,0.22> scale 3 } finish { ambient 0.45 diffuse 0.55 specular 0 } } }

Pylon(<8.5, 0, 12>, clock)
SiegeTank(<6.5, 0, 10>, 90)
Marine(<4, 0, 7>, 90)  Marine(<5, 0, 9>, 90)  Marine(<3.5, 0, 11>, 90)

#declare zr = clock*5;   // skitter
Zergling(<-4+clock*5, 0, 7>, -90, zr)
Zergling(<-5.5+clock*5, 0, 9>, -90, zr+0.3)
Zergling(<-4.5+clock*5, 0, 11>, -90, zr+0.6)
Zergling(<-6.5+clock*5, 0, 8.5>, -90, zr+0.9)

Battlecruiser(<-3+clock*5, 8, 9>, -90)

camera { orthographic location <46,34,-40> look_at <1,2,9> right x*38 up y*22 }
