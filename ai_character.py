#!/usr/bin/env python3
"""
ai_character.py — prompt -> smooth blob/metaball character, the old-school way.

The "new way for us": instead of the model writing raw POV-Ray, it emits a
METABALL SKELETON (weighted spheres + cylinders) as JSON. This script fuses that
skeleton into one continuous smooth `blob` surface (Blinn 1982) and renders it
deterministically — no sculpting tool, no mesh-gen API, fully self-contained.

    ./ai_character.py "a chubby three-eyed swamp gremlin" --render

Backend: any OpenAI-compatible endpoint (RETRO_LLM_URL, default localhost:8082).
"""
import argparse, json, os, re, subprocess, sys, time, urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
LIB, SCENES = os.path.join(HERE, "lib"), os.path.join(HERE, "scenes")
DEFAULT_LLM = os.environ.get("RETRO_LLM_URL", "http://localhost:8082/v1/chat/completions")
DEFAULT_MODEL = os.environ.get("RETRO_LLM_MODEL", "qwen2.5-coder-3b-q4.gguf")

SYSTEM_PROMPT = r"""You design a smooth 3D character as a METABALL (blob) skeleton
for a raytraced render. Output ONLY a JSON object (no prose, no code fences):

{
  "name": "short_slug",
  "skin": [r,g,b],          // body colour, floats 0..1
  "components": [           // weighted parts that FUSE into ONE smooth body
    {"t":"s","p":[x,y,z],"r":radius,"w":strength},            // sphere
    {"t":"c","a":[x,y,z],"b":[x,y,z],"r":radius,"w":strength} // cylinder (neck/limb)
  ],
  "eyes": [[x,y,z],[x,y,z]],   // 2 (or more) eye centres, on the FRONT of the head (-z)
  "eye_r": 0.15
}

RULES:
- Feet near y=0, head highest; total height about 3 units. Roughly symmetric in x.
- Good humanoid: big torso sphere (w 1.1), hips sphere, a head sphere on top,
  cylinders for neck/arms/legs (w 0.85-0.95), spheres for hands/feet (w 1.0).
- 8 to 16 components. strengths 0.7-1.2, radii 0.15-1.0.
- eyes just in front of the head sphere (z a bit more negative than the head),
  eye_r 0.12-0.18.
Return ONLY the JSON object."""

EXAMPLE = ('{"name":"blue_buddy","skin":[0.25,0.55,0.95],"components":['
           '{"t":"s","p":[0,2.0,0],"r":0.95,"w":1.1},'
           '{"t":"s","p":[0,1.45,0],"r":0.8,"w":1.0},'
           '{"t":"c","a":[0,2.35,0],"b":[0,2.85,0],"r":0.3,"w":1.0},'
           '{"t":"s","p":[0,3.05,0],"r":0.6,"w":1.2},'
           '{"t":"c","a":[-0.5,2.4,0],"b":[-1.05,1.55,0.1],"r":0.28,"w":0.9},'
           '{"t":"c","a":[0.5,2.4,0],"b":[1.05,1.55,0.1],"r":0.28,"w":0.9},'
           '{"t":"s","p":[-1.1,1.45,0.1],"r":0.32,"w":1.0},'
           '{"t":"s","p":[1.1,1.45,0.1],"r":0.32,"w":1.0},'
           '{"t":"c","a":[-0.3,1.2,0],"b":[-0.42,0.3,0],"r":0.32,"w":0.9},'
           '{"t":"c","a":[0.3,1.2,0],"b":[0.42,0.3,0],"r":0.32,"w":0.9}],'
           '"eyes":[[-0.22,3.1,-0.5],[0.22,3.1,-0.5]],"eye_r":0.16}')


def call_llm(prompt, url, model, timeout):
    body = json.dumps({
        "model": model,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": f"Example output:\n{EXAMPLE}\n\nNow design: {prompt}"},
        ],
        "temperature": 0.6, "max_tokens": 1400,
    }).encode()
    req = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return json.load(r)["choices"][0]["message"]["content"]


def extract_json(text):
    text = re.sub(r"```[a-zA-Z]*", "", text)
    m = re.search(r"\{.*\}", text, re.DOTALL)
    if not m:
        raise ValueError("no JSON object in model output")
    blob = m.group(0)
    # the local model loves to add JS-style comments + trailing commas; JSON forbids both
    blob = re.sub(r"//[^\n]*", "", blob)
    blob = re.sub(r"/\*.*?\*/", "", blob, flags=re.DOTALL)
    blob = re.sub(r",(\s*[}\]])", r"\1", blob)
    return json.loads(blob)


