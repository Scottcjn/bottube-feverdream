// tinkertoy.pov — "Tinker Toy Windmill"
// An early-Pixar tabletop: warm key light, soft checker floor, glossy primary
// plastic. A classic Tinker Toy build -- natural-wood spool hubs and bright
// colored rods -- assembled into a windmill whose sails slowly turn. The look
// nods to Luxo Jr. / Tin Toy (1986-88): simple geometric toys with warmth.

#include "retro90s.inc"

// Soft warm sky — a lit room, not an outdoor sunset.
Retro_Sky_Gradient(
  rgb <0.52, 0.64, 0.88>,    // top: gentle sky blue
  rgb <1.00, 0.88, 0.66>)    // horizon: warm cream

// High, warm key light for soft early-CGI shadows.
Retro_Sun(<-0.45, 0.85, -0.35>, rgb <1.00, 0.96, 0.86>)

// The tabletop: a warm cream-and-walnut checkerboard, lightly polished.
Retro_Checker_Floor(rgb <0.93, 0.90, 0.83>, rgb <0.52, 0.31, 0.19>, 0.14)

// --- Tinker Toy palette -----------------------------------------------------
#declare Wood = rgb <0.82, 0.58, 0.32>;   // natural birch spool
#declare Rod  = array[6] {
  rgb <0.88, 0.16, 0.16>,   // red
  rgb <0.16, 0.36, 0.88>,   // blue
  rgb <0.16, 0.72, 0.28>,   // green
  rgb <0.97, 0.82, 0.16>,   // yellow
  rgb <0.97, 0.52, 0.12>,   // orange
  rgb <0.62, 0.24, 0.72>    // violet
}

// --- the stand: base spool + upright mast + hub spool -----------------------
cylinder { <0, 0.00, 0>, <0, 0.30, 0>, 0.60 Retro_Plastic(Wood) }   // base spool
cylinder { <0, 0.30, 0>, <0, 2.30, 0>, 0.09 Retro_Plastic(Rod[1]) } // blue mast

#declare HubY = 2.30;
cylinder { <0, HubY, 0>, <0, HubY + 0.28, 0>, 0.52 Retro_Plastic(Wood) }  // hub spool

// --- the sails: six colored rods radiating from the hub, each capped by a
//     small wood spool. Wrapped in a union so the whole wheel slowly turns. ---
union {
  #declare i = 0;
  #while (i < 6)
    #declare ang = i * 60;
    #declare ex = 1.85 * cos(radians(ang));
    #declare ez = 1.85 * sin(radians(ang));
    cylinder { <0, HubY + 0.14, 0>, <ex, HubY + 0.14, ez>, 0.07 Retro_Plastic(Rod[i]) }
    cylinder { <ex, HubY, ez>, <ex, HubY + 0.28, ez>, 0.30 Retro_Plastic(Wood) }
    // a short bright stub off each end spool, for that busy Tinker Toy silhouette
    cylinder { <ex, HubY + 0.14, ez>,
               <ex * 1.28, HubY + 0.55, ez * 1.28>, 0.06 Retro_Plastic(Rod[mod(i + 2, 6)]) }
    #declare i = i + 1;
  #end
  rotate y * (clock * 300)     // the windmill turns as the camera orbits
}

// A couple of loose Tinker Toy pieces resting on the table, for scale + charm.
cylinder { <2.6, 0.0, -1.4>, <2.6, 0.22, -1.4>, 0.42 Retro_Plastic(Wood) }
cylinder { <2.6, 0.11, -1.4>, <3.9, 0.11, -0.7>, 0.06 Retro_Plastic(Rod[0]) }
sphere    { <-2.7, 0.35, 1.2>, 0.35 Retro_Plastic(Rod[3]) }

// Tabletop hero camera, raised so the checkerboard recedes to the horizon --
// the classic early-Pixar three-quarter tabletop view. Orbits the windmill.
Retro_Orbit_Camera(7.2, 3.9, <0, 1.7, 0>)
