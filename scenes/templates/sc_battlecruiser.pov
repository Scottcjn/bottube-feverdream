// sc_battlecruiser.pov — Terran battlecruiser cruises over a planet and fires a
// Yamato blast: a charging orb at the forward battery, then a thick beam forward.
// Space backdrop + deterministic starfield. Iso ortho cam, VGA-ify pipeline.
#include "retro90s.inc"
#include "starcraft.inc"
global_settings { ambient_light rgb 0.5 }
background { rgb <0.02,0.02,0.06> }
light_source { <-60,70,-50> color rgb <0.85,0.88,1.0> }
light_source { <50,20,-40> color rgb <0.18,0.20,0.34> shadowless }

// --- deterministic starfield: small emissive points scattered behind the action ---
#declare RS = seed(80486);
#declare i = 0;
#while (i < 140)
  #local sx = -40 + rand(RS)*90;
  #local sy =  -6 + rand(RS)*44;
  #local sb = 0.5 + rand(RS)*0.5;
  sphere { <sx, sy, 38>, 0.06 + rand(RS)*0.10
    texture { pigment { rgb <sb,sb,sb*1.05> } finish { ambient 3.0 } } }
  #declare i = i + 1;
#end

// --- a planet curving across the bottom of frame (ReBoot-ish horizon) ---
sphere { <6, -34, 18>, 40
  texture {
    pigment { gradient y color_map { [0 rgb <0.10,0.18,0.30>][0.5 rgb <0.16,0.30,0.42>][1 rgb <0.30,0.46,0.55>] } scale 40 translate <0,-34,0> }
    finish { ambient 0.35 diffuse 0.7 specular 0 }
  }
}

// --- timing: charge orb builds, then a Yamato beam spikes ---
#declare charge = select(0.58 - clock, 0, clock/0.58);     // 0->1 by 0.58, then 0
#declare beam   = max(0, 1 - abs(clock - 0.70)/0.13);      // spike ~0.57..0.83

// --- a battlecruiser with a Yamato cannon at its forward battery ---
#macro YamatoCruiser(Pos, faceDeg, ch, bm)
  #local muz = vrotate(<0,0.4,-3.9>, y*faceDeg) + Pos;       // muzzle, world
  #local fwd = vnormalize(vrotate(<0,0,-1>, y*faceDeg));     // forward dir, world
  Battlecruiser(Pos, faceDeg)
  #if (ch > 0.01)                                            // charging orb
    sphere { muz, 0.2 + 0.85*ch
      texture { pigment { rgbt <1,0.3,0.2, 1-ch> } finish { ambient 3.0 } } }
    light_source { muz color rgb <1,0.4,0.3>*(ch*2.2) shadowless }
  #end
  #if (bm > 0.01)                                            // the beam
    cylinder { muz, muz + fwd*44, 0.30 + 0.70*bm
      texture { pigment { rgbt <1,0.45,0.3, 0.35> } finish { ambient 3.0 } } }
    cylinder { muz, muz + fwd*44, 0.10 + 0.22*bm
      texture { pigment { rgbt <1,0.95,0.8, 0.0> } finish { ambient 4.0 } } } // hot core
    light_source { muz + fwd*9 color rgb <1,0.6,0.4>*(bm*3) shadowless }
  #end
#end

// the capital ship, drifting slowly across as it fires
YamatoCruiser(<10 - clock*4, 9, 9>, -90, charge, beam)

camera { orthographic location <46,34,-40> look_at <1,4,9> right x*38 up y*22 }
