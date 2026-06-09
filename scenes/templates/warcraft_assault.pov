// warcraft_assault.pov — humans and orcs in active melee: lunging attack pairs,
// a catapult boulder arcing toward the keep, a dragon swooping. WC1 iso pixel look.
#include "retro90s.inc"
#include "warcraft.inc"
global_settings { ambient_light rgb 0.55 }
background { rgb <0.18,0.20,0.34> }
light_source { <-60,90,-50> color rgb <1.0,0.92,0.78> }
light_source { <40,30,-60> color rgb <0.3,0.32,0.42> shadowless }
plane { y, 0 texture { pigment { checker color rgb <0.20,0.32,0.10> color rgb <0.26,0.38,0.12> scale 3 } finish { ambient 0.5 diffuse 0.6 specular 0 } } }

Keep(-1.5, 18) Barracks(5, 18) Farm(-9, 16)

// attack-lunge helper amounts (different phases so the field isn't in lockstep)
#declare A1 = abs(sin(clock*4*pi))*20;
#declare A2 = abs(sin(clock*4*pi + 1.7))*20;
#declare A3 = abs(sin(clock*4*pi + 3.4))*20;

// melee pair 1 (center) — orc lunges right, footman lunges left
object { OrcGrunt(0) rotate y*-30 rotate z*(-A1) translate <-1.2,0,7> }
object { Footman(0)  rotate y*120 rotate z*(A1)  translate < 1.2,0,7> }
// melee pair 2 (left flank)
object { OrcGrunt(0) rotate y*-30 rotate z*(-A2) translate <-5.0,0,9> }
object { Footman(0)  rotate y*120 rotate z*(A2)  translate <-2.8,0,9.4> }
// melee pair 3 (right flank)
object { OrcGrunt(0) rotate y*-30 rotate z*(-A3) translate < 2.8,0,5.2> }
object { Footman(0)  rotate y*120 rotate z*(A3)  translate < 5.0,0,5.2> }
// reinforcements charging in
object { OrcGrunt(0) rotate y*-30 translate <-7.5,0,11> }
Peon(-9.0)
object { Footman(0) rotate y*120 translate <7.4,0,11> }
object { Catapult(0) rotate y*-15 translate <-10,0,12.5> }

// catapult boulder arcing toward the keep
#declare BT = mod(clock*2.0, 1.0);
sphere { <-9.5 + BT*8.5, 0.6 + BT*7.0 - BT*BT*8.0, 12 + BT*6>, 0.28 texture { WC_Stone } }

// dragon swooping low across the battle then up
#declare DX = -13 + clock*26;
object { Dragon(0,0,0) rotate y*-90 translate <DX, 5.0 + abs(sin(clock*2*pi))*4.0, 9> }

camera { orthographic location <44,34,-40> look_at <0,1.8,8> right x*32 up y*18.5 }
