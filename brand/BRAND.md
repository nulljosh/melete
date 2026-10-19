# Thinkpond brand kit and design system

A brain resting on a lily pad: the pond that thinks

## The mark
One bold flat white glyph on an accent gradient tile. No text, no outline, no emblem.

- `../Thinkpond.icon` is the source of truth (Icon Composer). Light and dark fills are set in it.
- `../icon.svg` is the flat copy for READMEs (shown at 80 px). `icon-1024.png` is the App Store icon, no alpha.
- `mark.svg` is the glyph alone in `currentColor` for your own background.
- Clear space equal to the width of the glyph's thickest stroke. Smallest size 16 px.

## Colour
| Role | Light | Dark |
|---|---|---|
| Accent (buttons, links, your vote) | `#4d7c45` | `#8fc286` |
| Paper (page) | `#fafaf8` | `#1c1a17` |
| Card | `#ffffff` | `#26231f` |
| Hairline | `#e4e2dc` | `#35312b` |
| Ink (text) | `#1c1a17` | `#f3ede0` |
| On accent | `#ffffff` | `#1c1a17` |

Warm neutrals, one green. The accent is for actions, links, your own vote and the icon. Never brown, beige, purple or teal, and no second accent.

## Voice
"Drop an idea in. Watch it ripple." Short, plain, a little playful about the pond. Say what it does: a new idea every morning, a build brief in seconds, the good ones float up.

## Motion
The splash drops the brain onto the pad and the pond ripples once (1.8 s). Everything else is 0.2 to 0.4 s springs. Reduced motion gets still frames.

## Type
The system font: `-apple-system, BlinkMacSystemFont, "SF Pro Text", Lato, "Helvetica Neue", Helvetica, Arial, sans-serif`. Scale 34/41 bold, 22/28, 17/24, 15/20, 13/18.

## Space and shape
- Space on the 8 point grid: 4, 8, 12, 16, 24, 32, 48. Side margin 20. Reading column 680.
- Radii: cards 16, list rows 12, controls fully round, icon 22 percent.
- Controls are 48 points tall capsules, one height in a row. Focus is a 4 point ring at 30 percent accent.
- Motion is 0.2 s ease and honours reduced motion.

`tokens.css` holds the app's accent. Everything else comes from the shared token file.
