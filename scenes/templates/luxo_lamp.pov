// luxo_lamp.pov — generic articulated desk lamp hopping by a ball, the
// 1986-era CGI short look. No trademarks: just a friendly little lamp.
#include "retro90s.inc"

Retro_Sky_Gradient(rgb <0.30,0.35,0.55>, rgb <0.85,0.85,0.92>)
Retro_Sun(<-0.5,0.8,-0.3>, rgb <1.0,0.98,0.92>)
Retro_Checker_Floor(rgb <0.92,0.92,0.95>, rgb <0.55,0.55,0.62>, 0.25)

#declare Hop  = abs(sin(clock*2*pi))*1.1;            // little hop
#declare Lean = sin(clock*2*pi)*8;                   // lean into the hop
#declare Body = texture { pigment { rgb <0.92,0.92,0.95> } finish { ambient 0.3 diffuse 0.6 phong 0.8 phong_size 60 reflection { 0.12 } } }

// emissive bulb + spotlight, riding with the lamp
#declare Bx = 0; #declare By = 1.95+Hop; #declare Bz = -2.1;
light_source { <Bx,By,Bz> color rgb <1.4,1.35,1.1> spotlight point_at <0.4,0,-3.2> radius 16 falloff 26 }

// the lamp
union {
  cylinder { <0,0,0>, <0,0.16,0>, 0.85 texture { Body } }           // base
  cylinder { <0,0.16,0>, <0,1.55,-0.35>, 0.12 texture { Body } }    // lower arm
  sphere   { <0,1.55,-0.35>, 0.18 texture { Body } }                // elbow
  cylinder { <0,1.55,-0.35>, <0,2.45,-1.35>, 0.12 texture { Body } }// upper arm
  sphere   { <0,2.45,-1.35>, 0.20 texture { Body } }                // head joint
  cone { <0,2.45,-1.35>, 0.18, <0,1.95,-2.10>, 0.62 open texture { Body } } // shade
  sphere { <0,2.05,-2.0>, 0.20 texture { pigment { rgb <1,0.97,0.8> } finish { ambient 2.0 } } } // bulb
  rotate x*Lean
  translate <0, Hop, 0>
}

// the lamp's little ball (generic yellow with a blue band)
sphere { <1.7,0.45,-2.4>, 0.45
  texture {
    uv_mapping
    pigment { gradient v color_map { [0.0 rgb <0.95,0.8,0.1>][0.42 rgb <0.95,0.8,0.1>][0.42 rgb <0.1,0.3,0.8>][0.58 rgb <0.1,0.3,0.8>][0.58 rgb <0.95,0.8,0.1>][1.0 rgb <0.95,0.8,0.1>] }
    }
    finish { ambient 0.3 diffuse 0.7 phong 0.7 phong_size 50 }
  }
}

Retro_Camera(<-3.2,2.6,-5.2>, <0.2,1.3,-1.4>)
