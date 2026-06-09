// warcraft_rigged.inc — Orc and Footman rebuilt on the FK skeleton (skeleton.inc).
// The body is the skeleton's metaball skin; gear (axe/tusks, helmet/sword/shield)
// is attached at the computed joints, so they POSE and ANIMATE with the rig.
// Same angle params as SkeletonHumanoid (minus skinColor).
#include "skeleton.inc"

#declare RG_Steel = Tex_BrushedMetal(rgb <0.60,0.64,0.72>)
#declare RG_Wood  = Tex_Worn(rgb <0.36,0.22,0.10>, rgb <0.24,0.14,0.07>)
#declare RG_Blue  = Tex_Plastic(rgb <0.14,0.30,0.72>)
#declare RG_Red   = Tex_Plastic(rgb <0.72,0.12,0.12>)
#declare RG_Gold  = Tex_BrushedMetal(rgb <0.85,0.70,0.20>)

// ---- ORC: green bulky skeleton + tusks, glowing eyes, shoulder pads, axe ----
#macro SkeletonOrc(Pos, faceDeg, lean, headTilt, armLp, armLr, elbL,
        armRp, armRr, elbR, hipLp, kneeL, hipRp, kneeR)
  SK_Joints(lean,headTilt, armLp,armLr,elbL, armRp,armRr,elbR, hipLp,kneeL,hipRp,kneeR)
  union {
    SK_BodyBlob(rgb <0.32,0.52,0.22>, 1.28)
    // glowing eyes + brow
    #local E = SK_HeadFront(-0.30);
    sphere { E+<-0.13,0.02,0>, 0.07 texture { pigment{rgb<1,0.7,0.1>} finish{ambient 1.4} } }
    sphere { E+< 0.13,0.02,0>, 0.07 texture { pigment{rgb<1,0.7,0.1>} finish{ambient 1.4} } }
    // tusks (up from the jaw)
    cone { sk_Head+<-0.13,-0.16,-0.30>, 0.055, sk_Head+<-0.15,0.08,-0.34>, 0.0 texture { pigment{rgb 0.95} } }
    cone { sk_Head+< 0.13,-0.16,-0.30>, 0.055, sk_Head+< 0.15,0.08,-0.34>, 0.0 texture { pigment{rgb 0.95} } }
    // shoulder pads
    sphere { sk_ShL, 0.30 texture { RG_Wood } }  sphere { sk_ShR, 0.30 texture { RG_Wood } }
    // battle-axe held in the right hand
    #local H = sk_HaR;
    cylinder { H+<0,-0.35,0>, H+<0,1.55,0>, 0.06 texture { RG_Wood } }
    box { H+<-0.42,1.10,-0.18>, H+<0.42,1.62,0.18> texture { RG_Steel } }
    cone { H+<-0.42,1.36,0>, 0.28, H+<-0.72,1.36,0>, 0.0 texture { RG_Steel } }
    cone { H+< 0.42,1.36,0>, 0.28, H+< 0.72,1.36,0>, 0.0 texture { RG_Steel } }
    rotate y*faceDeg translate Pos
  }
#end

// ---- FOOTMAN: steel skeleton + helmet, blue tabard, sword, round shield ----
#macro SkeletonFootman(Pos, faceDeg, lean, headTilt, armLp, armLr, elbL,
        armRp, armRr, elbR, hipLp, kneeL, hipRp, kneeR)
  SK_Joints(lean,headTilt, armLp,armLr,elbL, armRp,armRr,elbR, hipLp,kneeL,hipRp,kneeR)
  union {
    SK_BodyBlob(rgb <0.58,0.62,0.70>, 1.0)
    // helmet (dome with a visor slit) + red plume + skin face
    sphere { sk_Head, 0.30 Tex_Skin(rgb <0.90,0.72,0.55>) }
    difference {
      sphere { sk_Head+<0,0.04,0>, 0.36 }
      box { sk_Head+<-0.5,-0.10,-0.5>, sk_Head+<0.5,0.02,-0.18> }
      texture { RG_Steel }
    }
    cone { sk_Head+<0,0.38,0>, 0.06, sk_Head+<0,0.60,0>, 0.0 texture { RG_Red } }
    // blue tabard down the torso front
    #local TC = (sk_Pelvis + sk_Chest)/2;
    box { TC+<-0.28,-0.5,-0.40>, TC+<0.28,0.5,-0.32> texture { RG_Blue } }
    // pauldrons
    sphere { sk_ShL, 0.21 texture { RG_Steel } }  sphere { sk_ShR, 0.21 texture { RG_Steel } }
    // sword in the right hand
    #local H = sk_HaR;
    cylinder { H+<0,-0.18,0>, H+<0,0.10,0>, 0.05 texture { RG_Wood } }
    box { H+<-0.17,0.08,-0.08>, H+<0.17,0.20,0.08> texture { RG_Gold } }
    box { H+<-0.06,0.20,-0.04>, H+<0.06,1.30,0.04> texture { RG_Steel } }
    cone { H+<0,1.30,0>, 0.08, H+<0,1.46,0>, 0.0 texture { RG_Steel } }
    // round shield on the left hand (faces forward, -z)
    #local S = sk_HaL;
    cylinder { S+<0,0,-0.10>, S+<0,0,-0.03>, 0.42 texture { RG_Steel } }
    cylinder { S+<0,0,-0.12>, S+<0,0,-0.07>, 0.12 texture { RG_Gold } }
    rotate y*faceDeg translate Pos
  }
#end

#declare RG_Leather = Tex_Worn(rgb <0.50,0.36,0.20>, rgb <0.36,0.24,0.12>)
#declare RG_Green   = Tex_Worn(rgb <0.18,0.42,0.18>, rgb <0.12,0.30,0.12>)

