// grand_battle.pov — the whole roster: charging orcs, holding footmen, volleying
// archers, flanking cavalry, before the keep. WC1 iso; VGA-ify for the finale.
#include "retro90s.inc"
#include "warcraft_rigged.inc"
#include "warcraft.inc"
global_settings { ambient_light rgb 0.55 }
background { rgb <0.16,0.18,0.30> }
light_source { <-60,90,-50> color rgb <1.0,0.90,0.72> }
light_source { <40,30,-60> color rgb <0.30,0.32,0.42> shadowless }
plane { y, 0 texture { pigment { checker color rgb <0.20,0.32,0.10> color rgb <0.26,0.38,0.12> scale 3 } finish { ambient 0.5 diffuse 0.6 specular 0 } } }
Keep(3, 21) Barracks(9, 21)

#declare cyc = clock*2*pi*3;
// CHARGING ORCS (from the left, advancing right)
#macro MO(zp, ph, xb)
  #local c = cyc + ph;
  SkeletonOrc(<-11+xb+clock*6.5, 0.06*abs(sin(c)), zp>, -90, 5,0, sin(c+pi)*22,8,16, sin(c)*22,8,16, sin(c)*30,-(0.5-0.5*cos(c))*45-6, -sin(c)*30,-(0.5-0.5*cos(c+pi))*45-6)
#end
MO(6,0,0) MO(8.5,1.6,-1.6) MO(11,3.1,-0.8) MO(13,2.2,-3.2)
// HOLDING FOOTMEN (right, facing the orcs, ready stance)
SkeletonFootman(<5,0,6.5>, 90, 6,0, 32,18,34, -22,8,24, 16,-12, -16,-12)
SkeletonFootman(<6,0,9>, 90, 6,0, 32,18,34, -22,8,24, 16,-12, -16,-12)
SkeletonFootman(<4.5,0,11.5>, 90, 6,0, 32,18,34, -22,8,24, 16,-12, -16,-12)
// VOLLEYING ARCHERS (behind footmen, firing on the orcs)
#declare shot = mod(clock*1.5,1.0);
#if (shot < 0.6) #declare dr = shot/0.6; #declare fl = 0; #else #declare dr = 0; #declare fl = (shot-0.6)*38; #end
SkeletonArcher(<8,0,7.5>, 90, dr, fl)  SkeletonArcher(<8.5,0,10.5>, 90, dr, fl)
union {
  #declare i = 0;
  #while (i < 12)
    #declare pg = mod(clock*1.5 + i*0.085, 1.0);
    #declare ax = 7.5 - pg*12;  #declare az = 7 + mod(i*2.3,6);
    #declare ay = 1.6 + pg*5.5 - pg*pg*6.0;
    cylinder { <ax+0.25,ay+0.1,az>, <ax-0.45,ay-0.35,az>, 0.04 texture { RG_Wood } }
    cone { <ax-0.45,ay-0.35,az>, 0.08, <ax-0.65,ay-0.5,az>, 0.0 texture { RG_Steel } }
    #declare i = i + 1;
  #end
}
// FLANKING CAVALRY (galloping in across the front)
MountedKnight(<-8+clock*9, 0, 2.5>, -90, clock*3)
MountedKnight(<-10+clock*9, 0, 3.8>, -90, clock*3+1.5)

camera { orthographic location <46,34,-40> look_at <0,1.8,9> right x*40 up y*23 }
