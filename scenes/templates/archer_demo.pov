#include "retro90s.inc"
#include "warcraft_rigged.inc"
Retro_Sky_Gradient(rgb <0.35,0.5,0.85>, rgb <0.7,0.92,1.0>)
Retro_Sun(<-0.4,0.8,-0.35>, rgb <1.0,0.98,0.92>)
Retro_Checker_Floor(rgb <0.30,0.45,0.18>, rgb <0.24,0.36,0.14>, 0.05)
// draw-and-loose cycle: draw 0->1, then loose (arrow flies)
#declare shot = mod(clock*2.0, 1.0);
#if (shot < 0.78)
  SkeletonArcher(<0,0,0>, -90, shot/0.78, 0)
#else
  SkeletonArcher(<0,0,0>, -90, 0, (shot-0.78)*42)
#end
Retro_Camera(<-3.5,2.4,-5.0>, <0.5,1.5,0>)
