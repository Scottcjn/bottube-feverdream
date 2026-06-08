// veggie_friends.pov — generic googly-eyed singing vegetables in the early-CGI
// style (think 1993-era smooth-shaded talking-veggie cartoons). No trademarks:
// just a friendly Tomato and Cucumber. They bob with the `clock` for animation.
#include "retro90s.inc"

Retro_Sky_Gradient(rgb <0.35,0.55,0.95>, rgb <1.0,0.85,0.55>)   // bright kitchen morning
Retro_Sun(<-0.4,0.7,-0.4>, rgb <1.0,0.97,0.9>)
Retro_Checker_Floor(rgb <0.95,0.95,0.92>, rgb <0.55,0.35,0.20>, 0.18)  // tile counter

// bob offsets (animate via clock; 0 on a still)
#declare BobT = sin(clock*2*pi)*0.22;
#declare BobC = sin((clock+0.5)*2*pi)*0.22;

#declare EyeWhite = texture { pigment { rgb 1 } finish { phong 0.5 ambient 0.4 } }
#declare EyePupil = texture { pigment { rgb 0.02 } finish { phong 0.7 ambient 0.2 } }

// --- Tomato (squashed red sphere + little stem + eyes) ---
union {
  sphere { 0, 1.2 scale <1,0.9,1> Retro_Plastic(rgb <0.85,0.13,0.09>) }
  cone { <0,1.0,0>, 0.18, <0,1.3,0>, 0.0 Retro_Plastic(rgb <0.30,0.55,0.18>) }
  sphere { <-0.42,0.55,-1.02>, 0.27 texture { EyeWhite } }
  sphere { < 0.42,0.55,-1.02>, 0.27 texture { EyeWhite } }
  sphere { <-0.42,0.55,-1.23>, 0.13 texture { EyePupil } }
  sphere { < 0.42,0.55,-1.23>, 0.13 texture { EyePupil } }
  translate <-1.7, 1.15+BobT, 10.5>
}

// --- Cucumber (tall rounded capsule + eyes) ---
union {
  merge {
    cylinder { <0,0,0>, <0,2.0,0>, 0.55 }
    sphere { <0,0,0>, 0.55 }
    sphere { <0,2.0,0>, 0.55 }
    Retro_Plastic(rgb <0.35,0.70,0.20>)
  }
  sphere { <-0.30,1.7,-0.56>, 0.22 texture { EyeWhite } }
  sphere { < 0.30,1.7,-0.56>, 0.22 texture { EyeWhite } }
  sphere { <-0.30,1.7,-0.73>, 0.11 texture { EyePupil } }
  sphere { < 0.30,1.7,-0.73>, 0.11 texture { EyePupil } }
  translate <1.7, 0.7+BobC, 10.5>
}


Retro_Camera(<0,2.6,2.0>, <0,1.5,10.5>)
