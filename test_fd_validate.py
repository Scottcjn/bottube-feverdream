import sys; sys.path.insert(0, ".")
from fd_validate import validate_scene
LIB="lib"
def has_err(src, needle):
    r=validate_scene(src, LIB)
    hit=any(needle in e for e in r["errors"])
    print(f"  [{'PASS' if hit else 'FAIL'}] catches '{needle}': errors={r['errors'][:2]}")
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

print(f"\n{'ALL VALIDATOR TESTS PASSED' if fails==0 else str(fails)+' TEST(S) FAILED'}")
sys.exit(1 if fails else 0)
