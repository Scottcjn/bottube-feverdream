// bouncy_90s_demo.pov — a hand-bouncy 90s product-shot demo: a chrome
// fractal-terrain landscape with three colored chrome spheres orbiting a
// central hub, a la late-90s product renders and Bryce gallery shots.
// Hand-authored. Re-dress: change sphere tints, swap the camera radius,
// change the orbit target.
#include "retro90s.inc"

Retro_Sky_Gradient(rgb <0.25, 0.10, 0.45>, rgb <0.95, 0.55, 0.20>)
Retro_Sun(<-0.5, 0.5, -0.5>, rgb <1.10, 0.90, 0.65>)

// Hub: chrome disc on a fractal floor.
disc { <0, 0, 0>, <0, 1, 0>, 1.6
  texture { Retro_Chrome(rgb <0.95, 0.95, 1.0>) }
  translate <0, 0.6, 0>
}
Retro_Fractal_Terrain(1.8, 0.20, Retro_Terrain_Texture())

// Three orbiting spheres — animation driven by `clock` via the angle
// in the macro below, so animate.sh's +KFI/+KFF can use this as-is.
#macro Orb(ring_r, ang, y, tint)
  sphere { <ring_r * cos(ang), y, ring_r * sin(ang)>, 0.55
    texture { Retro_Chrome(tint) }
  }
#end

union {
  Orb(3.0, clock * 2 * pi,         1.2, rgb <1.00, 0.35, 0.20>)   // red orbit
  Orb(3.0, clock * 2 * pi + 2.094, 1.4, rgb <0.20, 0.95, 0.40>)   // green orbit (120 deg)
  Orb(3.0, clock * 2 * pi + 4.189, 1.0, rgb <0.30, 0.55, 1.00>)   // blue orbit  (240 deg)
}

Retro_Orbit_Camera(7.5, 3.0, <0, 0.8, 0>)
