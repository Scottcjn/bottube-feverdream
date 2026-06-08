// ============================================================
//  retro90s.inc  —  Authentic mid-90s raytrace look library
//  Elyan Labs retro-cgi pipeline.  POV-Ray 3.7 SDL.
//
//  This is the "fever dream" DNA: chrome, glass, infinite
//  checker floors, gradient skies, fractal terrain, hard
//  Phong highlights — the genuine Bryce / POV-Ray era.
//
//  The AI scene generator composes scenes by calling these
//  macros, so every render inherits the period-correct look.
// ============================================================

#version 3.7;
#include "colors.inc"
#include "textures.inc"
#include "functions.inc"   // f_noise3d for procedural terrain

// ---- Global render feel: period-correct, slightly hot lighting ----
global_settings {
  assumed_gamma 1.0
  max_trace_level 8          // enough bounces for chrome-in-chrome
  ambient_light rgb 0.35     // the era loved a bright, punchy ambient floor
}

// ============================================================
//  SKY  —  the signature vertical gradient + optional grid sky
// ============================================================

// Classic Bryce-style sunset/twilight gradient backdrop.
#macro Retro_Sky_Gradient(c_top, c_horizon)
  sky_sphere {
    pigment {
      gradient y
      color_map {
        [0.0 c_horizon]
        [0.5 c_top]
        [1.0 c_top]
      }
      scale 2 translate -1
    }
  }
#end

// ReBoot-style infinite glowing grid stretching to the horizon.
#macro Retro_Grid_Floor(grid_color, base_color, cell)
  plane {
    y, 0
    pigment {
      checker
      pigment { color base_color }
      pigment {
        gradient x scale cell
        color_map { [0.0 grid_color][0.04 grid_color][0.04 base_color][1.0 base_color] }
      }
      scale cell
    }
    finish { ambient 0.5 diffuse 0.4 reflection { 0.25 } }
  }
#end

// The infinite reflective checkerboard — the most iconic floor of the era.
#macro Retro_Checker_Floor(c1, c2, reflect)
  plane {
    y, 0
    pigment { checker color c1 color c2 }
    finish {
      ambient 0.15 diffuse 0.7
      reflection { reflect }
      phong 0.4 phong_size 60
    }
  }
#end

// ============================================================
//  MATERIALS  —  the three pillars: chrome, glass, hot plastic
// ============================================================

// Mirror chrome — bread and butter of 90s demo scenes.
#macro Retro_Chrome(tint)
  texture {
    pigment { color tint }
    finish {
      ambient 0.1 diffuse 0.25
      reflection { 0.85 metallic }
      specular 0.9 roughness 0.001
      metallic
    }
  }
#end

// Refractive colored glass with that crisp raytraced edge.
#macro Retro_Glass(tint)
  texture {
    pigment { color tint filter 0.85 }
    finish {
      ambient 0.05 diffuse 0.1
      reflection { 0.1 0.4 fresnel }
      specular 0.9 roughness 0.0008
    }
  }
  interior { ior 1.5 fade_power 2 fade_distance 4 }
#end

// Glossy saturated plastic with a hard Phong hotspot — very era-correct.
#macro Retro_Plastic(base)
  texture {
    pigment { color base }
    finish {
      ambient 0.2 diffuse 0.65
      phong 1.0 phong_size 120
      reflection { 0.08 }
    }
  }
#end

// ============================================================
//  TERRAIN  —  fractal landscape (the Bryce calling card)
// ============================================================

// Procedural rolling fractal terrain via isosurface noise.
// scale_xz spreads it; height controls drama; tex is a texture{}.
#macro Retro_Fractal_Terrain(height, scale_xz, tex)
  isosurface {
    function {
      y
      - height * f_noise3d(x/scale_xz, 0, z/scale_xz)
      - 0.4 * height * f_noise3d(x/(scale_xz*0.3), 0, z/(scale_xz*0.3))
    }
    contained_by { box { <-60,-2,-60>, <60, height*2, 60> } }
    accuracy 0.01
    max_gradient 4
    texture { tex }
  }
#end

// A ready-made earthy terrain texture with snow caps and rock.
#macro Retro_Terrain_Texture()
  texture {
    pigment {
      gradient y
      turbulence 0.3
      color_map {
        [0.0 color rgb <0.30,0.22,0.12>]   // dirt
        [0.4 color rgb <0.25,0.35,0.15>]   // grass
        [0.7 color rgb <0.45,0.40,0.38>]   // rock
        [0.9 color rgb <0.95,0.95,1.00>]   // snow
        [1.0 color rgb <1,1,1>]
      }
      scale 8
    }
    finish { ambient 0.2 diffuse 0.7 }
  }
#end

// ============================================================
//  LIGHTING  —  a sun + soft fill, the standard era setup
// ============================================================

#macro Retro_Sun(dir, sun_color)
  light_source {
    dir * 1000
    color sun_color * 1.3      // punchy key light
    parallel
    point_at 0
  }
  // soft blue fill from opposite side so shadows aren't pitch black
  light_source {
    -dir * 800 + <0,400,0>
    color rgb <0.35,0.42,0.60>
    shadowless
  }
  // overhead bounce so floors/objects read brightly (era look)
  light_source {
    <0,1200,0>
    color rgb <0.30,0.30,0.34>
    shadowless
  }
#end

// ============================================================
//  CAMERA  —  the slightly-low hero angle the era favored
// ============================================================

#macro Retro_Camera(cam_loc, cam_target)
  camera {
    location cam_loc
    look_at  cam_target
    angle 50
    right x*image_width/image_height   // correct aspect, no stretch
  }
#end

// Orbiting hero camera for animation. POV-Ray sets `clock` from 0..1 across
// the frame range (+KFI/+KFF), so this sweeps a full circle automatically.
// Use this INSTEAD of Retro_Camera when the scene should animate.
#macro Retro_Orbit_Camera(orbit_radius, cam_height, orbit_target)
  camera {
    location <orbit_radius*sin(clock*2*pi), cam_height, orbit_radius*cos(clock*2*pi)>
    look_at  orbit_target
    angle 50
    right x*image_width/image_height
  }
#end
