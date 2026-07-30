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
run time, so this never drifts from the library. Macros the scene defines for
itself are harvested from the scene the same way: defining a local helper is a
style warning (scenes should compose), not a parse error, so calls to it are
checked against its own signature instead of being reported as invented.

    ./fd_validate.py scene.pov            # exit 0 = ok, 1 = errors
    validate_scene(source, lib_dir)       # -> {ok, errors, warnings, macros_used}
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_LIB = os.path.join(HERE, "lib")

_OPEN = {"(": ")", "[": "]", "{": "}"}
_CLOSE = {v: k for k, v in _OPEN.items()}

# `#macro Name(a, b)` — the parameter list may span lines (skeleton.inc does).
_MACRO_DEF = re.compile(r"#macro\s+([A-Za-z_]\w*)\s*\(([^)]*)\)")
_DECLARE = re.compile(r"#(declare|local)\s+([A-Za-z_]\w*)")

# POV-Ray keywords cannot be re-declared: `#macro Orb(x, y, r)` or
# `#local radius = 2;` is a fatal parse error ("Expected 'undeclared
# identifier', radius found instead"), not a shadowed name. Every word below
# was verified against POV-Ray 3.7.0.10 by actually parsing a scene that uses
# it as a macro parameter; the real keyword list is longer, so this catches the
# names a scene author (or a 3B model) is likely to reach for, not all of them.
_RESERVED = frozenset("""
t u v x y z pi clock
alpha ambient angle brightness color colour count density diffuse direction
distance emission end filter finish floor frequency gamma green blue red
interior inverse ior jitter location look_at material matrix max metallic min
no normal off offset on orientation pattern phase pigment radius ratio
reflection right rotate roughness scale seed size sky specular spacing
strength target text texture thickness transmit translate true false turbulence
type up val width wood yes
""".split())

# Object modifiers. Legal on an object, fatal inside a texture{} block
# ("No matching } in 'texture', no_shadow found instead") — all verified.
_OBJECT_ONLY = ("no_shadow", "no_image", "no_reflection", "double_illuminate",
                "inverse", "hollow", "clipped_by", "bounded_by")


def _scan(src: str, keep_strings: bool = False) -> str:
    """One pass over the source honouring both comments and string literals.

    Comments and strings must be recognised together, not in two independent
    regex passes: `"art//grid.png"` is a string that merely looks like it holds
    a comment, and stripping comments first would eat the closing quote, after
    which the orphaned quote swallows an arbitrary span of the scene (every
    macro call inside it silently unchecked, braces inside it uncounted).

    Comments collapse to a space. Strings collapse to `""` unless keep_strings.
    An unterminated string stops at the end of its line — POV-Ray strings do
    not span lines, so a stray quote costs one line, not the rest of the file.
    """
    out, i, n = [], 0, len(src)
    while i < n:
        c = src[i]
        if c == "/" and i + 1 < n and src[i + 1] == "*":
            end = src.find("*/", i + 2)
            i = n if end == -1 else end + 2
            out.append(" ")
        elif c == "/" and i + 1 < n and src[i + 1] == "/":
            end = src.find("\n", i)
            i = n if end == -1 else end          # keep the newline itself
            out.append(" ")
        elif c == '"':
            j = i + 1
            while j < n and src[j] not in ('"', "\n"):
                j += 2 if src[j] == "\\" else 1
            closed = j < n and src[j] == '"'
            j = j + 1 if closed else j
            out.append(src[i:j] if keep_strings else '""')
            i = j
        else:
            out.append(c)
            i += 1
    return "".join(out)


def strip_noise(src: str) -> str:
    """Remove // and /* */ comments and "double-quoted strings" so brace/paren
    scanning and macro detection never trip over text inside them."""
    return _scan(src)


def strip_comments(src: str) -> str:
    """Remove comments but keep string literals (for #include detection)."""
    return _scan(src, keep_strings=True)


def _macro_defs(text: str) -> dict:
    """Return {macro_name: (param_names, position)} for every #macro in text."""
    defs = {}
    for m in _MACRO_DEF.finditer(text):
        name, args = m.group(1), m.group(2).strip()
        params = tuple(a.strip() for a in args.split(",")) if args else ()
        defs[name] = (params, m.start(1))
    return defs


def _blocks(src: str, keyword: str):
    """Yield the body text of every `keyword { ... }` block, braces matched."""
    for m in re.finditer(r"\b" + keyword + r"\s*\{", src):
        i, depth, j, n = m.end() - 1, 0, m.end() - 1, len(src)
        while j < n:
            if src[j] == "{":
                depth += 1
            elif src[j] == "}":
                depth -= 1
                if depth == 0:
                    yield src[i + 1:j]
                    break
            j += 1


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
        for name, (params, _pos) in _macro_defs(text).items():
            macros[name] = len(params)
    return macros


