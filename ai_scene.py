#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""
ai_scene.py — AI command-line control for the retro-cgi pipeline.

Turns a plain-English prompt into an authentic mid-90s raytraced scene:

    ./ai_scene.py "a chrome robot head floating over a fractal canyon at sunset" --render

It teaches a local LLM the retro90s.inc macro library (system prompt below),
asks it to emit a POV-Ray scene, sanitizes the output, writes a .pov file, and
(optionally) renders it. Default backend is the POWER8 GPT-OSS server — local,
free, and on-brand for an Elyan Labs vintage-CGI factory.

Backend is any OpenAI-compatible /v1/chat/completions endpoint.
"""
import argparse, json, os, re, subprocess, sys, time, urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
LIB  = os.path.join(HERE, "lib")
SCENES = os.path.join(HERE, "scenes")

# Local code-specialized model (fast, ~95 tok/s on the 4070). POV-Ray SDL is
# code, so a coder model suits it well. Override with --llm-url / RETRO_LLM_URL.
DEFAULT_LLM = os.environ.get("RETRO_LLM_URL", "http://localhost:8082/v1/chat/completions")
DEFAULT_MODEL = os.environ.get("RETRO_LLM_MODEL", "qwen2.5-coder-3b-q4.gguf")

# The system prompt IS the API surface: it hands the model the macro library so
# it composes scenes from period-correct building blocks instead of inventing
# inconsistent SDL. Keep this in sync with lib/retro90s.inc.
SYSTEM_PROMPT = r"""You are a POV-Ray 3.7 scene author for an authentic mid-1990s
raytraced look (think Bryce / classic POV-Ray demo art): mirror chrome,
refractive glass, glossy hard-Phong plastic, infinite reflective checkerboards,
procedural fractal terrain, and vertical gradient sunset/twilight skies.

