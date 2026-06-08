// warcraft.inc — generic Warcraft-1-era fantasy-RTS generators (chunky early-90s
// CGI). Macros: OrcGrunt, Footman, Keep. No trademarks. Uses blob + Tier-1 textures.
#include "retro90s_textures.inc"

#declare WC_Steel  = Tex_BrushedMetal(rgb <0.60,0.64,0.72>)
#declare WC_Stone  = Tex_Worn(rgb <0.56,0.56,0.52>, rgb <0.40,0.40,0.36>)
#declare WC_Blue   = Tex_Plastic(rgb <0.14,0.30,0.72>)
#declare WC_Red    = Tex_Plastic(rgb <0.72,0.12,0.12>)
#declare WC_Wood   = Tex_Worn(rgb <0.36,0.22,0.10>, rgb <0.24,0.14,0.07>)
#declare WC_Skin   = Tex_Skin(rgb <0.90,0.72,0.55>)
#declare WC_OrcGrn = Tex_Worn(rgb <0.32,0.52,0.22>, rgb <0.22,0.40,0.15>)
#declare WC_Gold   = Tex_BrushedMetal(rgb <0.85,0.7,0.2>)

// ---- ORC GRUNT: hulking green blob brute with a battle-axe ----
#macro OrcGrunt(cx)
  union {
    blob {
      threshold 0.6
      sphere { <0,2.05,0.05>, 0.98, 1.25 }
      sphere { <0,1.45,0>, 0.82, 1.0 }
      sphere { <-0.9,2.15,0>, 0.52, 1.0 } sphere { <0.9,2.15,0>, 0.52, 1.0 }
      cylinder { <-0.9,2.0,0>, <-1.18,0.85,0.2>, 0.33, 0.9 }
      cylinder { <0.9,2.0,0>, <1.05,1.05,0.3>, 0.35, 0.9 }
      sphere { <-1.22,0.72,0.24>, 0.37, 1.0 } sphere { <1.08,0.95,0.34>, 0.38, 1.0 }
      cylinder { <-0.42,1.0,0>, <-0.48,0.12,0>, 0.36, 0.9 }
      cylinder { <0.42,1.0,0>, <0.48,0.12,0>, 0.36, 0.9 }
      texture { WC_OrcGrn }
    }
    superellipsoid { <0.4,0.3> scale <0.7,0.34,0.5> translate <0,1.05,0> texture { WC_Wood } }
    sphere { <-0.95,2.45,0>, 0.42 texture { WC_Wood } } sphere { <0.95,2.45,0>, 0.40 texture { WC_Wood } }
    sphere { <0,2.55,-0.1>, 0.5 texture { WC_OrcGrn } }
    sphere { <-0.17,2.55,-0.46>, 0.07 texture { pigment{rgb<1,0.7,0.1>} finish{ambient 1.4} } }
    sphere { <0.17,2.55,-0.46>, 0.07 texture { pigment{rgb<1,0.7,0.1>} finish{ambient 1.4} } }
    cone { <-0.16,2.34,-0.46>, 0.06, <-0.18,2.62,-0.5>, 0.0 texture { pigment{rgb 0.95} } }
    cone { <0.16,2.34,-0.46>, 0.06, <0.18,2.62,-0.5>, 0.0 texture { pigment{rgb 0.95} } }
    cylinder { <1.45,0.2,0.34>, <1.45,3.0,0.34>, 0.08 texture { WC_Wood } }
    box { <1.05,2.45,0.18>, <1.85,3.05,0.5> texture { WC_Steel } }
    cone { <1.05,2.75,0.34>, 0.30, <0.78,2.75,0.34>, 0.0 texture { WC_Steel } }
    cone { <1.85,2.75,0.34>, 0.30, <2.12,2.75,0.34>, 0.0 texture { WC_Steel } }
    translate <cx,0,0>
  }
#end

