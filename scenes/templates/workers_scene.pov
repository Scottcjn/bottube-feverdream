// workers_scene.pov — peons and peasants at work: chopping, mining, building.
// SkeletonWorker swings a tool on a work cycle (workPhase driven by clock).
#include "retro90s.inc"
#include "warcraft_rigged.inc"
#include "warcraft.inc"
Retro_Sky_Gradient(rgb <0.32,0.46,0.78>, rgb <0.80,0.74,0.58>)
Retro_Sun(<-0.45,0.8,-0.35>, rgb <1.0,0.95,0.78>)
Retro_Checker_Floor(rgb <0.30,0.45,0.18>, rgb <0.24,0.36,0.14>, 0.04)
Farm(-8.5, 11)  Barracks(8.5, 12)

#declare wp = clock;
// peon chopping a tree (axe)
WC_Tree(<-5,0,9.0>)
SkeletonWorker(<-5,0,7.1>, 180, rgb <0.30,0.52,0.22>, 1, wp)
// peon mining a rock (pick)
WC_Rock(<0,0,9.2>)
SkeletonWorker(<0,0,7.4>, 180, rgb <0.30,0.52,0.22>, 2, wp+0.33)
// peasant building a half-finished wall (hammer)
union {
  box { <4.4,0,8.6>, <5.0,0.9,9.2> texture { WC_Stone } }
  box { <5.0,0,8.6>, <5.6,0.6,9.2> texture { WC_Stone } }
  box { <4.4,0.9,8.6>, <5.0,1.4,9.2> texture { WC_Stone } }
}
SkeletonWorker(<5,0,7.4>, 180, rgb <0.85,0.72,0.55>, 3, wp+0.66)

Retro_Camera(<-2.5,3.2,-3.5>, <0.5,1.4,8.5>)
