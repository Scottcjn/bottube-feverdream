#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""
ai_scene_blender.py — prompt-to-Blender-scene, GPU animation lane.

Turns a plain-English prompt into an orbiting retro90s Blender scene script
(using retro90s_blender.py macros) and writes it to scenes/{name}.py.

Usage:
    ./ai_scene_blender.py "chrome whale over neon canyon" --name my_scene --frames 144
"""

import argparse
import os
import re
import textwrap


HERE = os.path.dirname(os.path.abspath(__file__))
SCENES = os.path.join(HERE, "scenes")

# ── Template ─────────────────────────────────

SCENE_TEMPLATE = '''# SPDX-License-Identifier: MIT
"""Scene generated from prompt: "{prompt}" — GPU animation lane."""

import os, sys

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
for cand in (os.path.join(_HERE, "lib"),
             os.path.expanduser("~/feverdream/lib"),
             os.path.expanduser("~/feverdream")):
    if os.path.isdir(cand):
        sys.path.append(cand)

from retro90s_blender import *

FRAMES = int(os.environ.get("FD_FRAMES", "{frames_default}"))

retro_reset()
retro_sky_gradient({sky_top}, {sky_horizon})
retro_sun({sun_dir}, {sun_color}, energy={sun_energy})
{terrain}
{floor}
{objects}

# orbit camera
retro_orbit_camera(orbit_radius={orbit_radius}, cam_height={cam_height},
                   target=({target_x}, {target_y}, {target_z}),
                   frames=FRAMES, lens_angle={lens_angle})

out_dir = os.path.join(os.getcwd(), "output", "anim")
retro_render_anim(out_dir, samples={samples})
print(f"[ai_scene_blender] rendered {{FRAMES}} frames -> " + out_dir)
'''

# ── Keyword-based parameterizer ─────────────

# Sky color palettes
SKY_PALETTES = {
    "sunset":   ((1.0, 0.55, 0.25), (0.15, 0.20, 0.55)),
    "night":    ((0.02, 0.02, 0.08), (0.05, 0.0, 0.15)),
    "dawn":     ((0.95, 0.7, 0.3), (0.3, 0.15, 0.4)),
    "cyberpunk":((0.9, 0.2, 0.5), (0.1, 0.0, 0.2)),
    "neon":     ((0.2, 0.9, 0.8), (0.05, 0.0, 0.2)),
    "day":      ((0.6, 0.8, 1.0), (0.8, 0.85, 0.95)),
    "desert":   ((1.0, 0.8, 0.5), (0.9, 0.7, 0.4)),
    "space":    ((0.0, 0.0, 0.02), (0.02, 0.0, 0.1)),
}

# Object generators
HERO_OBJECTS = {
    "chrome":  'retro_sphere((0, 6, 2.2), 2.2, retro_chrome((0.85, 0.88, 0.95)))',
    "glass":   'retro_sphere((-4, 9, 1.6), 1.6, retro_glass((0.2, 0.9, 0.6)))',
    "plastic": 'retro_torus((4.5, 8, 1.6), 1.6, 0.5, retro_plastic((0.9, 0.12, 0.12)), rot_deg=(70, 0, 0))',
}

# Additional themed objects
THEME_OBJECTS = {
    "robot": [
        'retro_sphere((0, 6, 2.2), 2.2, retro_chrome((0.75, 0.8, 0.9)))',
        'retro_box((-4, 9, 1.4), (2, 1.5, 1.2), retro_plastic((0.2, 0.5, 0.8)), rot_deg=(0, 0, 15))',
    ],
    "crystal": [
        'retro_cone((3, 7, 1.8), 1.0, 2.5, retro_glass((0.4, 0.7, 0.9)))',
    ],
    "whale": [
        'retro_sphere((0, 6, 2.2), 2.4, retro_chrome((0.7, 0.75, 0.85)))',
        'retro_sphere((-3, 8, 1.8), 1.2, retro_chrome((0.7, 0.75, 0.85)))',
    ],
    "diamond": [
        'retro_cone((0, 10, 2.0), 2.0, 3.0, retro_glass((0.9, 0.9, 1.0), ior=2.4))',
    ],
    "gear": [
        'retro_torus((0, 7, 1.8), 2.0, 0.6, retro_chrome((0.8, 0.8, 0.85)), rot_deg=(45, 0, 0))',
        'retro_torus((0, 7, 1.8), 1.2, 0.4, retro_chrome((0.8, 0.8, 0.85)), rot_deg=(90, 0, 0))',
    ],
    "tower": [
        'retro_box((0, 5, 1.5), (1.5, 4.0, 1.5), retro_plastic((0.6, 0.3, 0.1)))',
        'retro_sphere((0, 9, 1.5), 1.0, retro_chrome((0.9, 0.85, 0.7)))',
    ],
}

# Floor types
FLOOR_TYPES = {
    "water":    'retro_checker_floor((0.02, 0.1, 0.2), (0.04, 0.15, 0.3), reflect=0.7, cell=4.0)',
    "grid":     'retro_grid_floor((0.0, 0.6, 1.0), (0.02, 0.02, 0.05), cell=3.0)',
    "checker":  'retro_checker_floor((0.9, 0.9, 0.95), (0.08, 0.08, 0.12), reflect=0.35, cell=2.0)',
    "marble":   'retro_checker_floor((0.95, 0.92, 0.88), (0.15, 0.12, 0.1), reflect=0.5, cell=1.5)',
    "lava":     'retro_grid_floor((1.0, 0.3, 0.05), (0.3, 0.05, 0.0), cell=2.0)',
}

TERRAIN_OPTIONS = {
    "mountain": 'retro_fractal_terrain(height=8.0, scale_xz=25.0, loc=(0, 60, -1.0), extent=80)',
    "canyon":   'retro_fractal_terrain(height=12.0, scale_xz=20.0, loc=(3, 55, -2.0), extent=70)',
    "hills":    'retro_fractal_terrain(height=5.0, scale_xz=30.0, loc=(0, 50, -0.5), extent=90)',
    "none":     '',
}

DEFAULT_TERRAIN = 'retro_fractal_terrain(height=7.0, scale_xz=22.0, loc=(0, 60, -0.3), extent=80)'


def _find_keyword(text, keywords):
    """Return the first matching keyword key from a dict."""
    text_lower = text.lower()
    for key in keywords:
        if key in text_lower:
            return key
    return None


def _parse_prompt(prompt):
    """Parse a text prompt into scene parameters using keyword matching."""
    text = prompt.lower()
    
    # Sky
    sky_mood = _find_keyword(text, ["sunset", "night", "dawn", "cyberpunk", "neon", "desert", "space"])
    if not sky_mood:
        sky_mood = "sunset" if any(w in text for w in ["evening", "dusk", "orange"]) else \
                   "neon" if any(w in text for w in ["neon", "synthwave", "vapor", "glow"]) else \
                   "space" if any(w in text for w in ["space", "cosmic", "galaxy", "star"]) else \
                   "day" if any(w in text for w in ["day", "sunny", "bright", "morning"]) else \
                   "sunset"
    sky_top, sky_horizon = SKY_PALETTES[sky_mood]

    # Terrain
    terrain_type = _find_keyword(text, ["canyon", "mountain", "hills"])
    terrain = TERRAIN_OPTIONS.get(terrain_type, DEFAULT_TERRAIN)
    has_terrain = terrain_type or any(w in text for w in ["landscape", "terrain", "world", "environment"])

    # Floor
    floor_type = _find_keyword(text, ["water", "ocean", "sea", "lake"])
    if not floor_type:
        floor_type = "grid" if any(w in text for w in ["grid", "digital", "tron", "matrix"]) else \
                     "marble" if any(w in text for w in ["marble", "elegant", "palace"]) else \
                     "lava" if any(w in text for w in ["lava", "volcano", "fire"]) else \
                     "checker"
    floor = FLOOR_TYPES[floor_type]

    # Hero objects
    theme = _find_keyword(text, THEME_OBJECTS.keys())
    if theme:
        hero_lines = THEME_OBJECTS[theme]
    else:
        # Default hero trio based on materials mentioned
        materials = []
        if any(w in text for w in ["chrome", "metal", "silver", "mirror", "reflective"]):
            materials.append("chrome")
        if any(w in text for w in ["glass", "crystal", "transparent", "refract"]):
            materials.append("glass")
        if any(w in text for w in ["plastic", "glossy", "shiny", "colorful"]):
            materials.append("plastic")
        if not materials:
            materials = ["chrome", "glass", "plastic"]
        
        hero_lines = [HERO_OBJECTS[m] for m in materials if m in HERO_OBJECTS]

    objects = "\n".join(hero_lines)

    # Camera / orbit
    orbit_radius = 11
    cam_height = 4.5
    if theme == "whale":
        orbit_radius = 14
        cam_height = 3.5
    elif theme == "tower":
        orbit_radius = 13
        cam_height = 6.0
    elif any(w in text for w in ["close", "intimate", "detail"]):
        orbit_radius = 7
        cam_height = 3.0
    elif any(w in text for w in ["wide", "epic", "landscape"]):
        orbit_radius = 16
        cam_height = 5.5

    # Sun
    sun_energy = 5.0
    if sky_mood == "night":
        sun_energy = 1.5
    elif sky_mood == "neon":
        sun_energy = 3.0
    elif sky_mood == "space":
        sun_energy = 0.5

    return {
        "sky_top": sky_top,
        "sky_horizon": sky_horizon,
        "sun_dir": (-0.6, 0.7, -0.4),
        "sun_color": (1.0, 0.92, 0.78),
        "sun_energy": sun_energy,
        "terrain": terrain if has_terrain else '# no terrain (plain prompt)',
        "floor": floor,
        "objects": objects,
        "orbit_radius": orbit_radius,
        "cam_height": cam_height,
        "target_x": 0,
        "target_y": 7,
        "target_z": 2.0,
        "lens_angle": 50,
        "samples": 96,
        "frames_default": 144,
    }


def main():
    parser = argparse.ArgumentParser(description="Generate a Blender scene script from a text prompt")
    parser.add_argument("prompt", help="Scene description in plain English")
    parser.add_argument("--name", default="blender_ai_scene", help="Scene name (filename)")
    parser.add_argument("--frames", type=int, default=144, help="Number of frames for orbit animation")
    parser.add_argument("--samples", type=int, default=96, help="Cycles samples per frame")
    parser.add_argument("--output-dir", help="Output directory (default: scenes/)")
    args = parser.parse_args()

    params = _parse_prompt(args.prompt)
    params["frames_default"] = str(args.frames)
    params["samples"] = args.samples

    scene_dir = args.output_dir or SCENES
    os.makedirs(scene_dir, exist_ok=True)
    out_path = os.path.join(scene_dir, f"{args.name}.py")

    # Format template
    scene_code = SCENE_TEMPLATE.format(
        prompt=args.prompt.replace('"', '\\"'),
        **params
    )

    with open(out_path, 'w') as f:
        f.write(scene_code)

    os.chmod(out_path, 0o755)
    print(f"Wrote scene to {out_path}")
    print(f"  Sky: {params['sky_top']} / {params['sky_horizon']}")
    print(f"  Orbit: radius={params['orbit_radius']}, height={params['cam_height']}")
    print(f"  Frames: {args.frames}")
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main())
