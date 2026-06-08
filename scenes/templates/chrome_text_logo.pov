// chrome_text_logo.pov — 90s demo-reel chrome extruded text on a checkered
// floor. Generic: just "CHROME" as a stylized title-card hero, the kind
// you'd see on a CD-ROM box or a workstation vendor splash screen.
// Hand-authored. Re-dress-friendly: swap the string, change the chrome tint,
// re-tint the floor.
#include "retro90s.inc"

Retro_Sky_Gradient(rgb <0.10, 0.12, 0.30>, rgb <0.55, 0.70, 1.00>)
Retro_Sun(<-0.4, 0.7, -0.3>, rgb <1.0, 0.95, 0.85>)

// The floor: white-and-cyan checker, like a product-shoot cyc, that recedes
// to a soft horizon and reflects the chrome letters just enough to read
// "premium". (Reflect 0.18 — chrome does the rest.)
Retro_Checker_Floor(rgb <0.92, 0.95, 1.00>, rgb <0.20, 0.32, 0.55>, 0.18)

// "CHROME" — built from rotated boxes so it's deterministic across POV-Ray
// versions and doesn't need a font file. Each letter is ~0.9 units wide, the
// whole word spans ~6 units, the extrusion is 0.5 deep.
#declare LETTER_DEPTH = 0.5;
#macro ChromeBlock(x, y, w, h)
  box { <x, y, 0>, <x+w, y+h, LETTER_DEPTH> }
#end

#declare ChromeWord = union {
  // C
  ChromeBlock(0.0, 0.0, 0.4, 2.4)
  ChromeBlock(0.0, 0.0, 1.6, 0.4)
  ChromeBlock(0.0, 2.0, 1.6, 0.4)
  // H
  ChromeBlock(2.0, 0.0, 0.4, 2.4)
  ChromeBlock(2.0, 1.0, 1.4, 0.4)
  ChromeBlock(3.0, 0.0, 0.4, 2.4)
  // R (simplified: vertical bar + top bar + middle bar, no diagonal leg)
  ChromeBlock(3.8, 0.0, 0.4, 2.4)
  ChromeBlock(3.8, 0.0, 1.4, 0.4)
  ChromeBlock(5.2, 0.0, 0.4, 1.2)
  ChromeBlock(3.8, 1.0, 1.4, 0.4)
  // O
  ChromeBlock(5.6, 0.0, 0.4, 2.4)
  ChromeBlock(5.6, 0.0, 1.4, 0.4)
  ChromeBlock(5.6, 2.0, 1.4, 0.4)
  ChromeBlock(6.6, 0.0, 0.4, 2.4)
  // M
  ChromeBlock(7.4, 0.0, 0.4, 2.4)
  ChromeBlock(8.4, 0.0, 0.4, 2.4)
  ChromeBlock(7.4, 0.0, 1.4, 0.4)
  ChromeBlock(8.4, 0.0, 1.4, 0.4)
  // E
  ChromeBlock(9.2, 0.0, 0.4, 2.4)
  ChromeBlock(9.2, 0.0, 1.6, 0.4)
  ChromeBlock(9.2, 1.0, 1.2, 0.4)
  ChromeBlock(9.2, 2.0, 1.6, 0.4)
  // Center, tilt slightly, raise off the floor
  translate <-4.6, -0.1, 0>
  rotate <0, 0, -2>            // tiny tilt for drama
  translate <0, 1.2, 2>
}

object {
  ChromeWord
  texture { Retro_Chrome(rgb <0.92, 0.95, 1.00>) }
  scale 0.85
}

// A second smaller word, offset and red-chrome, to give the title-card a
// "subhead" — again, re-dress by changing the tint and string.
object {
  ChromeWord
  texture { Retro_Chrome(rgb <0.95, 0.40, 0.20>) }
  scale 0.35
  translate <1.2, -0.8, 4>
}

Retro_Orbit_Camera(9, 3.0, <2, 1.4, 2>)
