// starcraft.inc — generic 1998-RTS sci-fi units: Marine (rigged), Zergling,
// Pylon, Siege Tank, Battlecruiser. No trademarks. Uses skeleton + blob + CSG.
#include "skeleton.inc"

#declare SC_Steel = Tex_BrushedMetal(rgb <0.55,0.58,0.64>)
#declare SC_Tan   = Tex_Worn(rgb <0.66,0.58,0.38>, rgb <0.50,0.44,0.28>)
#declare SC_Dark  = Tex_Plastic(rgb <0.12,0.13,0.16>)
#declare SC_Zerg  = Tex_Worn(rgb <0.52,0.36,0.42>, rgb <0.36,0.24,0.30>)
#declare SC_Bone  = Tex_Worn(rgb <0.80,0.74,0.60>, rgb <0.62,0.56,0.42>)
#declare SC_EBlue = texture { pigment { rgb <0.3,0.7,1.0> } finish { ambient 2.0 } }
#declare SC_EOrange = texture { pigment { rgb <1.0,0.55,0.15> } finish { ambient 1.8 } }

// ---- MARINE: rigged Terran trooper in power armor with a gauss rifle ----
#macro Marine(Pos, faceDeg)
  SK_Joints(8,0,  -64,14,42,  -74,10,34,  10,-12, -10,-12)
  union {
    SK_BodyBlob(rgb <0.60,0.54,0.38>, 1.4)
    // helmet + dark visor
    sphere { sk_Head, 0.34 texture { SC_Tan } }
    box { sk_Head+<-0.3,-0.06,-0.42>, sk_Head+<0.3,0.12,-0.30> texture { SC_Dark } }
    // big pauldrons
    sphere { sk_ShL, 0.30 texture { SC_Steel } }  sphere { sk_ShR, 0.30 texture { SC_Steel } }
    // gauss rifle along the right forearm, both hands forward
    #local dir = vnormalize(sk_HaR - sk_ElR);  #local H = sk_HaR;
    box { H+dir*0.05+<-0.08,-0.08,-0.08>, H+dir*0.7+<0.08,0.10,0.08> texture { SC_Dark } }
    cylinder { H+dir*0.6, H+dir*1.25, 0.05 texture { SC_Steel } }   // barrel
    box { H+dir*0.2+<-0.06,-0.28,-0.05>, H+dir*0.35+<0.06,-0.08,0.05> texture { SC_Dark } } // magazine
    rotate y*faceDeg translate Pos
  }
#end

// ---- ZERGLING: low fast carapace bug with scythe claws ----
#macro Zergling(Pos, faceDeg, skitter)
  #local s = skitter*2*pi;
  union {
    blob { threshold 0.6
      sphere { <0,0.55,0.3>, 0.42, 1.1 } sphere { <0,0.6,-0.3>, 0.38, 1.0 }   // body
      cylinder { <0,0.6,-0.5>, <0,0.85,-0.95>, 0.18, 0.9 } sphere { <0,0.92,-1.05>, 0.26, 1.0 } // neck+head
      cylinder { <-0.3,0.5,0.2>, <-0.45,0.05,0.45>, 0.12, 0.85 } cylinder { <0.3,0.5,0.2>, <0.45,0.05,0.45>, 0.12, 0.85 } // hind legs
      cylinder { <-0.28,0.55,-0.3>, <-0.5,0.1,-0.6>, 0.10, 0.85 } cylinder { <0.28,0.55,-0.3>, <0.5,0.1,-0.6>, 0.10, 0.85 } // fore legs
      texture { SC_Zerg } }
    // scythe claws (curved bone) forward
    cone { <-0.32,0.6,-0.7>, 0.07, <-0.55,1.0,-1.4>, 0.0 texture { SC_Bone } }
    cone { < 0.32,0.6,-0.7>, 0.07, < 0.55,1.0,-1.4>, 0.0 texture { SC_Bone } }
    // back spikes
    cone { <0,0.95,0.1>, 0.07, <0,1.5,0.4>, 0.0 texture { SC_Bone } }
    cone { <-0.18,0.85,0.2>, 0.05, <-0.3,1.25,0.5>, 0.0 texture { SC_Bone } }
    cone { < 0.18,0.85,0.2>, 0.05, < 0.3,1.25,0.5>, 0.0 texture { SC_Bone } }
    // eyes
    sphere { <-0.1,0.95,-1.25>, 0.05 texture { SC_EOrange } } sphere { <0.1,0.95,-1.25>, 0.05 texture { SC_EOrange } }
    translate <0, abs(sin(s))*0.08, 0>
    rotate y*faceDeg translate Pos
  }
#end

