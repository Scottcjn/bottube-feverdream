// volley_scene.pov — a rank of rigged archers loose a volley; arrows arc down
// onto the keep. Shows the draw-and-loose rig at scale + arcing projectiles.
#include "retro90s.inc"
#include "warcraft_rigged.inc"
#include "warcraft.inc"
Retro_Sky_Gradient(rgb <0.28,0.38,0.66>, rgb <0.80,0.62,0.42>)
Retro_Sun(<-0.5,0.8,-0.3>, rgb <1.0,0.88,0.62>)
Retro_Checker_Floor(rgb <0.28,0.44,0.18>, rgb <0.22,0.34,0.12>, 0.05)
Keep(0, 18)  Barracks(6.5, 18)

// volley rhythm: all archers draw together then loose together (face +z = toward keep)
#declare shot = mod(clock*1.5, 1.0);
#if (shot < 0.6)
  #declare dr = shot/0.6;  #declare fl = 0;
#else
  #declare dr = 0;  #declare fl = (shot-0.6)*40;
#end
SkeletonArcher(<-4.2,0,3.2>, 180, dr, fl)
SkeletonArcher(<-2.1,0,2.7>, 180, dr, fl)
SkeletonArcher(< 0.0,0,3.2>, 180, dr, fl)
SkeletonArcher(< 2.1,0,2.7>, 180, dr, fl)
SkeletonArcher(< 4.2,0,3.2>, 180, dr, fl)

// arrows arcing toward the keep
union {
  #declare i = 0;
  #while (i < 18)
    #declare pg = mod(clock*1.5 + i*0.07, 1.0);
    #declare ax = -4.5 + mod(i*2.6, 9);
    #declare az = 4.5 + pg*11.5;
    #declare ay = 1.6 + pg*6.2 - pg*pg*6.6;
    cylinder { <ax,ay+0.12,az-0.25>, <ax,ay-0.35,az+0.45>, 0.04 texture { RG_Wood } }
    cone { <ax,ay-0.35,az+0.45>, 0.08, <ax,ay-0.5,az+0.65>, 0.0 texture { RG_Steel } }
    box { <ax-0.10,ay+0.02,az-0.35>, <ax+0.10,ay+0.22,az-0.25> texture { RG_Red } }
    #declare i = i + 1;
  #end
}
Retro_Camera(<-2.0,6.0,-8.5>, <0,2.8,10>)
