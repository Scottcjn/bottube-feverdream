// skeleton.inc — a posable humanoid SKELETON that drives a metaball skin.
// Forward kinematics (via vrotate) computes joint positions from joint angles;
// the joints are exposed as globals (sk_*) so callers can both skin the body and
// attach gear (weapons, helmets) at the right joints. Pose/animate by changing
// the angles. The old-school way to rig + pose a character.
#include "retro90s_textures.inc"

#declare SK_torso = 0.95;  #declare SK_neck = 0.22; #declare SK_head = 0.42;
#declare SK_uarm  = 0.58;  #declare SK_farm = 0.52;
#declare SK_thigh = 0.60;  #declare SK_shin = 0.58;
#declare SK_shdrW = 0.50;  #declare SK_hipW = 0.26; #declare SK_hipH = 1.15;

// Compute joint positions into globals (LOCAL space, pre figure-rotation):
//   sk_Pelvis sk_Chest sk_Neck sk_Head  sk_ShL sk_ElL sk_HaL  sk_ShR sk_ElR sk_HaR
//   sk_HiL sk_KnL sk_FtL  sk_HiR sk_KnR sk_FtR   (+ sk_lean sk_headTilt for gear)
#macro SK_Joints(lean, headTilt, armLp, armLr, elbL, armRp, armRr, elbR,
                 hipLp, kneeL, hipRp, kneeR)
  #declare sk_Pelvis = <0, SK_hipH, 0>;
  #declare sk_Chest  = sk_Pelvis + vrotate(<0,SK_torso,0>, <lean,0,0>);
  #declare sk_Neck   = sk_Chest  + vrotate(<0,SK_neck,0>,  <lean,0,0>);
  #declare sk_Head   = sk_Neck   + vrotate(<0,SK_head,0>,  <lean+headTilt,0,0>);
  #declare sk_ShL = sk_Chest + <-SK_shdrW,-0.05,0>;  #declare sk_ShR = sk_Chest + <SK_shdrW,-0.05,0>;
  #declare sk_ElL = sk_ShL + vrotate(<0,-SK_uarm,0>, <armLp,0, armLr>);
  #declare sk_ElR = sk_ShR + vrotate(<0,-SK_uarm,0>, <armRp,0,-armRr>);
  #declare sk_HaL = sk_ElL + vrotate(<0,-SK_farm,0>, <armLp+elbL,0, armLr>);
  #declare sk_HaR = sk_ElR + vrotate(<0,-SK_farm,0>, <armRp+elbR,0,-armRr>);
  #declare sk_HiL = sk_Pelvis + <-SK_hipW,0,0>;  #declare sk_HiR = sk_Pelvis + <SK_hipW,0,0>;
  #declare sk_KnL = sk_HiL + vrotate(<0,-SK_thigh,0>, <hipLp,0,0>);
  #declare sk_KnR = sk_HiR + vrotate(<0,-SK_thigh,0>, <hipRp,0,0>);
  #declare sk_FtL = sk_KnL + vrotate(<0,-SK_shin,0>, <hipLp+kneeL,0,0>);
  #declare sk_FtR = sk_KnR + vrotate(<0,-SK_shin,0>, <hipRp+kneeR,0,0>);
  #declare sk_lean = lean;  #declare sk_headTilt = headTilt;
#end

// Build the blob skin from the sk_* joints. `bulk` scales limb girth (1=normal).
#macro SK_BodyBlob(skinColor, bulk)
  blob {
    threshold 0.6
    sphere { sk_Pelvis, 0.40*bulk, 1.05 } sphere { sk_Chest, 0.46*bulk, 1.15 }
    cylinder { sk_Pelvis, sk_Chest, 0.33*bulk, 0.9 }
    cylinder { sk_Neck, sk_Head, 0.18, 0.8 } sphere { sk_Head, 0.34, 1.1 }
    sphere { sk_ShL,0.22*bulk,0.9 } cylinder { sk_ShL,sk_ElL,0.15*bulk,0.85 } sphere { sk_ElL,0.16*bulk,0.9 } cylinder { sk_ElL,sk_HaL,0.13*bulk,0.85 } sphere { sk_HaL,0.18*bulk,1.0 }
    sphere { sk_ShR,0.22*bulk,0.9 } cylinder { sk_ShR,sk_ElR,0.15*bulk,0.85 } sphere { sk_ElR,0.16*bulk,0.9 } cylinder { sk_ElR,sk_HaR,0.13*bulk,0.85 } sphere { sk_HaR,0.18*bulk,1.0 }
    sphere { sk_HiL,0.24*bulk,0.9 } cylinder { sk_HiL,sk_KnL,0.19*bulk,0.85 } sphere { sk_KnL,0.18*bulk,0.9 } cylinder { sk_KnL,sk_FtL,0.16*bulk,0.85 } sphere { sk_FtL,0.20*bulk,1.0 }
    sphere { sk_HiR,0.24*bulk,0.9 } cylinder { sk_HiR,sk_KnR,0.19*bulk,0.85 } sphere { sk_KnR,0.18*bulk,0.9 } cylinder { sk_KnR,sk_FtR,0.16*bulk,0.85 } sphere { sk_FtR,0.20*bulk,1.0 }
    Tex_Skin(skinColor)
  }
#end

// head-front point (for eyes/face gear), respecting head tilt
#macro SK_HeadFront(dz)
  (sk_Head + vrotate(<0,0.05,dz>, <sk_lean+sk_headTilt,0,0>))
#end

#macro SK_Eyes()
  #local E = SK_HeadFront(-0.27);
  sphere { E + <-0.13,0,0>, 0.09 texture { pigment{rgb 1} finish{phong 0.6 ambient 0.45} } }
  sphere { E + < 0.13,0,0>, 0.09 texture { pigment{rgb 1} finish{phong 0.6 ambient 0.45} } }
  sphere { E + <-0.13,0,-0.06>, 0.045 texture { pigment{rgb 0.04} } }
  sphere { E + < 0.13,0,-0.06>, 0.045 texture { pigment{rgb 0.04} } }
#end

#macro SkeletonHumanoid(Pos, faceDeg, lean, headTilt, armLp, armLr, elbL,
        armRp, armRr, elbR, hipLp, kneeL, hipRp, kneeR, skinColor)
  SK_Joints(lean,headTilt, armLp,armLr,elbL, armRp,armRr,elbR, hipLp,kneeL,hipRp,kneeR)
  union {
    SK_BodyBlob(skinColor, 1.0)
    SK_Eyes()
    rotate y*faceDeg translate Pos
  }
#end
