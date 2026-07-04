// concept_turntable.pov — "Concept One: 3D Perspective View"
// A Wavefront-demo product turntable: a sleek hot-orange concept vehicle with
// chrome wheels and canopy, parked on a thin display plinth, slowly spinning
// under a soft studio sky over a faint perspective grid. The camera holds a
// fixed 3/4 hero angle so the turntable rotation reads. Pure 1992 product-viz.

#include "retro90s.inc"

// Soft studio sky — cool grey up top fading to a warm near-white horizon, the
// classic seamless product-shot backdrop.
Retro_Sky_Gradient(
  rgb <0.42, 0.50, 0.64>,    // top: cool studio grey-blue
  rgb <0.93, 0.91, 0.86>)    // horizon: warm seamless white

// Warm key light, high and to the left — a soft product-shot key.
Retro_Sun(<-0.55, 0.78, -0.30>, rgb <1.00, 0.95, 0.84>)

// Faint technical perspective grid — the "3D PERSPECTIVE VIEW" Wavefront floor.
Retro_Grid_Floor(rgb <0.32, 0.52, 0.72>, rgb <0.84, 0.86, 0.90>, 1.2)

// --- palette -----------------------------------------------------------------
#declare HotOrange = rgb <0.95, 0.45, 0.10>;   // bold concept-car orange
#declare ChromeSil = rgb <0.85, 0.88, 0.95>;   // bright chrome
#declare DarkTire  = rgb <0.10, 0.10, 0.12>;   // near-black tire

// --- the display plinth: a thin rectangular box with a chrome trim edge ------
box { <-2.7, 0.00, -2.1>, <2.7, 0.30, 2.1> Retro_Plastic(rgb <0.14, 0.15, 0.18>) }
box { <-2.75, 0.30, -2.15>, <2.75, 0.38, 2.15> Retro_Chrome(ChromeSil) }  // chrome cap

// --- the hero: a sleek concept vehicle, wrapped in a union that spins ---------
union {
  // Low sculptural body — a rounded superellipsoid slab, the concept form.
  superellipsoid { <0.35, 0.55>
    scale <2.05, 0.46, 0.98>
    translate <0, 1.14, 0>
    Retro_Plastic(HotOrange)
  }
  // Tapered nose wedge blended off the front (+x), for a low aggressive prow.
  cone { <2.55, 1.08, 0>, 0.02, <1.4, 1.14, 0>, 0.62
    scale <1, 0.7, 1> translate <0, 0.34, 0>
    Retro_Plastic(HotOrange)
  }
  // Chrome bubble canopy set forward on the deck.
  sphere { <0, 0, 0>, 1
    scale <0.92, 0.42, 0.66>
    translate <0.35, 1.52, 0>
    Retro_Chrome(ChromeSil)
  }
  // Rear spoiler — a thin chrome wing on two little posts.
  box { <-2.05, 1.60, -0.85>, <-1.75, 1.66, 0.85> Retro_Chrome(ChromeSil) }
  cylinder { <-1.9, 1.40, -0.62>, <-1.9, 1.60, -0.62>, 0.05 Retro_Chrome(ChromeSil) }
  cylinder { <-1.9, 1.40,  0.62>, <-1.9, 1.60,  0.62>, 0.05 Retro_Chrome(ChromeSil) }

  // A bright chrome side accent strip down each flank.
  box { <-1.7, 1.02, -1.00>, <1.9, 1.10, -0.94> Retro_Chrome(ChromeSil) }
  box { <-1.7, 1.02,  0.94>, <1.9, 1.10,  1.00> Retro_Chrome(ChromeSil) }

  // Headlights — small chrome pods at the prow.
  sphere { <2.2, 1.16, -0.42>, 0.16 Retro_Chrome(ChromeSil) }
  sphere { <2.2, 1.16,  0.42>, 0.16 Retro_Chrome(ChromeSil) }

  // Four wheels — dark tires with bright chrome hubs, resting on the plinth.
  #declare wx = 1.42;
  #declare wz = 0.94;
  #declare k = 0;
  #while (k < 4)
    #declare sx = wx * (1 - 2 * mod(k, 2));          // +x front / -x rear pairs
    #declare sz = wz * (1 - 2 * div(k, 2));          // +z / -z sides
    // tire (cylinder axle along z)
    cylinder { <sx, 0.70, sz - 0.14>, <sx, 0.70, sz + 0.14>, 0.36 Retro_Plastic(DarkTire) }
    // chrome hub cap on the outer face
    sphere { <sx, 0.70, sz + 0.15 * (1 - 2 * div(k, 2))>, 0.20 Retro_Chrome(ChromeSil) }
    #declare k = k + 1;
  #end

  // Spin the whole vehicle on the turntable (camera stays fixed).
  rotate y * (clock * 360)
}

// Fixed 3/4 hero camera — front-right, slightly raised, so the spin reads.
Retro_Camera(<5.4, 3.0, -5.6>, <0, 1.15, 0>)