// ---- PYLON: floating Protoss-style power crystal with an energy field ----
#macro Pylon(Pos, pulse)
  union {
    box { <-0.5,0,-0.5>, <0.5,0.4,0.5> texture { SC_Steel } }   // base
    // floating crystal (bipyramid)
    merge {
      cone { <0,0,0>, 0.5, <0,1.5,0>, 0.0 } cone { <0,0,0>, 0.5, <0,-0.8,0>, 0.0 }
      texture { pigment { rgbf <0.3,0.6,1.0,0.55> } finish { ambient 1.0 phong 1 reflection { 0.15 } } }
      rotate y*(pulse*120) translate <0,2.0,0>
    }
    // glowing core + energy field
    sphere { <0,2.0,0>, 0.3 texture { SC_EBlue } }
    sphere { <0,1.6,0>, 1.3 texture { pigment { rgbf <0.3,0.6,1.0, 0.92 - 0.05*sin(pulse*2*pi)> } finish { ambient 0.8 } } }
    translate Pos
  }
#end

// ---- SIEGE TANK: tracked Terran tank with a big cannon ----
#macro SiegeTank(Pos, faceDeg)
  union {
    box { <-0.9,0.2,-1.3>, <0.9,0.7,1.3> texture { SC_Tan } }       // hull
    box { <-1.05,0,-1.4>, <-0.7,0.5,1.4> texture { SC_Dark } }      // left track
    box { < 0.7,0,-1.4>, < 1.05,0.5,1.4> texture { SC_Dark } }      // right track
    superellipsoid { <0.4,0.4> scale <0.7,0.4,0.7> translate <0,0.95,0.1> texture { SC_Steel } } // turret
    cylinder { <0,1.0,-0.3>, <0,1.0,-2.6>, 0.13 texture { SC_Steel } }  // cannon barrel
    box { <-0.12,0.9,-2.6>, <0.12,1.1,-2.3> texture { SC_Dark } }       // muzzle brake
    rotate y*faceDeg translate Pos
  }
#end

// ---- BATTLECRUISER: Behemoth-class Terran capital ship ----
// Bow (-z): big rounded command bridge + Yamato nose dish. Stern (+z): 3 engine
// nozzles. Long chunky industrial hull, swept side sponsons. (Pos, faceDeg)
#macro Battlecruiser(Pos, faceDeg)
  union {
    // --- main hull: fat amidships, tapering toward the bow ---
    superellipsoid { <0.3,0.22> scale <1.5,1.05,2.5> translate <0,0,0.7> texture { SC_Steel } }   // aft main body
    superellipsoid { <0.3,0.30> scale <1.05,0.8,1.9> translate <0,0,-1.9> texture { SC_Steel } }  // forward hull (tapered)
    box { <-0.85,-1.0,-2.0>, <0.85,-0.15,2.6> texture { SC_Dark } }                                // ventral keel
    box { <-0.3,1.0,-0.4>, <0.3,1.35,1.6> texture { SC_Dark } }                                    // dorsal spine
    // --- signature command bridge: big rounded "head" sitting high & forward ---
    superellipsoid { <0.6,0.6> scale <1.05,1.05,1.35> translate <0,1.55,-1.7> texture { SC_Steel } }
    box { <-0.6,0.3,-2.2>, <0.6,1.45,-0.7> texture { SC_Dark } }                                   // bridge neck/shoulders
    sphere { <0,1.7,-2.55>, 0.5 texture { SC_EBlue } }                                             // forward viewport glow
    box { <-0.65,1.55,-2.4>, <0.65,1.95,-1.9> texture { SC_EBlue } }                               // bridge window band
    // --- Yamato nose emitter: wide dish at the very bow ---
    cone { <0,0.35,-3.45>, 0.72, <0,0.35,-3.95>, 0.46 texture { SC_Steel } }                       // emitter housing
    disc { <0,0.35,-3.97>, z, 0.42 texture { SC_EOrange } }                                        // emitter face glow
    // --- swept side sponsons / fins (mid-hull) ---
    prism { linear_sweep linear_spline -0.2,0.2, 5, <-1.0,-0.4>,<-2.3,0.6>,<-2.3,1.6>,<-1.0,1.2>,<-1.0,-0.4> texture { SC_Steel } } // port wing
    prism { linear_sweep linear_spline -0.2,0.2, 5, < 1.0,-0.4>,< 2.3,0.6>,< 2.3,1.6>,< 1.0,1.2>,< 1.0,-0.4> texture { SC_Steel } } // stbd wing
    // --- stern engine block + 3 thruster nozzles ---
    box { <-1.15,-0.35,2.4>, <1.15,0.95,3.15> texture { SC_Dark } }
    cylinder { <-0.62,0.3,3.1>, <-0.62,0.3,3.65>, 0.32 texture { SC_EBlue } }
    cylinder { < 0.0,0.35,3.1>, < 0.0,0.35,3.75>, 0.38 texture { SC_EBlue } }
    cylinder { < 0.62,0.3,3.1>, < 0.62,0.3,3.65>, 0.32 texture { SC_EBlue } }
    rotate y*faceDeg translate Pos
  }
#end
