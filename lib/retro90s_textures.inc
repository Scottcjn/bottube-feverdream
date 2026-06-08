// retro90s_textures.inc — Tier-1 "textured" material upgrade for the feverdream
// premium lane. Procedural texture + normal/bump maps add real surface detail
// (microsurface tooth, brushed metal, subtle wear) on top of the flat plastic
// look — no external image files needed. Apply like the base material macros.
#include "functions.inc"

// glossy plastic with micro-surface tooth (kills the dead-flat CG-plastic look)
#macro Tex_Plastic(base)
  texture {
    pigment { base }
    normal { granite 0.10 scale 0.05 }
    finish { ambient 0.28 diffuse 0.62 phong 1 phong_size 120 reflection { 0.07 } }
  }
#end

// painted plastic with faint colour variation + wear, for big body panels
#macro Tex_Worn(base, wear)
  texture {
    pigment { bozo turbulence 0.35 color_map { [0.0 base][0.72 base][1.0 wear] } scale 0.55 }
    normal { granite 0.14 scale 0.07 }
    finish { ambient 0.30 diffuse 0.60 phong 0.9 phong_size 90 reflection { 0.05 } }
  }
#end

// brushed metal (anisotropic-ish stretched bump) — for rings, trim, armor
#macro Tex_BrushedMetal(tint)
  texture {
    pigment { tint }
    normal { bumps 0.22 scale <0.006, 0.5, 0.006> }
    finish { ambient 0.20 diffuse 0.34 reflection { 0.45 metallic } phong 1 phong_size 220 metallic }
  }
#end

// subtle skin/soft surface
#macro Tex_Skin(base)
  texture {
    pigment { base }
    normal { bumps 0.04 scale 0.03 }
    finish { ambient 0.35 diffuse 0.72 phong 0.4 phong_size 30 }
  }
#end
