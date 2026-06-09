// skeleton.inc — a posable humanoid SKELETON that drives a metaball skin.
// Forward kinematics (via POV's vrotate) computes joint positions from a set of
// joint angles; the joints are then blob-skinned into one smooth body. Pose or
// animate by changing the angles. The old-school way to rig + pose a character.
#include "retro90s_textures.inc"

// bone lengths
#declare SK_torso = 0.95;  #declare SK_neck = 0.22; #declare SK_head = 0.42;
#declare SK_uarm  = 0.58;  #declare SK_farm = 0.52;
#declare SK_thigh = 0.60;  #declare SK_shin = 0.58;
#declare SK_shdrW = 0.50;  #declare SK_hipW = 0.26; #declare SK_hipH = 1.15;

// SkeletonHumanoid(<pos>, faceDeg, lean, headTilt,
//   armLp,armLr,elbL, armRp,armRr,elbR,  hipLp,kneeL, hipRp,kneeR,  skinColor)
//   *p = pitch (fwd/back, +=forward), *r = raise (out to side), elb/knee = bend.
#macro SkeletonHumanoid(Pos, faceDeg, lean, headTilt,
        armLp, armLr, elbL, armRp, armRr, elbR,
        hipLp, kneeL, hipRp, kneeR, skinColor)

  // --- spine (lean tilts the torso forward about x) ---
  #local Pelvis = <0, SK_hipH, 0>;
  #local Chest  = Pelvis + vrotate(<0, SK_torso, 0>, <lean,0,0>);
  #local Neck   = Chest  + vrotate(<0, SK_neck, 0>,  <lean,0,0>);
  #local Head   = Neck   + vrotate(<0, SK_head, 0>,  <lean+headTilt,0,0>);
  // --- arms ---
  #local ShL = Chest + <-SK_shdrW, -0.05, 0>;  #local ShR = Chest + <SK_shdrW, -0.05, 0>;
  #local ElL = ShL + vrotate(<0,-SK_uarm,0>, <armLp,0, armLr>);
  #local ElR = ShR + vrotate(<0,-SK_uarm,0>, <armRp,0,-armRr>);
  #local HaL = ElL + vrotate(<0,-SK_farm,0>, <armLp+elbL,0, armLr>);
  #local HaR = ElR + vrotate(<0,-SK_farm,0>, <armRp+elbR,0,-armRr>);
  // --- legs ---
  #local HiL = Pelvis + <-SK_hipW,0,0>;  #local HiR = Pelvis + <SK_hipW,0,0>;
  #local KnL = HiL + vrotate(<0,-SK_thigh,0>, <hipLp,0,0>);
  #local KnR = HiR + vrotate(<0,-SK_thigh,0>, <hipRp,0,0>);
  #local FtL = KnL + vrotate(<0,-SK_shin,0>, <hipLp+kneeL,0,0>);
  #local FtR = KnR + vrotate(<0,-SK_shin,0>, <hipRp+kneeR,0,0>);

  union {
    blob {
      threshold 0.6
      sphere { Pelvis, 0.40, 1.05 } sphere { Chest, 0.46, 1.15 }
      cylinder { Pelvis, Chest, 0.33, 0.9 }
      cylinder { Neck, Head, 0.18, 0.8 } sphere { Head, 0.34, 1.1 }
      // arms
      sphere { ShL, 0.22, 0.9 } cylinder { ShL, ElL, 0.15, 0.85 }
      sphere { ElL, 0.16, 0.9 } cylinder { ElL, HaL, 0.13, 0.85 } sphere { HaL, 0.18, 1.0 }
      sphere { ShR, 0.22, 0.9 } cylinder { ShR, ElR, 0.15, 0.85 }
      sphere { ElR, 0.16, 0.9 } cylinder { ElR, HaR, 0.13, 0.85 } sphere { HaR, 0.18, 1.0 }
      // legs
      sphere { HiL, 0.24, 0.9 } cylinder { HiL, KnL, 0.19, 0.85 }
      sphere { KnL, 0.18, 0.9 } cylinder { KnL, FtL, 0.16, 0.85 } sphere { FtL, 0.20, 1.0 }
      sphere { HiR, 0.24, 0.9 } cylinder { HiR, KnR, 0.19, 0.85 }
      sphere { KnR, 0.18, 0.9 } cylinder { KnR, FtR, 0.16, 0.85 } sphere { FtR, 0.20, 1.0 }
      Tex_Skin(skinColor)
    }
    // eyes on the head (front = -z in local space)
    #local EyeBase = Head + vrotate(<0,0.05,-0.27>, <lean+headTilt,0,0>);
    sphere { EyeBase + <-0.13,0,0>, 0.09 texture { pigment{rgb 1} finish{phong 0.6 ambient 0.45} } }
    sphere { EyeBase + < 0.13,0,0>, 0.09 texture { pigment{rgb 1} finish{phong 0.6 ambient 0.45} } }
    sphere { EyeBase + <-0.13,0,-0.06>, 0.045 texture { pigment{rgb 0.04} } }
    sphere { EyeBase + < 0.13,0,-0.06>, 0.045 texture { pigment{rgb 0.04} } }
    rotate y*faceDeg
    translate Pos
  }
#end
