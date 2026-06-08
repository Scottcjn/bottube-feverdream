// warcraft_battle_anim.pov — orc vs footman clash (clock-driven lunges) with a
// red dragon flying over the keep. Animated WC1-era battle.
#include "retro90s.inc"
#include "warcraft.inc"
Retro_Sky_Gradient(rgb <0.20,0.24,0.42>, rgb <0.72,0.55,0.40>)
Retro_Sun(<-0.5,0.7,-0.4>, rgb <1.0,0.82,0.55>)
plane { y, 0 Tex_Worn(rgb <0.24,0.42,0.16>, rgb <0.30,0.24,0.12>) }
Keep(0, 13)

#declare Clash = sin(clock*6*pi);
object { OrcGrunt(0) rotate z*(-14*Clash) translate <-2.6,0,0> }
object { Footman(0)  rotate y*-22 rotate z*(14*Clash) translate <2.6,0,0> }

// red dragon strafing across, above the keep
#declare DX = -12 + clock*24;
object { Dragon(0,0,0) rotate y*-90 translate <DX, 7.2 + sin(clock*8*pi)*0.5, 10> }

Retro_Camera(<0,3.0,-8.5>, <0,2.2,5>)