def _v(a):
    return f"<{a[0]},{a[1]},{a[2]}>"


def build_scene(spec):
    skin = spec.get("skin", [0.4, 0.6, 0.9])
    comps = spec.get("components", [])[:24]
    parts = []
    for c in comps:
        if c.get("t") == "s":
            parts.append(f'  sphere {{ {_v(c["p"])}, {c.get("r",0.4)}, {c.get("w",1.0)} }}')
        elif c.get("t") == "c":
            parts.append(f'  cylinder {{ {_v(c["a"])}, {_v(c["b"])}, {c.get("r",0.25)}, {c.get("w",0.9)} }}')
    eyes = spec.get("eyes", [])[:6]
    er = spec.get("eye_r", 0.15)
    eye_objs = []
    for e in eyes:
        eye_objs.append(f'sphere {{ {_v(e)}, {er} texture {{ pigment{{rgb 1}} finish{{phong 0.6 ambient 0.45}} }} }}')
        pup = [e[0], e[1], e[2] - er * 0.8]
        eye_objs.append(f'sphere {{ {_v(pup)}, {er*0.5} texture {{ pigment{{rgb 0.04}} }} }}')
    return f'''// AI-generated blob character: {spec.get("name","char")}
#include "retro90s.inc"
#include "retro90s_textures.inc"
Retro_Sky_Gradient(rgb <0.35,0.5,0.85>, rgb <0.7,0.92,1.0>)
Retro_Sun(<-0.4,0.8,-0.35>, rgb <1.0,0.98,0.92>)
Retro_Checker_Floor(rgb <0.85,0.88,0.95>, rgb <0.3,0.5,0.78>, 0.18)
blob {{
  threshold 0.6
{chr(10).join(parts)}
  Tex_Skin(rgb <{skin[0]},{skin[1]},{skin[2]}>)
}}
{chr(10).join(eye_objs)}
Retro_Camera(<-2.6,2.8,-5.6>, <0,1.7,0>)
'''


def render(pov, out, w, h):
    cmd = ["povray", f"+I{pov}", f"+O{out}", f"+W{w}", f"+H{h}", "+A0.3",
           f"+L{LIB}", f"+WT{os.cpu_count()}", "-D"]
    res = subprocess.run(cmd, capture_output=True, text=True)
    err = res.stdout + res.stderr
    pm = re.search(r"line (\d+): Parse Error: (.+)", err)
    if pm:
        return False, f"line {pm.group(1)}: {pm.group(2)}"
    return os.path.exists(out), (out if os.path.exists(out) else "no output")


def main():
    ap = argparse.ArgumentParser(description="prompt -> smooth blob/metaball character")
    ap.add_argument("prompt")
    ap.add_argument("--name", default=None)
    ap.add_argument("--render", action="store_true")
    ap.add_argument("--width", type=int, default=560)
    ap.add_argument("--height", type=int, default=560)
    ap.add_argument("--llm-url", default=DEFAULT_LLM)
    ap.add_argument("--model", default=DEFAULT_MODEL)
    ap.add_argument("--timeout", type=int, default=180)
    ap.add_argument("--retries", type=int, default=2)
    args = ap.parse_args()

    for attempt in range(1, args.retries + 2):
        print(f"[ai-char] generating skeleton (attempt {attempt}) ...", file=sys.stderr)
        try:
            raw = call_llm(args.prompt, args.llm_url, args.model, args.timeout)
            spec = extract_json(raw)
        except Exception as e:
            print(f"[ai-char] generation/parse failed: {e}", file=sys.stderr)
            continue
        name = args.name or re.sub(r"[^a-z0-9]+", "_", (spec.get("name") or args.prompt).lower())[:40].strip("_") or "char"
        pov = os.path.join(SCENES, f"char_{name}.pov")
        with open(pov, "w") as f:
            f.write(build_scene(spec))
        print(f"[ai-char] wrote {pov} ({len(spec.get('components',[]))} blob parts)", file=sys.stderr)
        if not args.render:
            print(pov); return
        out = os.path.join(HERE, "output", f"char_{name}.png")
        os.makedirs(os.path.dirname(out), exist_ok=True)
        ok, info = render(pov, out, args.width, args.height)
        if ok:
            print(f"[ai-char] rendered -> {info}", file=sys.stderr); print(out); return
        print(f"[ai-char] render failed: {info}", file=sys.stderr)
    print("[ai-char] gave up", file=sys.stderr); sys.exit(1)


if __name__ == "__main__":
    main()
