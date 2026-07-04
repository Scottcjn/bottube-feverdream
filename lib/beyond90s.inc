// ============================================================
//  beyond90s.inc  —  "Beyond the Mind's Eye" (1992) look pack
//  Elyan Labs retro-cgi pipeline.  POV-Ray 3.7 SDL.
//
//  Companion to retro90s.inc — adds the signature early-CGI
//  compilation vibe: three-stop sunset gradient skies, dark
//  mesa/butte horizon silhouettes, polished GOLD chrome,
//  starfields, glowing planets, and product-viz plinths.
//
//  Conventions match retro90s.inc: pure macros, no camera or
//  global_settings here. Include retro90s.inc FIRST in scenes
//  (it owns global_settings); this file only defines macros.
// ============================================================

// ============================================================
//  SKY  —  the signature THREE-stop sunset gradient
// ============================================================

// The Mind's Eye sunset: deep violet/blue zenith, a hot
// orange/magenta band, and a yellow glow hugging the horizon.
// Below the horizon stays c_glow so chrome/floors reflect warmth.
//   c_top  = zenith color        (e.g. rgb <0.10,0.05,0.35>)
//   c_band = hot mid band        (e.g. rgb <1.00,0.30,0.45>)
//   c_glow = horizon glow        (e.g. rgb <1.00,0.85,0.30>)
#macro Beyond_Sunset_Sky(c_top, c_band, c_glow)
  sky_sphere {
    pigment {
      gradient y
      color_map {
        [0.00  c_glow]     // everything below the horizon: warm glow
        [0.50  c_glow]     // horizon line
        [0.545 c_band]     // hot orange/magenta band hugs the horizon
        [0.585 c_band]
        [0.66  c_top]      // deep violet/blue takes over fast (so the
        [1.00  c_top]      // top stop is visible in a level camera frame)
      }
      scale 2 translate -1
    }
  }
#end

// ============================================================
//  HORIZON  —  dark mesa/butte silhouettes in a ring
// ============================================================

// A ring of `butte_count` dark angular buttes at distance `dist`,
// standing on y=0, up to `height` tall. Widths/heights vary
// deterministically per butte (sin-hash) so the skyline reads
// natural but renders identically every frame of an animation.
// Emits a union — wrap in object{} to rotate/translate it.
// (NB: params avoid POV reserved words like `count`.)
#macro Beyond_Mesa_Ring(butte_color, butte_count, dist, height)
  union {
    #local i = 0;
    #while (i < butte_count)
      // pseudo-random (but deterministic) jitter per butte
      #local ang = 360*i/butte_count + 8*sin(i*12.9898);
      #local h   = height * (0.55 + 0.45*abs(sin(i*3.7 + 1.3)));
      #local w   = (dist*pi/butte_count) * (0.9 + 0.5*abs(cos(i*2.3)));
      #local d   = w*0.5;
      union {
        // main butte slab
        box { <-w/2, 0, -d/2>, <w/2, h, d/2> }
        // stepped cap — the classic flat-top butte profile
        box { <-w*0.30, h*0.98, -d*0.40>, <w*0.30, h*1.22, d*0.40> }
        // talus skirt at the base
        cone { <0,0,0>, w*0.75, <0, h*0.45, 0>, w*0.28 }
        translate <0, 0, dist>
        rotate y*ang
      }
      #local i = i + 1;
    #end
    pigment { color butte_color }
    // near-flat shading: buttes should read as silhouettes
    finish { ambient 0.25 diffuse 0.35 }
  }
#end

// ============================================================
//  MATERIALS  —  polished gold chrome
// ============================================================

// Warm metallic GOLD chrome — the iconic posing-figure material.
// tint multiplies the gold base; pass rgb <1,1,1> for pure gold,
// or push it warmer/cooler. Needs a bright sky to mirror (same
// rule as Retro_Chrome).
#macro Beyond_Gold(tint)
  texture {
    pigment { color tint * <1.00, 0.78, 0.34> }
    finish {
      ambient 0.12 diffuse 0.30
      brilliance 4
      reflection { 0.65 metallic }
      specular 1.0 roughness 0.0015
      metallic
    }
  }
#end

// ============================================================
//  SPACE  —  starfield + glowing planet
// ============================================================

