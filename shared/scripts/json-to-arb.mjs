// shared/i18n/{en,hi,ta}.json  →  app/lib/l10n/app_{en,hi,ta}.arb
//
// Flatten nested keys with '_' and turn arrays into indexed keys so Flutter's
// gen-l10n can consume them. Run from the repo root:  node shared/scripts/json-to-arb.mjs
//
// This is a lossy convenience: arrays of objects (home.ages, home.how, faq.items,
// *.facts) are flattened to  section_key_0_field  etc. The Flutter side reads
// them back into typed lists.

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const locales = ["en", "hi", "ta"];

function flatten(obj, prefix, out) {
  for (const [k, v] of Object.entries(obj)) {
    const key = prefix ? `${prefix}_${k}` : k;
    if (Array.isArray(v)) {
      v.forEach((item, i) => {
        if (item && typeof item === "object") flatten(item, `${key}_${i}`, out);
        else out[`${key}_${i}`] = String(item);
      });
    } else if (v && typeof v === "object") {
      flatten(v, key, out);
    } else {
      out[key] = String(v);
    }
  }
}

for (const loc of locales) {
  const src = JSON.parse(readFileSync(resolve(root, `shared/i18n/${loc}.json`), "utf8"));
  const flat = {};
  flatten(src, "", flat);

  const arb = { "@@locale": loc };
  for (const [k, val] of Object.entries(flat)) arb[k] = val;

  const outPath = resolve(root, `app/lib/l10n/app_${loc}.arb`);
  mkdirSync(dirname(outPath), { recursive: true });
  writeFileSync(outPath, JSON.stringify(arb, null, 2) + "\n", "utf8");
  console.log(`wrote ${outPath}  (${Object.keys(flat).length} keys)`);
}
