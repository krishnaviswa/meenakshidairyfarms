# Meenakshi Dairy Farms — brand tokens

Single source for colours, type and voice. The website (`web/src/styles`) and the
Flutter app (`app/lib/theme`) both derive their theme from this file.

## Colour

### Light (default)

| Token | Hex | Use |
|---|---|---|
| `cream` | `#F5EFE0` | page background |
| `cream-card` | `#FDFBF3` | cards, raised surfaces |
| `cream-sunk` | `#EFE7D3` | sunken panels, input fill |
| `forest` | `#1E4A2B` | headings, primary text accents, dark buttons |
| `leaf` | `#3C7D45` | primary action, links |
| `leaf-bright` | `#4E9A54` | hover / active on leaf |
| `gold` | `#BE8F35` | secondary accent, dashed borders, rules |
| `ink` | `#2A2A22` | body text |
| `muted` | `#6E6A5A` | secondary text |
| `line` | `#DCD2B9` | borders, dividers |
| `danger` | `#A6392B` | errors, required marks |
| `btn-text` | `#FFFDF6` | text on `leaf` / `forest` |

### Dark

| Token | Hex |
|---|---|
| `cream` | `#101C15` |
| `cream-card` | `#17271C` |
| `cream-sunk` | `#12211A` |
| `forest` | `#DDEAD7` |
| `leaf` | `#58A55E` |
| `leaf-bright` | `#6DBE72` |
| `gold` | `#D9B267` |
| `ink` | `#ECEFE4` |
| `muted` | `#9AA893` |
| `line` | `#2C3E30` |
| `danger` | `#E0796A` |
| `btn-text` | `#0E1A12` |

Theme resolution: explicit `data-theme="dark|light"` on `:root` wins; otherwise
follow `prefers-color-scheme`. Persist the user's choice in `localStorage`
(`meenakshi_theme`).

Shadows: `--shadow: 0 10px 34px -14px rgba(30,55,31,.34)` ·
`--shadow-sm: 0 4px 14px -8px rgba(30,55,31,.3)`.

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
