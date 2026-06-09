// skeleton_poses.pov — one skeleton, three poses (idle / walking / attacking).
#include "retro90s.inc"
#include "skeleton.inc"
Retro_Sky_Gradient(rgb <0.35,0.5,0.85>, rgb <0.7,0.92,1.0>)
Retro_Sun(<-0.4,0.8,-0.35>, rgb <1.0,0.98,0.92>)
Retro_Checker_Floor(rgb <0.85,0.88,0.95>, rgb <0.4,0.55,0.78>, 0.12)

// IDLE — arms relaxed, legs straight
SkeletonHumanoid(<-2.6,0,0>, 0, 0, 0,  0,10,12,  0,10,12,  0,0, 0,0, rgb <0.30,0.60,0.95>)
// WALKING — mid-stride, counter-swinging arms
SkeletonHumanoid(<0,0,0>, 0, 6, -4,  -28,8,18,  28,8,18,  32,-12, -30,22, rgb <0.30,0.75,0.40>)
// ATTACKING — right arm raised to strike, lunging forward
SkeletonHumanoid(<2.6,0,0>, 0, 16, -8,  55,12,30,  -120,5,35,  28,-22, -18,12, rgb <0.85,0.35,0.25>)

Retro_Camera(<0,3.2,-8.6>, <0,1.5,0>)
