// warcraft_war_iso.pov — the siege in a WC1-style isometric RTS view + flat-lit
// tiled terrain. Render small, then pixelate/dither in post for the VGA look.
#include "retro90s.inc"
#include "warcraft.inc"
global_settings { ambient_light rgb 0.55 }       // flatter, VGA-ish
background { rgb <0.18,0.20,0.34> }
// flat directional light, minimal specular look
light_source { <-60,90,-50> color rgb <1.0,0.92,0.78> }
light_source { <40,30,-60> color rgb <0.3,0.32,0.42> shadowless }

// tiled grass/dirt terrain (square tiles, flat-lit)
plane { y, 0
  texture { pigment { checker color rgb <0.20,0.32,0.10> color rgb <0.26,0.38,0.12> scale 3 }
            finish { ambient 0.5 diffuse 0.6 specular 0 } } }

Keep(-1.5, 17)
Barracks(4.5, 17)
Farm(-8, 15)
#declare Clash = sin(clock*6*pi);
object { OrcGrunt(0) rotate y*-22 rotate z*(-14*Clash) translate <-2.8,0,6> }
object { OrcGrunt(0) rotate y*-22 translate <-5.4,0,8.5> }
object { OrcGrunt(0) rotate y*-22 translate <-7.0,0,5.5> }
Peon(-8.6)
object { Catapult(0) rotate y*-18 translate <-9.5,0,10> }
object { Footman(0) rotate y*22 rotate z*(14*Clash) translate <2.8,0,6> }
object { Footman(0) rotate y*22 translate <5.4,0,8.5> }
object { Footman(0) rotate y*22 translate <7.0,0,5.5> }
#declare DX = -13 + clock*26;
object { Dragon(0,0,0) rotate y*-90 translate <DX, 8.0, 12> }

// near-orthographic isometric RTS camera (distant + narrow angle)
camera { location <44,34,-40> look_at <0,1.8,7> angle 26 right x*image_width/image_height up y }
