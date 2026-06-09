// base_to_war.pov — a timed sequence: peons/peasants BUILD the base (clock<0.5),
// then the army MARCHES OUT (clock>=0.5). Distinct orc-peon vs peasant looks + a
// log-hauler. WC1 iso; VGA-ify for the finale.
#include "retro90s.inc"
#include "warcraft_rigged.inc"
#include "warcraft.inc"
global_settings { ambient_light rgb 0.55 }
background { rgb <0.16,0.18,0.30> }
light_source { <-60,90,-50> color rgb <1.0,0.90,0.72> }
light_source { <40,30,-60> color rgb <0.30,0.32,0.42> shadowless }
plane { y, 0 texture { pigment { checker color rgb <0.20,0.32,0.10> color rgb <0.26,0.38,0.12> scale 3 } finish { ambient 0.5 diffuse 0.6 specular 0 } } }
Keep(3,21) Barracks(8.5,21) Farm(-8,19)

// marching orc (war phase): advances -x, walk cycle
#macro WarOrc(zp, ph)
  #local c = (clock-0.5)*2*2*pi*3 + ph;
  #local ux = 5 - (clock-0.5)*2*11;
  SkeletonOrc(<ux, 0.06*abs(sin(c)), zp>, 90, 5,0, sin(c+pi)*22,8,16, sin(c)*22,8,16, sin(c)*28,-(0.5-0.5*cos(c))*42-6, -sin(c)*28,-(0.5-0.5*cos(c+pi))*42-6)
#end
#macro WarFoot(zp, ph)
  #local c = (clock-0.5)*2*2*pi*3 + ph;
  #local ux = 6 - (clock-0.5)*2*11;
  SkeletonFootman(<ux, 0.06*abs(sin(c)), zp>, 90, 5,0, sin(c+pi)*22,8,16, sin(c)*22,8,16, sin(c)*28,-(0.5-0.5*cos(c))*42-6, -sin(c)*28,-(0.5-0.5*cos(c+pi))*42-6)
#end

#if (clock < 0.5)
  // ---- BUILD PHASE ----
  #declare wp = clock*3;
  WC_Tree(<-6,0,11>)
  SkeletonWorker(<-6,0,9.2>, 180, rgb<0.30,0.52,0.22>, 1, wp, 1)
  WC_Rock(<-1.5,0,11.5>)
  SkeletonWorker(<-1.5,0,9.6>, 180, rgb<0.30,0.52,0.22>, 2, wp+0.33, 1)
  union { box{<4.4,0,9>,<5.0,1.0,9.6> texture{WC_Stone}} box{<5.0,0,9>,<5.6,0.6,9.6> texture{WC_Stone}} box{<4.4,1.0,9>,<5.0,1.5,9.6> texture{WC_Stone}} }
  SkeletonWorker(<5,0,9.6>, 180, rgb<0.85,0.72,0.55>, 3, wp+0.66, 2)
  // hauler carrying logs toward the keep
  SkeletonHauler(<-6 + clock*18, 0, 6.5>, -90, rgb<0.30,0.52,0.22>, clock*5, 1, 1)
#else
  // ---- WAR PHASE: the army marches out ----
  WarOrc(6,0) WarOrc(8,1.6) WarOrc(10,3.1)
  WarFoot(6.8,0.8) WarFoot(9,2.4)
  MountedKnight(<6 - (clock-0.5)*2*12, 0, 3.5>, 90, (clock-0.5)*2*3)
#end

camera { orthographic location <46,34,-40> look_at <0,1.8,9> right x*40 up y*23 }