You MUST build scenes by calling ONLY these macros from "retro90s.inc"
(the file is already on the include path — start the scene with: #include "retro90s.inc").
Do not redefine them. Do not add global_settings/camera defaults yourself.

MACROS (signatures and meaning):
  Retro_Sky_Gradient(c_top, c_horizon)            // sky_sphere; colors are rgb <r,g,b>
  Retro_Grid_Floor(grid_color, base_color, cell)  // glowing ReBoot grid plane at y=0
  Retro_Checker_Floor(c1, c2, reflect)            // infinite checker plane, reflect 0..1
  Retro_Chrome(tint)         -> use as a sphere/object texture: sphere{<..>,r Retro_Chrome(rgb<..>)}
  Retro_Glass(tint)          -> refractive colored glass texture (includes interior)
  Retro_Plastic(base)        -> glossy saturated plastic with hard hotspot
  Retro_Fractal_Terrain(height, scale_xz, tex)    // tex must be a texture{...} or Retro_Terrain_Texture()
  Retro_Terrain_Texture()                         // earthy->snow terrain texture
  Retro_Sun(dir, sun_color)                       // dir = direction vector <x,y,z>; adds soft fill
  Retro_Camera(cam_loc, cam_target)               // hero camera

PRIMITIVES you may use freely: sphere, box, torus, cone, cylinder, plane,
union, difference, merge, and transforms (rotate, translate, scale).
Apply Retro_Chrome/Glass/Plastic(...) as the texture inside the primitive braces.

CRITICAL SYNTAX RULES (a scene that breaks these will NOT render):
- FORBIDDEN at top level: raw `plane{}`, `pigment{}`, `finish{}`, and the
  keywords `checker`/`checkboard`/`sky_sphere`/`light_source`/`camera`.
  The floor, sky, sun, and camera come ONLY from the macros below. If you need
  a floor, call Retro_Checker_Floor(...) — never write your own plane.
- Colors are floats 0.0-1.0, e.g. rgb <0.9,0.4,0.1>.  NEVER 0-255.
- Retro_Chrome / Retro_Glass / Retro_Plastic ALREADY expand to a full
  texture{...} block.  Apply them DIRECTLY inside the object — do NOT wrap them
  in another texture{} or material{}.  Wrapping them is the #1 cause of errors.
- Do NOT put a semicolon after a macro call.  `Retro_Sun(...)` not `Retro_Sun(...);`
- A vector is <x,y,z>.  Macro args are comma-separated.

COMPOSITION RULES for a good 90s frame:
- Exactly ONE floor macro (checker OR grid), at y=0.
- Keep objects above y=0; give the hero object pride of place near the center.
- Use exactly 1 Retro_Sun, 1 Retro_Sky_Gradient, and 1 camera.
- Keep terrain height modest (6-12) and pushed into the background so it doesn't
  swallow the hero objects.
- Strong, saturated colors. Sunset oranges, twilight blues, neon accents.

WORKED EXAMPLE (copy this structure and syntax exactly):
#include "retro90s.inc"
Retro_Sky_Gradient(rgb <0.15,0.20,0.55>, rgb <1.0,0.55,0.25>)
Retro_Sun(<-0.6,0.7,-0.4>, rgb <1.0,0.92,0.78>)
Retro_Checker_Floor(rgb <0.9,0.9,0.95>, rgb <0.08,0.08,0.12>, 0.35)
Retro_Fractal_Terrain(8, 22, Retro_Terrain_Texture())
sphere { <0,2.2,6>, 2.2 Retro_Chrome(rgb <0.85,0.88,0.95>) }
sphere { <-4,1.6,9>, 1.6 Retro_Glass(rgb <0.2,0.9,0.6>) }
torus { 1.6, 0.5 Retro_Plastic(rgb <0.9,0.12,0.12>) rotate x*70 translate <4.5,1.4,8> }
Retro_Camera(<0,3.2,-3>, <0,1.8,7>)

OUTPUT: Return ONLY the POV-Ray scene source. No markdown fences, no prose,
no explanation. Start with the #include line."""

def call_llm(prompt, url, model, temperature, timeout):
    body = json.dumps({
        "model": model,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": prompt},
        ],
        "temperature": temperature,
        "max_tokens": 1800,
    }).encode()
    req = urllib.request.Request(url, data=body,
                                headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        data = json.load(r)
    return data["choices"][0]["message"]["content"]

def sanitize(sdl):
    """Strip markdown fences / stray prose; ensure the include line is present."""
    # remove ```pov ... ``` fences if the model added them
    sdl = re.sub(r"^\s*```[a-zA-Z]*\s*", "", sdl)
    sdl = re.sub(r"\s*```\s*$", "", sdl)
    # drop any leading prose before the first directive
    m = re.search(r'(#include|#version|camera|sphere|sky_sphere|Retro_)', sdl)
    if m:
        sdl = sdl[m.start():]
    if 'retro90s.inc' not in sdl:
        sdl = '#include "retro90s.inc"\n' + sdl
    # Defensive fixes for the model's most common mistakes:
    # 1) un-nest texture{ Retro_Chrome(...) } -> Retro_Chrome(...)
    sdl = re.sub(r'texture\s*\{\s*(Retro_(?:Chrome|Glass|Plastic)\([^)]*\))\s*\}',
                 r'\1', sdl)
    # 2) drop semicolons placed right after a Retro_* macro call
    sdl = re.sub(r'(Retro_\w+\([^\n]*\))\s*;', r'\1', sdl)
    # 3) rescale obvious 0-255 colors to 0-1 (any rgb component > 1.5)
    def _fix_color(m):
        nums = [float(x) for x in re.split(r'\s*,\s*', m.group(1))]
        if any(n > 1.5 for n in nums):
            nums = [round(n/255.0, 4) for n in nums]
        return "rgb <" + ",".join(str(n) for n in nums) + ">"
    sdl = re.sub(r'rgb\s*<\s*([0-9.]+\s*,\s*[0-9.]+\s*,\s*[0-9.]+)\s*>',
                 _fix_color, sdl)
    return sdl.strip() + "\n"

def render(pov_path, out_png, w, h, quality):
    aa = "+A0.3" if quality != "draft" else ""
    cmd = ["povray", f"+I{pov_path}", f"+O{out_png}",
           f"+W{w}", f"+H{h}", aa, f"+L{LIB}",
           f"+WT{os.cpu_count()}", "-D"]
    cmd = [c for c in cmd if c]
    print("  $", " ".join(cmd), file=sys.stderr)
    res = subprocess.run(cmd, capture_output=True, text=True)
    err = res.stdout + res.stderr
    pm = re.search(r"line (\d+): Parse Error: (.+)", err)
    if pm:
        return False, f"line {pm.group(1)}: {pm.group(2)}"
    if not os.path.exists(out_png):
        tail = "\n".join(err.splitlines()[-6:])
        return False, tail or "render produced no output"
    return True, out_png

def main():
    ap = argparse.ArgumentParser(description="AI -> POV-Ray retro-CGI scene generator")
    ap.add_argument("prompt", help="plain-English scene description")
    ap.add_argument("--name", default=None, help="basename for the scene/output")
    ap.add_argument("--render", action="store_true", help="render after generating")
    ap.add_argument("--width", type=int, default=1280)
    ap.add_argument("--height", type=int, default=720)
    ap.add_argument("--quality", choices=["draft", "final"], default="final")
    ap.add_argument("--llm-url", default=DEFAULT_LLM)
    ap.add_argument("--model", default=DEFAULT_MODEL)
    ap.add_argument("--temperature", type=float, default=0.7)
    ap.add_argument("--timeout", type=int, default=300)
    ap.add_argument("--retries", type=int, default=2,
                    help="re-ask the LLM if the scene fails to parse")
    ap.add_argument("--animate", action="store_true",
                    help="request an orbiting camera (Retro_Orbit_Camera) for animation")
    args = ap.parse_args()

    name = args.name or re.sub(r"[^a-z0-9]+", "_",
                               args.prompt.lower())[:40].strip("_") or "scene"
    pov_path = os.path.join(SCENES, name + ".pov")
    out_png  = os.path.join(HERE, "output", name + ".png")
    os.makedirs(os.path.dirname(out_png), exist_ok=True)

    user_prompt = args.prompt
    if args.animate:
        user_prompt += ("\n\nANIMATE THIS: use Retro_Orbit_Camera(radius, height, "
                        "<x,y,z>) instead of Retro_Camera so the camera orbits the "
                        "scene via the clock variable. Keep the hero object centered "
                        "near the origin so it stays framed through the full orbit.")
    for attempt in range(1, args.retries + 2):
        print(f"[ai] generating scene (attempt {attempt}) via {args.model} ...",
              file=sys.stderr)
        t0 = time.time()
        try:
            raw = call_llm(user_prompt, args.llm_url, args.model,
                           args.temperature, args.timeout)
        except Exception as e:
            print(f"[ai] LLM call failed: {e}", file=sys.stderr)
            sys.exit(2)
        sdl = sanitize(raw)
        with open(pov_path, "w") as f:
            f.write(sdl)
        print(f"[ai] wrote {pov_path} ({len(sdl)} bytes, {time.time()-t0:.1f}s)",
              file=sys.stderr)

        if not args.render:
            print(pov_path); return

        ok, info = render(pov_path, out_png, args.width, args.height, args.quality)
        if ok:
            print(f"[ai] rendered -> {info}", file=sys.stderr)
            print(out_png); return
        print(f"[ai] render failed: {info}", file=sys.stderr)
        # feed the parse error back so the model can self-correct
        user_prompt = (f"{args.prompt}\n\nYour previous scene FAILED with: {info}\n"
                       "Common cause: you wrote a raw plane{}/pigment{}/light_source{} "
                       "or invented a keyword. Use ONLY the Retro_* macros for floor, "
                       "sky, sun, camera, and materials. Return ONLY corrected source.")
    print("[ai] giving up after retries", file=sys.stderr); sys.exit(1)

if __name__ == "__main__":
    main()
