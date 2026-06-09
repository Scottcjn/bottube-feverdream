// sc_siege.pov — Terran siege line shelling: tanks recoil + muzzle-flash on each
// shot, impacts bloom on the target side a beat later. Iso ortho cam, VGA-ify.
#include "retro90s.inc"
#include "starcraft.inc"
global_settings { ambient_light rgb 0.5 }
background { rgb <0.05,0.05,0.10> }
light_source { <-50,80,-50> color rgb <0.9,0.9,1.0> }
light_source { <40,30,-60> color rgb <0.25,0.28,0.4> shadowless }
plane { y, 0 texture { pigment { checker color rgb <0.22,0.20,0.18> color rgb <0.28,0.26,0.22> scale 3 } finish { ambient 0.45 diffuse 0.55 specular 0 } } }

// --- fire cadence: three shots across the clip, sharp attack/decay ---
#macro Beat(Phase, W)
  #local d = abs(clock - Phase);
  ( select(W - d, 0, 1 - d/W) )
#end
// rolling barrage — each tank fires on its own beats (never all at once)
#declare fireA = max(Beat(0.10,0.07), Beat(0.58,0.07));
#declare fireB = max(Beat(0.26,0.07), Beat(0.74,0.07));
#declare fireC = max(Beat(0.42,0.07), Beat(0.90,0.07));
// impacts land just after each muzzle leaves (shell travel)
#declare hitA = max(Beat(0.17,0.06), Beat(0.65,0.06));
#declare hitB = max(Beat(0.33,0.06), Beat(0.81,0.06));
#declare hitC = max(Beat(0.49,0.06), Beat(0.97,0.06));

// --- a siege tank that recoils and flashes; flash tracks faceDeg via vrotate ---
#macro FireTank(Pos, faceDeg, fr)
  #local tipw   = vrotate(<0,1.0,-2.95>, y*faceDeg) + Pos;   // muzzle tip, world
  #local recoil = vrotate(<0,0,0.45>,    y*faceDeg) * fr;    // kick straight back
  SiegeTank(Pos + recoil, faceDeg)
  #if (fr > 0.01)
    sphere { tipw, 0.18 + 0.30*fr
      texture { pigment { rgbt <1,0.85,0.45, 1-fr> } finish { ambient 2.2 } } }
    light_source { tipw color rgb <1.0,0.8,0.45>*(fr*1.4) shadowless }
  #end
#end

// --- an impact bloom: low dome of fire + dust + flash light ---
#macro Impact(Pos, h)
  #if (h > 0.01)
    sphere { Pos + <0,0.4,0>, 0.4 + 1.1*h
      texture { pigment { rgbt <1,0.55,0.2, 1-h> } finish { ambient 2.2 } } }
    sphere { Pos + <0,0.3,0>, 0.7 + 1.6*h
      texture { pigment { rgbt <0.6,0.55,0.5, 1-0.4*h> } finish { ambient 0.7 } } }
    light_source { Pos + <0,1,0> color rgb <1,0.6,0.3>*(h*2.0) shadowless }
  #end
#end

// the siege line (facing -x toward the target field), staggered
FireTank(<7.0, 0,  6>, 90, fireA)
FireTank(<8.0, 0, 10>, 90, fireB)
FireTank(<6.5, 0, 13>, 90, fireC)

// a couple marines dug in behind the line
Marine(<10, 0, 8>, 90)  Marine(<10.5, 0, 12>, 90)

// shells land on the left target field (each tank's own impact)
Impact(<-9, 0,  7>, hitA)
Impact(<-11,0, 11>, hitB)
Impact(<-8, 0, 13>, hitC)

camera { orthographic location <46,34,-40> look_at <1,2,9> right x*38 up y*22 }