def _split_top_level_args(inner: str):
    """Split a macro call's argument text on TOP-LEVEL commas only — commas
    inside <vectors>, nested (calls), {blocks} or [arrays] do not separate args.

    POV-Ray spells comparisons with the same characters it uses for vectors, so
    `<`/`>` get their own counter: a `>` closes nothing unless a `<` is actually
    open, which keeps `select(clock>0.5, a, b)` from closing the `(` around it.
    If a `<` is still open at the end it was a less-than, so the text is split
    again with angle brackets treated as ordinary characters."""
    def split(use_angles):
        args, depth, angle, cur = [], 0, 0, []
        for ch in inner:
            if ch in _OPEN:
                depth += 1
            elif ch in _CLOSE:
                depth = max(0, depth - 1)
            elif use_angles and ch == "<":
                angle += 1
            elif use_angles and ch == ">" and angle:
                angle -= 1
            if ch == "," and depth == 0 and angle == 0:
                args.append("".join(cur))
                cur = []
            else:
                cur.append(ch)
        tail = "".join(cur).strip()
        if tail or args:
            args.append(tail)
        return [a.strip() for a in args], angle

    args, angle = split(True)
    if angle:
        args, _ = split(False)
    return args


def _find_calls(src: str):
    """Yield (name, arg_text, ok_balanced, position) for every `Identifier( ... )`
    whose name starts with an uppercase letter (library macros are Capitalized;
    POV built-ins are lowercase). Uses balanced-paren matching to grab the arg
    text."""
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
                    yield name, src[i + 1:j], True, m.start(1)
                    break
            j += 1
        else:
            yield name, src[i + 1:], False, m.start(1)


def validate_scene(source: str, lib_dir: str = DEFAULT_LIB) -> dict:
    macros = harvest_macros(lib_dir)
    errors, warnings, used = [], [], []
    clean = strip_noise(source)

    # 1. must pull in the library — and a commented-out #include does not count
    if '#include "retro90s.inc"' not in strip_comments(source):
        errors.append('missing `#include "retro90s.inc"` (the library must be '
                      'pulled in before any Retro_* macro)')

    # 2. the scene must not redefine library macros; its own helpers are legal
    #    (a style warning) and become part of the contract for step 4
    local, def_sites = {}, set()
    for name, (params, pos) in _macro_defs(clean).items():
        def_sites.add(pos)
        if name in macros:
            errors.append(f"redefines library macro `{name}` (forbidden)")
        else:
            warnings.append(f"defines its own macro `{name}` (scenes should compose, not define)")
            local[name] = len(params)
        for p in params:
            if p in _RESERVED:
                errors.append(f"`{name}` names a parameter `{p}`, which is a POV-Ray "
                              f"keyword — POV-Ray cannot declare it and refuses the scene")
    known = dict(macros)
    known.update(local)

    # 2b. same trap for #declare/#local names
    for m in _DECLARE.finditer(clean):
        if m.group(2) in _RESERVED:
            errors.append(f"`#{m.group(1)} {m.group(2)}` — `{m.group(2)}` is a POV-Ray "
                          f"keyword and cannot be declared")

    # 3. balanced braces/parens overall (catch truncated output)
    for op, name in ((("{", "}"), "braces"), (("(", ")"), "parens")):
        if clean.count(op[0]) != clean.count(op[1]):
            errors.append(f"unbalanced {name}: {clean.count(op[0])} `{op[0]}` vs {clean.count(op[1])} `{op[1]}`")

    # 4. every Capitalized(...) call must be a known macro with the right arity
    cams = 0
    for name, arg_text, balanced, pos in _find_calls(clean):
        if pos in def_sites:      # the #macro line itself is a definition
            continue
        if not balanced:
            errors.append(f"`{name}(` is never closed (truncated scene?)")
            continue
        if name not in known:
            errors.append(f"unknown macro `{name}` — not defined in lib/*.inc "
                          f"and not defined in this scene")
            continue
        used.append(name)
        if name in ("Retro_Camera", "Retro_Orbit_Camera"):
            cams += 1
        got = len(_split_top_level_args(arg_text)) if arg_text.strip() else 0
        want = known[name]
        if got != want:
            where = "" if name in macros else " (defined in this scene)"
            errors.append(f"`{name}`{where} takes {want} arg(s), got {got}: ({arg_text.strip()[:60]})")

    # 5. texture{} blocks: the material macros already ARE a texture, and object
    #    modifiers belong on the object, not inside its texture
    for body in _blocks(clean, "texture"):
        m = re.match(r"\s*(Retro_(?:Chrome|Glass|Plastic))\s*\(", body)
        if m:
            errors.append(f"`{m.group(1)}(...)` is wrapped in `texture{{ }}` — the macro "
                          f"already expands to a full texture block, so POV-Ray reports "
                          f"`No matching }} in 'texture'`. Apply it directly in the object.")
        for kw in _OBJECT_ONLY:
            if re.search(r"\b" + kw + r"\b", body):
                errors.append(f"`{kw}` is inside a `texture{{ }}` block — it is an object "
                              f"modifier and POV-Ray stops there. Move it out to the object.")
    for body in _blocks(clean, "material"):
        m = re.match(r"\s*(Retro_(?:Chrome|Glass|Plastic))\s*\(", body)
        if m:
            errors.append(f"`{m.group(1)}(...)` is wrapped in `material{{ }}` — the macro "
                          f"already expands to a full texture block")

    # 6. exactly one hero camera is expected
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
