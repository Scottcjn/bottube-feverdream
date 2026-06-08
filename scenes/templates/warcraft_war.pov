// warcraft_war.pov — composed siege: orc horde vs human line before the keep,
// catapult support, red dragon overhead. Animated clash + flyover via clock.
#include "retro90s.inc"
#include "warcraft.inc"
Retro_Sky_Gradient(rgb <0.18,0.22,0.42>, rgb <0.78,0.55,0.38>)   // war-dusk
Retro_Sun(<-0.5,0.7,-0.45>, rgb <1.0,0.80,0.52>)
plane { y, 0 Tex_Worn(rgb <0.23,0.40,0.15>, rgb <0.30,0.23,0.11>) }

// --- human base (back) ---
Keep(-1.5, 17)
Barracks(4.5, 17)
Farm(-8, 15)

#declare Clash = sin(clock*6*pi);

// --- orc horde (left, angled in) ---
object { OrcGrunt(0) rotate y*-22 rotate z*(-14*Clash) translate <-2.8,0,6> }      // melee
object { OrcGrunt(0) rotate y*-22 translate <-5.4,0,8.5> }
object { OrcGrunt(0) rotate y*-22 translate <-7.0,0,5.5> }
Peon(-8.6)
object { Catapult(0) rotate y*-18 translate <-9.5,0,10> }

// --- human line (right, angled in) ---
object { Footman(0) rotate y*22 rotate z*(14*Clash) translate <2.8,0,6> }          // melee
object { Footman(0) rotate y*22 translate <5.4,0,8.5> }
object { Footman(0) rotate y*22 translate <7.0,0,5.5> }

// --- red dragon strafing over the field ---
#declare DX = -13 + clock*26;
object { Dragon(0,0,0) rotate y*-90 translate <DX, 8.0 + sin(clock*8*pi)*0.5, 12> }

Retro_Camera(<0,5.6,-13>, <0,2.4,7>)
