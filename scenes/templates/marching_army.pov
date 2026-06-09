// marching_army.pov — rigged orcs and footmen CHARGING (walk cycle + advance)
// toward each other into a clash. WC1 iso view; VGA-ify via make_wc1_video.sh.
#include "retro90s.inc"
#include "warcraft_rigged.inc"
#include "warcraft.inc"
global_settings { ambient_light rgb 0.55 }
background { rgb <0.18,0.20,0.34> }
light_source { <-60,90,-50> color rgb <1.0,0.92,0.78> }
light_source { <40,30,-60> color rgb <0.3,0.32,0.42> shadowless }
plane { y, 0 texture { pigment { checker color rgb <0.20,0.32,0.10> color rgb <0.26,0.38,0.12> scale 3 } finish { ambient 0.5 diffuse 0.6 specular 0 } } }
Keep(0, 20) Barracks(7, 20)

// one marching orc (faces +x, charges right); ph = gait phase
#macro MarchOrc(xb, zp, ph)
  #local c = clock*2*pi*3 + ph;
  #local ux = -10 + xb + clock*7.5;
  SkeletonOrc(<ux, 0.06*abs(sin(c)), zp>, -90, 5, 0,
     sin(c+pi)*24,8,16, sin(c)*24,8,16,
     sin(c)*30, -(0.5-0.5*cos(c))*45-6, -sin(c)*30, -(0.5-0.5*cos(c+pi))*45-6)
#end
// one marching footman (faces -x, charges left)
#macro MarchFoot(xb, zp, ph)
  #local c = clock*2*pi*3 + ph;
  #local ux = 10 - xb - clock*7.5;
  SkeletonFootman(<ux, 0.06*abs(sin(c)), zp>, 90, 5, 0,
     sin(c+pi)*22,16,22, sin(c)*22,8,16,
     sin(c)*30, -(0.5-0.5*cos(c))*45-6, -sin(c)*30, -(0.5-0.5*cos(c+pi))*45-6)
#end

MarchOrc(0, 6, 0)    MarchOrc(-2.2, 8.5, 1.6)  MarchOrc(-1.0, 11, 3.1)  MarchOrc(-4.0, 10, 0.8)
MarchFoot(0, 6, 0.5) MarchFoot(-2.2, 8.5, 2.1) MarchFoot(-1.0, 11, 3.6) MarchFoot(-4.0, 10, 1.3)

camera { orthographic location <44,34,-40> look_at <0,1.8,8> right x*34 up y*19.5 }
