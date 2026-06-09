// rigged_duel.pov — the orc and footman rebuilt on the FK skeleton, posed.
#include "retro90s.inc"
#include "warcraft_rigged.inc"
Retro_Sky_Gradient(rgb <0.30,0.42,0.72>, rgb <0.75,0.65,0.50>)
Retro_Sun(<-0.45,0.8,-0.4>, rgb <1.0,0.90,0.70>)
Retro_Checker_Floor(rgb <0.30,0.45,0.18>, rgb <0.24,0.36,0.14>, 0.05)

// orc: mid-attack (axe arm raised, lunging), facing right toward the footman
SkeletonOrc(<-1.8,0,0>, 70, 14, -6,  45,10,28,  -110,6,30,  28,-22, -16,12)
// footman: braced guard (shield up, sword back), facing left toward the orc
SkeletonFootman(<1.8,0,0>, -70, 8, -2,  35,20,40,  -40,8,30,  -20,14, 22,-18)

Retro_Camera(<0,2.6,-6.5>, <0,1.5,0>)
