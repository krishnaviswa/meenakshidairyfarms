# Meenakshi Dairy Farms — brand tokens

Single source for colours, type and voice. The website (`web/src/styles`) and the
Flutter app (`app/lib/theme`) both derive their theme from this file.

## Colour

### Light (default)

| Token | Hex | Use |
|---|---|---|
| `cream` | `#FBF8F2` | page background |
| `cream-card` | `#FFFFFF` | cards, raised surfaces |
| `cream-sunk` | `#F3EBE0` | sunken panels, input fill |
| `forest` | `#3A2718` | cocoa headings, primary text accents, dark buttons |
| `leaf` | `#C45C26` | terracotta primary action and links |
| `leaf-bright` | `#D46A32` | hover / active on terracotta |
| `gold` | `#C4A35A` | secondary accent, borders, rules |
| `ink` | `#2C241C` | body text |
| `muted` | `#75695D` | secondary text |
| `line` | `#E7DCCB` | borders, dividers |
| `danger` | `#A6392B` | errors, required marks |
| `btn-text` | `#FFFAF4` | text on `leaf` / `forest` |

### Dark

| Token | Hex |
|---|---|
| `cream` | `#16110E` |
| `cream-card` | `#201914` |
| `cream-sunk` | `#1B1511` |
| `forest` | `#F4E7D8` |
| `leaf` | `#D66B34` |
| `leaf-bright` | `#E37B43` |
| `gold` | `#D6B66F` |
| `ink` | `#F5EEE7` |
| `muted` | `#B9AA9C` |
| `line` | `#3D3027` |
| `danger` | `#E0796A` |
| `btn-text` | `#FFFAF4` |

Theme resolution: explicit `data-theme="dark|light"` on `:root` wins; otherwise
follow `prefers-color-scheme`. Persist the user's choice in `localStorage`
(`meenakshi_theme`).

Shadows use warm cocoa-tinted low-opacity values, never green-tinted shadows.

## Type

| Role | Family | Notes |
|---|---|---|
| Display / headings | **Fraunces** (opsz 9–144, wght 400/600/700) | serif, `letter-spacing: -.01em`, `text-wrap: balance` |
| Body / UI | **Mulish** (400/500/600/700) | |
| Tamil | **Noto Sans Tamil** (400/500/700) | always in the fallback stack |
| Devanagari | **Noto Sans Devanagari** (400/500/700) | always in the fallback stack |

Full stacks:
- headings: `"Fraunces","Noto Sans Tamil","Noto Sans Devanagari",Georgia,serif`
- body: `"Mulish","Noto Sans Tamil","Noto Sans Devanagari",system-ui,-apple-system,"Segoe UI",Roboto,sans-serif`

For `hi` / `ta` locales: drop Latin-style `text-transform: uppercase` and
`letter-spacing` on eyebrows, labels and small-caps elements.

Base body: 16px / 1.55. Content width: `max-width: 580px` on the order/account
flows; marketing pages may go wider (up to ~1080px) with sections centred.

## Logo / wordmark

Text wordmark: **"Meenakshi Dairy Farms"** in Fraunces 700, `forest`; the tagline
line under it in Fraunces 600, `gold`, at `.5em`.

## Voice

- Warm, plain, specific. "From our farm to your family."
- Confident about what is true (pure, undiluted, A2, BCM-7 free, farm-raised, daily
  fresh, naturally high protein & calcium in buffalo milk).
- **No disease claims.** No "prevents / cures / treats". No puberty claims. A2 is
  described as *easier to digest for people sensitive to A1 milk* — nothing more.
- Numbers with ranges, not false precision ("~7% fat", not "7.00%").

## Taglines

- EN: *Good milk · Healthy families · A better tomorrow*
- HI: *अच्छा दूध · स्वस्थ परिवार · बेहतर कल*
- TA: *நல்ல பால் · ஆரோக்கியமான குடும்பங்கள் · சிறந்த நாளை*
