#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""
fd_validate.py — pre-render validator for LLM-authored retro90s POV-Ray scenes.

The pipeline's expensive step is the raytrace. A small model writing SDL will
sometimes invent a macro, pass the wrong number of arguments, redefine a library
macro, or stop mid-scene with unbalanced braces — and today none of that is
caught until POV-Ray fails (or worse, renders garbage). This checks a scene
against the macro contract in `lib/*.inc` first, so ai_scene.py can reject or
feed the exact errors back to the model instead of burning a render.

The known-macro set and each macro's arity are harvested from `lib/*.inc` at
run time, so this never drifts from the library.

    ./fd_validate.py scene.pov            # exit 0 = ok, 1 = errors
    validate_scene(source, lib_dir)       # -> {ok, errors, warnings, macros_used}
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_LIB = os.path.join(HERE, "lib")

_OPEN = {"(": ")", "[": "]", "{": "}", "<": ">"}
_CLOSE = {v: k for k, v in _OPEN.items()}


def strip_noise(src: str) -> str:
    """Remove // and /* */ comments and "double-quoted strings" so brace/paren
    scanning and macro detection never trip over text inside them."""
    src = re.sub(r"/\*.*?\*/", " ", src, flags=re.DOTALL)
    src = re.sub(r"//[^\n]*", " ", src)
    src = re.sub(r'"(?:[^"\\]|\\.)*"', '""', src)
    return src


def harvest_macros(lib_dir: str) -> dict:
    """Return {macro_name: arg_count} for every #macro defined in lib/*.inc."""
    macros = {}
    if not os.path.isdir(lib_dir):
        return macros
    for fn in sorted(os.listdir(lib_dir)):
        if not fn.endswith(".inc"):
            continue
        text = strip_noise(open(os.path.join(lib_dir, fn), encoding="utf-8",
                                 errors="replace").read())
        for m in re.finditer(r"#macro\s+([A-Za-z_]\w*)\s*\(([^)]*)\)", text):
            name, args = m.group(1), m.group(2).strip()
            macros[name] = 0 if args == "" else args.count(",") + 1
    return macros


def _split_top_level_args(inner: str):
    """Split a macro call's argument text on TOP-LEVEL commas only — commas
    inside <vectors>, nested (calls), {blocks} or [arrays] do not separate args."""
    args, depth, cur = [], 0, []
    for ch in inner:
        if ch in _OPEN:
            depth += 1
        elif ch in _CLOSE:
            depth = max(0, depth - 1)
        if ch == "," and depth == 0:
            args.append("".join(cur))
            cur = []
        else:
            cur.append(ch)
    tail = "".join(cur).strip()
    if tail or args:
        args.append(tail)
    return [a.strip() for a in args]


def _find_calls(src: str):
    """Yield (name, arg_text, ok_balanced) for every `Identifier( ... )` whose
    name starts with an uppercase letter (library macros are Capitalized; POV
    built-ins are lowercase). Uses balanced-paren matching to grab the arg text."""
    for m in re.finditer(r"\b([A-Z]\w*)\s*\(", src):
        name = m.group(1)
        i = m.end() - 1  # at the '('
        depth, j = 0, i
        n = len(src)
        while j < n:
            c = src[j]
            if c == "(":
                depth += 1
            elif c == ")":
                depth -= 1
                if depth == 0:
                    yield name, src[i + 1:j], True
                    break
            j += 1
        else:
            yield name, src[i + 1:], False


def validate_scene(source: str, lib_dir: str = DEFAULT_LIB) -> dict:
    macros = harvest_macros(lib_dir)
    errors, warnings, used = [], [], []
    clean = strip_noise(source)

    # 1. must pull in the library
    if '#include "retro90s.inc"' not in source and "#include \"retro90s.inc\"" not in source:
        errors.append('missing `#include "retro90s.inc"` (must be the first line)')

    # 2. the scene must not redefine library macros
    for m in re.finditer(r"#macro\s+([A-Za-z_]\w*)", clean):
        if m.group(1) in macros:
            errors.append(f"redefines library macro `{m.group(1)}` (forbidden)")
        else:
            warnings.append(f"defines its own macro `{m.group(1)}` (scenes should compose, not define)")

    # 3. balanced braces/parens overall (catch truncated output)
    for op, name in ((("{", "}"), "braces"), (("(", ")"), "parens")):
        if clean.count(op[0]) != clean.count(op[1]):
            errors.append(f"unbalanced {name}: {clean.count(op[0])} `{op[0]}` vs {clean.count(op[1])} `{op[1]}`")

    # 4. every Capitalized(...) call must be a known macro with the right arity
    cams = 0
    for name, arg_text, balanced in _find_calls(clean):
        if not balanced:
            errors.append(f"`{name}(` is never closed (truncated scene?)")
            continue
        if name not in macros:
            errors.append(f"unknown macro `{name}` — not defined in lib/*.inc")
            continue
        used.append(name)
        if name in ("Retro_Camera", "Retro_Orbit_Camera"):
            cams += 1
        got = len(_split_top_level_args(arg_text)) if arg_text.strip() else 0
        want = macros[name]
        if got != want:
            errors.append(f"`{name}` takes {want} arg(s), got {got}: ({arg_text.strip()[:60]})")

    # 5. exactly one hero camera is expected
    if cams == 0:
        warnings.append("no Retro_Camera / Retro_Orbit_Camera — POV will use a default view")
    elif cams > 1:
        warnings.append(f"{cams} cameras defined — the last one wins")

    return {"ok": not errors, "errors": errors, "warnings": warnings,
            "macros_used": sorted(set(used))}


def main(argv):
    if len(argv) < 2:
        print("usage: fd_validate.py scene.pov [--lib DIR]", file=sys.stderr)
        return 2
    lib = DEFAULT_LIB
    if "--lib" in argv:
        lib = argv[argv.index("--lib") + 1]
    src = open(argv[1], encoding="utf-8", errors="replace").read()
    r = validate_scene(src, lib)
    for e in r["errors"]:
        print(f"  ERROR: {e}")
    for w in r["warnings"]:
        print(f"  warn:  {w}")
    print(f"{'OK' if r['ok'] else 'INVALID'} — {argv[1]} "
          f"(macros: {', '.join(r['macros_used']) or 'none'})")
    return 0 if r["ok"] else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
