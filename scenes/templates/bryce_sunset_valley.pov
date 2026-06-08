// bryce_sunset_valley.pov — Bryce-style sunset over a fractal-terrain valley.
// Hand-authored. The look: warm magenta/amber sky, two-tone mountains
// receding into haze, a single chrome sphere hero in the foreground, the
// whole thing framed by a soft horizon glow. Uses lib/retro90s.inc.
#include "retro90s.inc"

#local SKY_TOP    = rgb <0.20, 0.05, 0.35>;   // deep magenta zenith
#local SKY_HORIZ  = rgb <1.00, 0.45, 0.20>;   // amber horizon
#local SUN_WARM   = rgb <1.10, 0.85, 0.55>;

Retro_Sky_Gradient(SKY_TOP, SKY_HORIZ)
Retro_Sun(<-0.6, 0.35, -0.7>, SUN_WARM)

// Distant mountains as a 5-octave fractal terrain; warmer near the camera,
// cooler at the peaks, so the valley reads as "receding into haze".
Retro_Fractal_Terrain(2.4, 0.30, Retro_Terrain_Texture())

// Hero chrome sphere catching the sunset on the right rim.
sphere { <3.0, 1.6, 0>, 1.4 Retro_Chrome(rgb <0.95, 0.92, 0.99>) }
sphere { <-2.5, 1.0, 1.5>, 0.9 Retro_Glass(rgb <1.0, 0.55, 0.30>) }

Retro_Camera(<8, 3.5, 8>, <0, 1.2, 0>)
