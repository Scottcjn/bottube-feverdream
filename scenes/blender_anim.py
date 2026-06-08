"""blender_anim.py — orbiting retro90s hero scene for the GPU animation lane.
Animated sibling of scenes/blender_hero.py: a camera orbits the chrome/glass/
plastic trio over a reflective checkerboard with fractal mountains.

Run:  FD_FRAMES=72 blender -b -P gpu_enable.py -P scenes/blender_anim.py
Frames land in ./output/anim/ (f0001.png ...). FD_FRAMES sets the orbit length.
"""
import os, sys

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
for cand in (os.path.join(_HERE, "lib"),
             os.path.expanduser("~/feverdream/lib"),
             os.path.expanduser("~/feverdream")):
    if os.path.isdir(cand):
        sys.path.append(cand)

from retro90s_blender import *   # noqa

FRAMES = int(os.environ.get("FD_FRAMES", "72"))

retro_reset()
retro_sky_gradient((0.15, 0.20, 0.55), (1.0, 0.55, 0.25))
retro_sun((-0.6, 0.7, -0.4), (1.0, 0.92, 0.78), energy=5.0)
retro_fractal_terrain(height=7.0, scale_xz=22.0, loc=(0, 60, -0.3), extent=80)
retro_checker_floor((0.9, 0.9, 0.95), (0.08, 0.08, 0.12), reflect=0.4, cell=2.0)

retro_sphere((0, 6, 2.2), 2.2, retro_chrome((0.85, 0.88, 0.95)))
retro_sphere((-4, 9, 1.6), 1.6, retro_glass((0.2, 0.9, 0.6)))
retro_torus((4.5, 8, 1.6), 1.6, 0.5, retro_plastic((0.9, 0.12, 0.12)),
            rot_deg=(70, 0, 0))

# camera orbits the hero trio (centered ~ (0,7))
retro_orbit_camera(orbit_radius=11, cam_height=4.5, target=(0, 7, 2.0),
                   frames=FRAMES)

out_dir = os.path.join(os.getcwd(), "output", "anim")
retro_render_anim(out_dir, samples=96)
print(f"[blender_anim] rendered {FRAMES} frames -> {out_dir}")