// Points of light on a huge inward-facing sphere (radius 900,
// so it sits inside the sky_sphere but beyond any scene geometry).
//   star_density = 0..1  (0 = very sparse, 1 = dense field)
//   star_color   = star tint (e.g. rgb <1,0.95,0.85>)
// no_shadow so it never dapples the sun; emission so stars stay
// bright regardless of scene lighting.
#macro Beyond_Starfield(star_density, star_color)
  sphere {
    <0,0,0>, 900
    hollow no_shadow
    texture {
      pigment {
        granite
        color_map {
          [0.00                      rgbt <0,0,0,1>]
          [0.78 - 0.18*star_density  rgbt <0,0,0,1>]
          [0.80 - 0.18*star_density  color star_color]
          [1.00                      color star_color]
        }
        scale 25
      }
      finish { emission 1.0 ambient 0 diffuse 0 }
    }
  }
#end

// Glowing planet: a softly banded lit sphere wrapped in an
// emissive media atmosphere that brightens at the limb (rim glow).
// Emits a union centered at the origin — wrap in object{} and
// translate it into the sky:  object { Beyond_Planet(9, rgb<1,0.62,0.2>,
// rgb<1,0.45,0.15>) translate <-30,40,80> }
#macro Beyond_Planet(p_radius, surface_color, glow_color)
  union {
    // the lit body — subtle turbulent banding, soft shading
    sphere {
      <0,0,0>, p_radius
      texture {
        pigment {
          gradient y
          turbulence 0.55
          color_map {
            [0.00 color surface_color*0.55]
            [0.45 color surface_color]
            [0.62 color surface_color*1.25]
            [1.00 color surface_color*0.70]
          }
          scale p_radius*0.6
        }
        finish { ambient 0.30 diffuse 0.75 specular 0.15 roughness 0.05 }
      }
    }
    // emissive atmosphere shell — media path length peaks at the
    // limb, so the rim glows brightest (view-independent, safe for
    // orbit cameras). Emission scales with 1/p_radius so the glow
    // strength is consistent across planet sizes.
    sphere {
      <0,0,0>, p_radius*1.22
      hollow no_shadow
      pigment { color rgbt <0,0,0,1> }
      finish { ambient 0 diffuse 0 }
      interior {
        media {
          emission glow_color * (1.6/p_radius)
          density {
            spherical
            density_map {
              [0.00 rgb 0.00]   // outer edge of atmosphere
              [0.10 rgb 0.90]   // just off the limb: hottest
              [0.18 rgb 0.15]   // planet surface — fades over the disc
              [1.00 rgb 0.05]
            }
            scale p_radius*1.22
          }
        }
      }
    }
  }
#end

// ============================================================
//  PRODUCT VIZ  —  "3D PERSPECTIVE VIEW" turntable plinth
// ============================================================

// A dark display drum with a chrome trim ring and a glowing top
// disc marked with radial turntable ticks. The plinth STANDS ON
// y=0 (so it works with the Retro floors); its top surface is at
// y = plinth_size*0.30 — translate the hero up by that amount:
//   object { Beyond_Plinth(6, rgb <0.15,0.45,0.9>) }
//   object { My_Hero translate <0, 6*0.30, 0> }
//   plinth_size = plinth radius (param avoids POV reserved word `size`)
//   top_color   = glowing display-top color (e.g. rgb <0.15,0.45,0.9>)
// Emits a union — wrap in object{} to move it if needed.
#macro Beyond_Plinth(plinth_size, top_color)
  union {
    // dark drum base
    cylinder {
      <0, 0, 0>, <0, plinth_size*0.25, 0>, plinth_size
      pigment { color rgb <0.06, 0.06, 0.09> }
      finish { ambient 0.15 diffuse 0.5 phong 0.5 phong_size 80 reflection { 0.10 } }
    }
    // chrome trim ring at the lip
    torus {
      plinth_size*0.97, plinth_size*0.045
      pigment { color rgb <0.90, 0.90, 0.95> }
      finish {
        ambient 0.1 diffuse 0.25
        reflection { 0.85 metallic }
        specular 0.9 roughness 0.001
        metallic
      }
      translate <0, plinth_size*0.25, 0>
    }
    // glowing display top with radial degree ticks
    cylinder {
      <0, plinth_size*0.25, 0>, <0, plinth_size*0.30, 0>, plinth_size*0.94
      pigment {
        radial frequency 24
        color_map {
          [0.00 color top_color*1.25]
          [0.06 color top_color*1.25]
          [0.06 color top_color*0.65]
          [1.00 color top_color*0.65]
        }
      }
      finish { ambient 0.45 diffuse 0.6 phong 0.6 phong_size 90 reflection { 0.08 } }
    }
  }
#end
