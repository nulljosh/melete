# Melete brand kit and design system

Melete is the Muse of thought and practice, one of the three first Muses. Her name means "thinking about something". The app is a feed of ideas worth thinking about, so she holds the lamp.

## The mark
A Greek oil lamp with its flame lit: the light you think by. One bold flat white glyph on a laurel gradient tile. No text, no outline, no emblem.

- `../Melete.icon` is the source of truth (Icon Composer), copied into `ios/` and `macos/`. Light and dark fills are set in it.
- `../icon.svg` is the flat copy for READMEs (80 px) and the web. `icon-1024.png` is the App Store icon, no alpha.
- `mark.svg` is the glyph alone in `currentColor`, for the nav and footer.
- It must read at 29 px: the body, the nozzle and the flame.

## The figure
The landing's hero is a 19th-century wood engraving of a Muse deep in thought, finger to her lips, crowned with laurel (public domain, Wikimedia Commons, "Polyhymnia - the Greek muse"). It is traced to vector in `../melete.svg` and its plinth reads MELETE. Rays turn slowly behind her. Three crops of it make the footer tiles.

## Colour
| Role | Light | Dark |
|---|---|---|
| Accent (buttons, links, your vote, the icon) | `#4d7c45` laurel | `#8fc286` |
| Icon gradient | `#6f9a62` to `#3b6334` | |
| Field (landing hero, download band) | `#1f2b1d` | `#1f2b1d` |
| On field | `#eef3ea`, soft `#a9c3a1` | |
| Paper (page) | `#fafaf8` | `#1c1a17` |
| Card | `#ffffff` | `#26231f` |
| Hairline | `#e4e2dc` | `#35312b` |
| Ink (text) | `#1c1a17` | `#f3ede0` |
| On accent | `#ffffff` | `#1c1a17` |

Warm neutrals and one laurel green. Never brown, beige, purple or teal, and no second accent.

## Type
- Headlines on the landing: the system serif, `ui-serif, "New York", "Iowan Old Style", Georgia`. Large and light, tracked at -0.03em. Nothing is bundled.
- Everything else, and everything in the apps: the system font, `-apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", Helvetica, Arial, sans-serif`. Scale 34/41, 22/28, 17/24, 15/20, 13/18.

## Space and shape
- 8 point grid: 4, 8, 12, 16, 24, 32, 48. Side margin 20 (16 on phones). Reading column 680.
- Radii: cards 16, list rows 12, controls fully round, icon 22 percent.
- Controls are 48 point capsules. Focus is a 4 point ring at 30 percent accent.
- Motion is 0.2 to 0.4 s and honours reduced motion.

## Voice
Short, plain, a little classical. Say what it does: a new idea every morning, vote, see what is already on the App Store, build the one nobody has. No em dashes, no hype.

`tokens.css` holds the accent, the field and the display face. Everything else comes from the shared token file.
