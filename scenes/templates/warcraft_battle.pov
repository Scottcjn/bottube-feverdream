// warcraft_battle.pov — orc grunt vs human footman before a stone keep.
// Chunky Warcraft-1-era fantasy CGI. Generic, no trademarks.
#include "retro90s.inc"
#include "warcraft.inc"
Retro_Sky_Gradient(rgb <0.22,0.26,0.40>, rgb <0.70,0.58,0.42>)
Retro_Sun(<-0.5,0.7,-0.4>, rgb <1.0,0.85,0.6>)
plane { y, 0 Tex_Worn(rgb <0.24,0.42,0.16>, rgb <0.30,0.24,0.12>) }
Keep(0, 11)
OrcGrunt(-2.6)
object { Footman(2.6) rotate y*-25 }
Retro_Camera(<0,3.2,-8.5>, <0,2.0,4>)
