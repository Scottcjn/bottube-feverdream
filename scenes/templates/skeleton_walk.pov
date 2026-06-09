// skeleton_walk.pov — a clock-driven WALK CYCLE on the FK skeleton. Legs stride
// in opposite phase, knees flex on the lift, arms counter-swing, body bobs.
#include "retro90s.inc"
#include "skeleton.inc"
Retro_Sky_Gradient(rgb <0.35,0.5,0.85>, rgb <0.7,0.92,1.0>)
Retro_Sun(<-0.4,0.8,-0.35>, rgb <1.0,0.98,0.92>)
Retro_Checker_Floor(rgb <0.85,0.88,0.95>, rgb <0.4,0.55,0.78>, 0.12)

#declare cyc = clock*2*pi*2;                 // 2 stride cycles across the clip
#declare hipL = sin(cyc)*32;
#declare hipR = sin(cyc + pi)*32;
#declare kneeL = -(0.5 - 0.5*cos(cyc))*45 - 6;     // flex, most on the back-swing
#declare kneeR = -(0.5 - 0.5*cos(cyc + pi))*45 - 6;
#declare armL = sin(cyc + pi)*24;            // arms opposite to same-side leg
#declare armR = sin(cyc)*24;
#declare bobY = 0.06*abs(sin(cyc)) ;         // body bob (2x leg freq feel)
#declare walkX = -4.2 + clock*8.4;           // stride across the floor

// faces +x (direction of travel) so we see the stride in profile/3-4
SkeletonHumanoid(<walkX, bobY, 0>, -90, 5, 0,
   armL,8,18,  armR,8,18,  hipL,kneeL, hipR,kneeR, rgb <0.30,0.62,0.95>)

Retro_Camera(<walkX-1.2,2.2,-6.5>, <walkX+0.4,1.35,1.0>)
