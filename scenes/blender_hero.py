# SPDX-License-Identifier: MIT
"""blender_hero.py — the retro90s hero scene, GPU lane (Blender/Cycles).
Equivalent of scenes/demo_chrome_sunset.pov, built with retro90s_blender.

Run: blender -b -P gpu_enable.py -P scenes/blender_hero.py
(gpu_enable.py forces OptiX/CUDA first.)
"""
import os, sys
# locate the look library next to this script's repo
_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(os.path.join(_HERE, "lib"))
# when run via blender on a remote box, fall back to ~/feverdream/lib
for cand in (os.path.join(_HERE, "lib"),
             os.path.expanduser("~/feverdream/lib"),
             os.path.expanduser("~/feverdream")):
    if os.path.isdir(cand):
        sys.path.append(cand)

from retro90s_blender import *   # noqa

retro_reset()

# twilight-blue top, hot sunset horizon
retro_sky_gradient((0.15, 0.20, 0.55), (1.0, 0.55, 0.25))
retro_sun((-0.6, 0.7, -0.4), (1.0, 0.92, 0.78), energy=5.0)

# fractal mountains FAR in the background, behind the hero objects (y=6..9)
retro_fractal_terrain(height=7.0, scale_xz=22.0, loc=(0, 60, -0.3), extent=80)

# iconic reflective checkerboard
retro_checker_floor((0.9, 0.9, 0.95), (0.08, 0.08, 0.12), reflect=0.4, cell=2.0)

# hero chrome sphere + colored glass + glossy red torus  (POV x, depth, height)
retro_sphere((0, 6, 2.2), 2.2, retro_chrome((0.85, 0.88, 0.95)))
retro_sphere((-4, 9, 1.6), 1.6, retro_glass((0.2, 0.9, 0.6)))
retro_torus((4.5, 8, 1.6), 1.6, 0.5, retro_plastic((0.9, 0.12, 0.12)),
            rot_deg=(70, 0, 0))

retro_camera((0, -3, 3.2), (0, 7, 1.8))

out = os.path.join(os.getcwd(), "output", "blender_hero.png")
retro_render_still(out, samples=128)
print(f"[blender_hero] saved {out}")