// ---- FOOTMAN: armored human knight with sword + round shield ----
#macro Footman(cx)
  union {
    cylinder { <-0.22,0,0>, <-0.20,0.85,0>, 0.20 texture { WC_Steel } }  // legs
    cylinder { < 0.22,0,0>, < 0.20,0.85,0>, 0.20 texture { WC_Steel } }
    superellipsoid { <0.4,0.3> scale <0.48,0.6,0.34> translate <0,1.45,0> texture { WC_Steel } } // armored torso
    box { <-0.30,1.05,-0.36>, <0.30,1.95,-0.30> texture { WC_Blue } }    // blue tabard
    sphere { <-0.52,1.75,0>, 0.18 texture { WC_Steel } } sphere { <0.52,1.75,0>, 0.18 texture { WC_Steel } } // pauldrons
    // head: helmet dome + dark visor slit + skin
    sphere { <0,2.25,0>, 0.30 texture { WC_Skin } }
    difference { sphere { <0,2.30,0>, 0.34 } box { <-0.4,2.18,-0.5>,<0.4,2.30,-0.20> } texture { WC_Steel } } // helmet
    cone { <0,2.62,0>, 0.06, <0,2.85,0>, 0.0 texture { WC_Red } }        // helm plume
    // left arm + round shield
    cylinder { <-0.5,1.8,0>, <-0.72,1.1,0.1>, 0.14 texture { WC_Steel } }
    cylinder { <-0.78,1.15,-0.45>, <-0.78,1.15,-0.30>, 0.45 texture { WC_Steel } } // shield disc
    cylinder { <-0.78,1.15,-0.47>, <-0.78,1.15,-0.44>, 0.12 texture { WC_Gold } }   // shield boss
    // right arm raised + sword
    cylinder { <0.5,1.8,0>, <0.85,2.4,0.1>, 0.14 texture { WC_Steel } }
    cylinder { <0.85,2.3,0.1>, <0.85,2.5,0.1>, 0.05 texture { WC_Wood } }           // grip
    box { <0.70,2.5,0.0>, <1.0,2.62,0.2> texture { WC_Gold } }                       // crossguard
    box { <0.80,2.6,0.04>, <0.90,3.5,0.16> texture { WC_Steel } }                    // blade
    cone { <0.85,3.5,0.1>, 0.08, <0.85,3.65,0.1>, 0.0 texture { WC_Steel } }         // blade tip
    translate <cx,0,0>
  }
#end

// ---- KEEP: a chunky stone tower with crenellations + banner ----
#macro Keep(cx, cz)
  union {
    box { <-1.6,0,-1.6>, <1.6,3.0,1.6> texture { WC_Stone } }       // base
    box { <-1.1,3.0,-1.1>, <1.1,5.5,1.1> texture { WC_Stone } }     // tower
    // crenellations around the tower top
    #local k = -1.1;
    #while (k < 1.1)
      box { <k,5.5,-1.15>, <k+0.3,5.9,-0.85> texture { WC_Stone } }
      box { <k,5.5,0.85>, <k+0.3,5.9,1.15> texture { WC_Stone } }
      box { <-1.15,5.5,k>, <-0.85,5.9,k+0.3> texture { WC_Stone } }
      box { <0.85,5.5,k>, <1.15,5.9,k+0.3> texture { WC_Stone } }
      #local k = k + 0.55;
    #end
    box { <-0.45,0,-1.65>, <0.45,1.4,-1.55> texture { WC_Wood } }   // door
    // banner pole + red flag on the tower
    cylinder { <0,5.9,0>, <0,7.2,0>, 0.06 texture { WC_Wood } }
    box { <0,6.4,-0.02>, <1.1,7.1,0.02> texture { WC_Red } }
    translate <cx,0,cz>
  }
#end

#declare WC_Cream = texture { pigment { rgb <0.85,0.78,0.60> } finish { ambient 0.3 diffuse 0.6 } }
#declare WC_DragonRed  = Tex_Worn(rgb <0.70,0.12,0.10>, rgb <0.50,0.08,0.06>)
#declare WC_DragonWing = Tex_Worn(rgb <0.55,0.10,0.08>, rgb <0.40,0.06,0.05>)

// ---- FARM: cream hut with a thatch cone roof ----
#macro Farm(cx, cz)
  union {
    box { <-1,0,-0.8>, <1,1.1,0.8> texture { WC_Cream } }
    cone { <0,1.0,0>, 1.5, <0,2.2,0>, 0.0 texture { WC_Wood } }
    box { <-0.3,0,-0.85>, <0.3,0.72,-0.78> texture { WC_Wood } }
    translate <cx,0,cz>
  }
#end

// ---- BARRACKS: bigger building, red roof + banner ----
#macro Barracks(cx, cz)
  union {
    box { <-1.8,0,-1.2>, <1.8,1.8,1.2> texture { WC_Wood } }
    box { <-2.0,1.8,-1.4>, <2.0,2.0,1.4> texture { WC_Stone } }
    cone { <0,1.9,0>, 2.5, <0,3.5,0>, 0.0 texture { WC_Red } }
    box { <-0.5,0,-1.25>, <0.5,1.25,-1.15> texture { WC_Stone } }
    cylinder { <-1.6,2.0,-1.25>, <-1.6,3.3,-1.25>, 0.05 texture { WC_Wood } }
    box { <-1.6,2.5,-1.27>, <-0.85,3.15,-1.23> texture { WC_Red } }
    translate <cx,0,cz>
  }
#end

