// desert_dusk.pov — "Mesa Mirage at Sundown"
// The signature Beyond-the-Mind's-Eye desert shot: a vivid violet-to-orange
// gradient sky, a dark ring of mesa silhouettes on the far horizon, a low warm
// sun, and a little cluster of mirror-chrome and colored-glass forms sitting on
// the dark sand near the origin — so every chrome face catches the sunset.
// A slow chrome-and-glass hero obelisk turns as the camera orbits. Orbit camera.

#include "retro90s.inc"
#include "beyond90s.inc"

// Vivid three-stop dusk — the signature Beyond-the-Mind's-Eye sunset: electric
// violet overhead, a hot magenta-orange band, and a yellow horizon glow that the
// chrome and the sand both drink in.
Beyond_Sunset_Sky(
  rgb <0.16, 0.10, 0.46>,    // top: deep twilight violet
  rgb <1.00, 0.30, 0.42>,    // band: hot magenta-orange
  rgb <1.00, 0.80, 0.34>)    // glow: yellow horizon

// Low, warm key light raking in near the horizon for long desert shadows and
// hard mirror highlights on the chrome.
Retro_Sun(<-0.75, 0.22, -0.55>, rgb <1.0, 0.74, 0.44>)

// --- the desert floor: a dark, faintly polished sand plane. Not a grid — the
//     chrome should mirror pure sunset sky and dark ground, the way the
//     "creature crossing the mesa" reference frame reads. -----------------------
plane {
  y, 0
  pigment { color rgb <0.14, 0.07, 0.06> }   // dark dusk-shadowed sand
  finish {
    ambient 0.18 diffuse 0.5
    reflection { 0.18 }
    phong 0.2 phong_size 40
  }
}

// --- a ring of dark mesa/butte silhouettes set way back on the far ground.
//     Varying heights + widths give the ragged Monument-Valley skyline. They sit
//     far enough out (radius ~60) that the orbit camera always frames a horizon
//     line of them behind the hero. --------------------------------------------
#declare MesaTex = texture {
  pigment { color rgb <0.05, 0.03, 0.05> }   // near-black, just catching rim light
  finish { ambient 0.14 diffuse 0.35 }
}

#declare mh = array[9] { 6.5, 11.0, 4.0, 9.0, 5.5, 13.0, 7.5, 3.5, 10.0 }
#declare mw = array[9] { 5.0,  4.0, 6.5, 3.2, 7.0,  4.5, 3.0, 5.5,  4.2 }

#declare i = 0;
#while (i < 9)
  #declare mang = i * 40 + 12;
  #declare mrad = 58 + mod(i, 3) * 7;
  #declare mx = mrad * cos(radians(mang));
  #declare mz = mrad * sin(radians(mang));
  box {
    <-mw[i], 0, -mw[i] * 0.8>, <mw[i], mh[i], mw[i] * 0.8>
    texture { MesaTex }
    translate <mx, 0, mz>
  }
  #declare i = i + 1;
#end

// --- the hero cluster, kept near the origin so the orbit camera holds it. -----

// A slow-turning obelisk: a chrome column crowned with a floating glass gem and
// flanked by a chrome sphere, all wrapped so the whole form rotates with clock.
union {
  // tapered chrome column (two stacked cones read as a polished monolith)
  cone { <0, 0, 0>, 1.1, <0, 3.4, 0>, 0.55 Retro_Chrome(rgb <0.86, 0.90, 1.0>) }
  cone { <0, 3.4, 0>, 0.55, <0, 4.2, 0>, 0.0 Retro_Chrome(rgb <1.0, 0.9, 0.78>) }
  // amber glass gem hovering above the tip, catching the sun through it
  sphere { <0, 5.0, 0>, 0.7 Retro_Glass(rgb <1.0, 0.62, 0.18>) }
  // a chrome ring around the column for reflective interest
  torus { 1.5, 0.16 Retro_Chrome(rgb <0.8, 0.85, 0.95>) translate y*1.6 }
  rotate y * (clock * 180)
}

// Big mirror-chrome sphere resting on the sand beside the obelisk.
sphere { <3.6, 1.6, 1.4>, 1.6 Retro_Chrome(rgb <0.9, 0.93, 1.0>) }

// Emerald refractive glass sphere — a cool complement to the warm sky.
sphere { <-3.2, 1.2, 2.0>, 1.2 Retro_Glass(rgb <0.18, 0.95, 0.55>) }

// Sapphire glass teardrop, small and bright, near the front.
sphere { <-1.6, 0.7, -2.4>, 0.7 Retro_Glass(rgb <0.28, 0.5, 1.0>) }

// A short chrome pylon for a long vertical reflection streak.
cylinder { <4.4, 0, -2.6>, <4.4, 3.0, -2.6>, 0.3 Retro_Chrome(rgb <0.82, 0.86, 0.96>) }

// Slow orbit, pulled back and raised so the mesa horizon and the sunset both read.
Retro_Orbit_Camera(16, 3.6, <0, 2.4, 0>)
