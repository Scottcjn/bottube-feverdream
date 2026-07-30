import glob, os, sys; sys.path.insert(0, ".")
from fd_validate import validate_scene
LIB="lib"
def has_err(src, needle):
    r=validate_scene(src, LIB)
    hit=any(needle in e for e in r["errors"])
    print(f"  [{'PASS' if hit else 'FAIL'}] catches '{needle}': errors={r['errors'][:2]}")
    return hit

def is_ok(src, label):
    r=validate_scene(src, LIB)
    print(f"  [{'PASS' if r['ok'] else 'FAIL'}] {label}: errors={r['errors'][:2]}")
    return r["ok"]

def has_warn(src, needle, label):
    r=validate_scene(src, LIB)
    hit=any(needle in w for w in r["warnings"])
    print(f"  [{'PASS' if hit else 'FAIL'}] {label}")
    return hit

GOOD = '''#include "retro90s.inc"
Retro_Sky_Gradient(rgb <0.1,0.2,0.5>, rgb <1.0,0.5,0.2>)
Retro_Sun(<-0.6,0.7,-0.4>, rgb <1,0.9,0.8>)
Retro_Fractal_Terrain(14, 22, Retro_Terrain_Texture())
sphere { <0,2,6>, 2 Retro_Chrome(rgb <0.8,0.9,1.0>) }
Retro_Camera(<0,4,-10>, <0,1,4>)
'''
fails=0
# baseline good scene must be OK (vectors' internal commas must NOT miscount args)
r=validate_scene(GOOD, LIB)
print(f"  [{'PASS' if r['ok'] else 'FAIL'}] good scene valid (arg-count vector-safe): {r['errors']}")
fails += 0 if r["ok"] else 1

fails += 0 if has_err(GOOD.replace("Retro_Fractal_Terrain(14, 22, Retro_Terrain_Texture())",
                                   "Retro_Water(<0,0,0>, 5)"), "unknown macro `Retro_Water`") else 1
fails += 0 if has_err(GOOD.replace("Retro_Chrome(rgb <0.8,0.9,1.0>)",
                                   "Retro_Chrome(rgb <0.8,0.9,1.0>, 5)"), "Retro_Chrome` takes 1") else 1
fails += 0 if has_err("#macro Retro_Chrome(t)\n#end\n"+GOOD, "redefines library macro `Retro_Chrome`") else 1
fails += 0 if has_err(GOOD.replace("Retro_Camera(<0,4,-10>, <0,1,4>)","sphere { <0,0,0>, 1"), "unbalanced") else 1
fails += 0 if has_err(GOOD.replace('#include "retro90s.inc"\n',''), "missing `#include") else 1
# truncated: unclosed macro call
fails += 0 if has_err('#include "retro90s.inc"\nRetro_Sun(<0,1,0>, rgb <1,1,1', "never closed") else 1
# camera warning (not an error) — good scene w/o camera should still be ok=True but warn
nocam=validate_scene(GOOD.replace("Retro_Camera(<0,4,-10>, <0,1,4>)\n",""), LIB)
cam_warn=any("no Retro_Camera" in w for w in nocam["warnings"])
print(f"  [{'PASS' if (nocam['ok'] and cam_warn) else 'FAIL'}] no-camera is a warning not an error")
fails += 0 if (nocam["ok"] and cam_warn) else 1


# --- a scene may define its own helper macro (warning, not a parse error) ---
LOCAL = GOOD.replace("sphere { <0,2,6>, 2 Retro_Chrome(rgb <0.8,0.9,1.0>) }", '''#macro Rock(cx, cy, r, tint)
  sphere { <cx, cy, 6>, r Retro_Chrome(tint) }
#end
Rock(-2, 2, 1.2, rgb <0.7,0.5,0.4>)
Rock( 2, 2, 0.8, rgb <0.5,0.6,0.8>)''')
fails += 0 if is_ok(LOCAL, "scene-local macro is not an 'unknown macro'") else 1
fails += 0 if has_warn(LOCAL, "defines its own macro `Rock`",
                       "scene-local macro still warns 'should compose'") else 1
# ...but the local macro's own signature is now enforced
fails += 0 if has_err(LOCAL.replace("Rock(-2, 2, 1.2, rgb <0.7,0.5,0.4>)",
                                    "Rock(-2, 2, 1.2)"), "`Rock` (defined in this scene) takes 4") else 1
# ...and an invented macro is still caught in a scene that defines helpers
fails += 0 if has_err(LOCAL.replace("Rock( 2, 2, 0.8, rgb <0.5,0.6,0.8>)",
                                    "Retro_Water(<0,0,0>, 5)"), "unknown macro `Retro_Water`") else 1

# --- a string that contains // must not blind the scanner ---
# (stripping comments before strings ate the closing quote, and the orphaned
#  quote then swallowed everything up to the next quote in the scene)
SLASHES = GOOD.replace('Retro_Fractal_Terrain(14, 22, Retro_Terrain_Texture())',
                       '#declare Grid = "art//grid.png"\nRetro_Water(<0,0,0>, 5)\n#declare Note = "hero"')