// ---- ARCHER: rigged bowman. draw (0..1) pulls the string; flight>0 looses ----
#macro SkeletonArcher(Pos, faceDeg, draw, flight)
  // archery stance: left arm out (bow), right arm bent (draw), feet apart
  SK_Joints(6, 0,  -78,6,14,  -34,12,82,  14,-8, -14,-8)
  union {
    SK_BodyBlob(rgb <0.30,0.50,0.26>, 1.0)
    SK_Eyes()
    // little green hood
    difference { sphere { sk_Head+<0,0.04,0.04>, 0.37 } box { sk_Head+<-0.5,-0.1,-0.55>, sk_Head+<0.5,0.5,0.0> } texture { RG_Green } }
    // bow on the left hand (curved limbs + grip)
    #local BH = sk_HaL;
    #local BowTop = BH + <0, 0.92, 0.16>;  #local BowBot = BH + <0,-0.92, 0.16>;
    #local BowMid1 = BH + <0, 0.5, 0.02>;  #local BowMid2 = BH + <0,-0.5, 0.02>;
    cylinder { BH, BowMid1, 0.05 texture { RG_Leather } } cylinder { BowMid1, BowTop, 0.04 texture { RG_Leather } }
    cylinder { BH, BowMid2, 0.05 texture { RG_Leather } } cylinder { BowMid2, BowBot, 0.04 texture { RG_Leather } }
    // bowstring pulled back to the nock by `draw`
    #local Nock = BH + <0, 0, 0.16 + draw*0.62>;
    cylinder { BowTop, Nock, 0.012 texture { pigment{rgb 0.92} } }
    cylinder { Nock, BowBot, 0.012 texture { pigment{rgb 0.92} } }
    // arrow: nocked at the string, or flying forward when loosed
    #if (flight <= 0)
      #local AB = Nock;  #local AT = Nock + <0,0,-1.15>;
      cylinder { AB, AT, 0.028 texture { RG_Wood } } cone { AT, 0.06, AT+<0,0,-0.13>, 0.0 texture { RG_Steel } }
      box { AB+<-0.10,-0.10,0.02>, AB+<0.10,0.10,0.06> texture { RG_Red } }   // fletching
    #else
      #local AB = BH + <0,0.05,-0.25 - flight>;  #local AT = AB + <0,0,-1.0>;
      cylinder { AB, AT, 0.028 texture { RG_Wood } } cone { AT, 0.06, AT+<0,0,-0.13>, 0.0 texture { RG_Steel } }
      box { AB+<-0.10,-0.10,0>, AB+<0.10,0.10,0.04> texture { RG_Red } }
    #end
    rotate y*faceDeg translate Pos
  }
#end

#declare RG_Horse = Tex_Worn(rgb <0.46,0.30,0.17>, rgb <0.32,0.20,0.10>)
#declare RG_HrDk  = Tex_Worn(rgb <0.22,0.14,0.08>, rgb <0.14,0.09,0.05>)

// ---- HORSE: blob quadruped (faces -z). gallop (0..1) animates the legs ----
#macro Horse(Pos, faceDeg, gallop)
  #local g = gallop*2*pi;
  #local fL = sin(g)*22;  #local fR = sin(g+pi)*22;   // front legs swing
  #local bL = sin(g+pi)*22; #local bR = sin(g)*22;    // back legs (diagonal)
  union {
    blob {
      threshold 0.6
      sphere { <0,1.55,0>, 0.56, 1.1 } sphere { <0,1.55,-0.7>, 0.5, 1.0 } sphere { <0,1.55,0.72>, 0.5, 1.0 }
      cylinder { <0,1.65,-1.05>, <0,2.45,-1.65>, 0.28, 0.9 } sphere { <0,2.55,-1.82>, 0.30, 1.0 }
      cylinder { <0,2.5,-1.9>, <0,2.35,-2.28>, 0.15, 0.8 }
      cylinder { <-0.34,1.45,-0.85> + vrotate(<0,0,0>,<0,0,0>), <-0.40,0.12,-0.85> + <fL*0.01,0,0>, 0.15, 0.85 }
      cylinder { < 0.34,1.45,-0.85>, < 0.40,0.12,-0.85> + <fR*0.01,0,0>, 0.15, 0.85 }
      cylinder { <-0.34,1.45,0.85>, <-0.40,0.12,0.85> + <bL*0.01,0,0>, 0.15, 0.85 }
      cylinder { < 0.34,1.45,0.85>, < 0.40,0.12,0.85> + <bR*0.01,0,0>, 0.15, 0.85 }
      texture { RG_Horse }
    }
    cone { <0,1.7,1.05>, 0.13, <0,0.9,1.7>, 0.0 texture { RG_HrDk } }       // tail
    cylinder { <0,2.5,-1.45>, <0,2.05,-0.9>, 0.10 texture { RG_HrDk } }     // mane
    superellipsoid { <0.3,0.3> scale <0.42,0.14,0.5> translate <0,1.92,0.05> texture { RG_Leather } } // saddle
    sphere { <-0.13,2.6,-2.02>, 0.05 texture { pigment{rgb 0.05} } } sphere { <0.13,2.6,-2.02>, 0.05 texture { pigment{rgb 0.05} } }
    cone { <-0.1,2.78,-1.78>, 0.05, <-0.12,2.95,-1.78>, 0.0 texture { RG_Horse } } // ears
    cone { < 0.1,2.78,-1.78>, 0.05, < 0.12,2.95,-1.78>, 0.0 texture { RG_Horse } }
    rotate y*faceDeg translate Pos
  }
#end