// ---- CATAPULT: wheeled siege engine with a throwing arm + boulder ----
#macro Catapult(cx)
  union {
    box { <-0.6,0.35,-0.45>, <0.6,0.6,0.45> texture { WC_Wood } }
    cylinder { <-0.65,0.35,-0.5>, <-0.65,0.35,-0.4>, 0.32 texture { WC_Wood } }
    cylinder { < 0.65,0.35,-0.5>, < 0.65,0.35,-0.4>, 0.32 texture { WC_Wood } }
    cylinder { <-0.65,0.35,0.4>, <-0.65,0.35,0.5>, 0.32 texture { WC_Wood } }
    cylinder { < 0.65,0.35,0.4>, < 0.65,0.35,0.5>, 0.32 texture { WC_Wood } }
    cylinder { <-0.3,0.6,0>, <0,1.5,0.1>, 0.07 texture { WC_Wood } }
    cylinder { < 0.3,0.6,0>, <0,1.5,0.1>, 0.07 texture { WC_Wood } }
    cylinder { <0.5,0.6,0.3>, <-0.3,1.75,-0.6>, 0.08 texture { WC_Wood } }
    sphere { <-0.3,1.75,-0.6>, 0.22 texture { WC_Stone } }
    translate <cx,0,0>
  }
#end

// ---- PEON: small green orc worker with a pickaxe ----
#macro Peon(cx)
  union {
    blob {
      threshold 0.6
      sphere { <0,1.0,0>, 0.5, 1.1 } sphere { <0,0.6,0>, 0.42, 1.0 }
      cylinder { <-0.35,1.0,0>, <-0.5,0.5,0.1>, 0.16, 0.9 }
      cylinder { < 0.35,1.0,0>, < 0.5,0.5,0.1>, 0.16, 0.9 }
      cylinder { <-0.2,0.55,0>, <-0.22,0.08,0>, 0.18, 0.9 }
      cylinder { < 0.2,0.55,0>, < 0.22,0.08,0>, 0.18, 0.9 }
      texture { WC_OrcGrn }
    }
    sphere { <0,1.45,-0.05>, 0.32 texture { WC_OrcGrn } }
    sphere { <-0.1,1.45,-0.32>, 0.05 texture { pigment{rgb<1,0.8,0.2>} finish{ambient 1.3} } }
    sphere { < 0.1,1.45,-0.32>, 0.05 texture { pigment{rgb<1,0.8,0.2>} finish{ambient 1.3} } }
    cylinder { <0.5,0.2,0.1>, <0.5,1.7,0.1>, 0.05 texture { WC_Wood } }
    box { <0.34,1.58,0.0>, <0.78,1.70,0.2> texture { WC_Steel } }
    translate <cx,0,0>
  }
#end

// ---- DRAGON: red winged dragon (place flying: cx,cy,cz) ----
#macro Dragon(cx, cy, cz)
  union {
    blob {
      threshold 0.6
      sphere { <0,0,0>, 0.7, 1.1 }
      sphere { <0,0.15,-1.0>, 0.55, 1.0 }
      cylinder { <0,0.15,-1.3>, <0.1,0.9,-2.3>, 0.28, 0.9 }
      sphere { <0.15,1.05,-2.6>, 0.4, 1.0 }
      cylinder { <0,0,0.9>, <0.1,0.4,2.6>, 0.16, 0.85 }
      sphere { <0.1,0.5,2.85>, 0.18, 1.0 }
      cylinder { <-0.45,-0.3,-0.4>, <-0.7,-1.1,-0.4>, 0.16, 0.85 }
      cylinder { < 0.45,-0.3,-0.4>, < 0.7,-1.1,-0.4>, 0.16, 0.85 }
      texture { WC_DragonRed }
    }
    superellipsoid { <0.2,0.8> scale <1.6,0.04,1.0> rotate z*32 rotate x*-12 translate <-1.4,0.95,-0.3> texture { WC_DragonWing } }
    superellipsoid { <0.2,0.8> scale <1.6,0.04,1.0> rotate z*-32 rotate x*-12 translate < 1.4,0.95,-0.3> texture { WC_DragonWing } }
    cone { <0.0,1.4,-2.6>, 0.06, <-0.1,1.75,-2.5>, 0.0 texture { pigment{rgb 0.9} } }
    cone { <0.3,1.4,-2.6>, 0.06, <0.4,1.75,-2.5>, 0.0 texture { pigment{rgb 0.9} } }
    sphere { <0.0,1.1,-2.95>, 0.06 texture { pigment{rgb<1,0.8,0.1>} finish{ambient 1.6} } }
    sphere { <0.3,1.1,-2.95>, 0.06 texture { pigment{rgb<1,0.8,0.1>} finish{ambient 1.6} } }
    translate <cx,cy,cz>
  }
#end