fails += 0 if has_err(SLASHES, "unknown macro `Retro_Water`") else 1
BRACE = GOOD.replace('Retro_Fractal_Terrain(14, 22, Retro_Terrain_Texture())',
                     '#declare Grid = "art//grid.png"').replace(
                     'sphere { <0,2,6>, 2 Retro_Chrome(rgb <0.8,0.9,1.0>) }',
                     'sphere { <0,2,6>, 2\n  Retro_Chrome(rgb <0.8,0.9,1.0>)\n  #debug "placed\\n"\n}')
fails += 0 if is_ok(BRACE, "string with // does not fake a brace imbalance") else 1
# a commented-out include is not an include
fails += 0 if has_err(GOOD.replace('#include "retro90s.inc"',
                                   '// #include "retro90s.inc"'), "missing `#include") else 1

# --- < and > are comparison operators too, not only vector brackets ---
fails += 0 if is_ok(GOOD.replace("Retro_Checker_Floor", "Retro_Checker_Floor").replace(
    'Retro_Fractal_Terrain(14, 22, Retro_Terrain_Texture())',
    'Retro_Checker_Floor(rgb <0.9,0.9,0.95>, rgb <0.1,0.1,0.15>, select(clock>0.5, 0.2, 0.8))'),
    "comparison inside a macro argument does not miscount args") else 1

# --- POV-Ray-authored checks: a keyword cannot be a parameter or a #declare ---
fails += 0 if has_err(GOOD.replace("sphere { <0,2,6>, 2 Retro_Chrome(rgb <0.8,0.9,1.0>) }",
    "#macro Orb(x, y, radius)\n  sphere { <x, y, 6>, radius Retro_Chrome(rgb <1,1,1>) }\n#end\nOrb(0, 2, 2)"),
    "names a parameter `x`") else 1
fails += 0 if has_err(GOOD.replace("Retro_Sun(", "#declare size = 3;\nRetro_Sun("),
                      "`#declare size`") else 1
fails += 0 if is_ok(GOOD.replace("sphere { <0,2,6>, 2 Retro_Chrome(rgb <0.8,0.9,1.0>) }",
    "#macro Orb(cx, cy, rad)\n  sphere { <cx, cy, 6>, rad Retro_Chrome(rgb <1,1,1>) }\n#end\nOrb(0, 2, 2)"),
    "non-keyword parameter names are fine") else 1

# --- the material macros already ARE a texture; modifiers belong on the object ---
fails += 0 if has_err(GOOD.replace("sphere { <0,2,6>, 2 Retro_Chrome(rgb <0.8,0.9,1.0>) }",
    "sphere { <0,2,6>, 2\n  texture { Retro_Chrome(rgb <0.8,0.9,1.0>) }\n}"),
    "wrapped in `texture{ }`") else 1
fails += 0 if has_err(GOOD.replace("sphere { <0,2,6>, 2 Retro_Chrome(rgb <0.8,0.9,1.0>) }",
    "sphere { <0,2,6>, 2\n  texture { pigment { rgb <0.8,0.2,0.2> } finish { ambient 1 } no_shadow }\n}"),
    "`no_shadow` is inside a `texture{ }` block") else 1
fails += 0 if is_ok(GOOD.replace("sphere { <0,2,6>, 2 Retro_Chrome(rgb <0.8,0.9,1.0>) }",
    "sphere { <0,2,6>, 2\n  texture { pigment { rgb <0.8,0.2,0.2> } finish { ambient 1 } }\n  no_shadow\n}"),
    "no_shadow on the object (not in the texture) is fine") else 1

# --- regression: the verdict on every shipped scene must match POV-Ray's own ---
# Ground truth from rendering all 61 at 160x90 with POV-Ray 3.7.0.10: 57 parse,
# 4 do not. Those 4 are the KNOWN_BAD below (the reason given is POV-Ray's own
# first error), plus mainframe_residents.pov, which POV-Ray renders but which
# breaks the project's own rule 2 by redefining the library macro Googly.
KNOWN_BAD={
  "scenes/templates/asteroid_field.pov":     "no_shadow/inverse inside texture{}",
  "scenes/templates/bouncy_90s_demo.pov":    "#macro Orb(x, y, ...) — x/y are keywords",
  "scenes/templates/chrome_text_logo.pov":   "#macro ChromeBlock(x, y, ...) — keywords",
  "scenes/templates/glass_city_skyline.pov": "no_shadow inside texture{}",
  "scenes/templates/mainframe_residents.pov":"redefines library macro Googly",
}
bad={}
for f in sorted(glob.glob("scenes/*.pov")) + sorted(glob.glob("scenes/templates/*.pov")):
    r=validate_scene(open(f, encoding="utf-8", errors="replace").read(), LIB)
    if not r["ok"]:
        bad[f]=r["errors"][:1]
unexpected=[f for f in bad if f not in KNOWN_BAD]
missed=[f for f in KNOWN_BAD if f not in bad]
ok = not unexpected and not missed
print(f"  [{'PASS' if ok else 'FAIL'}] shipped scenes: {len(bad)} invalid, expected "
      f"{len(KNOWN_BAD)} (false rejects: {unexpected[:3]}, missed: {missed[:3]})")
fails += 0 if ok else 1

print(f"\n{'ALL VALIDATOR TESTS PASSED' if fails==0 else str(fails)+' TEST(S) FAILED'}")
sys.exit(1 if fails else 0)
