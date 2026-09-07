// Copy the canonical translation files from ../shared/i18n into src/i18n so Astro
// can import them without reaching outside the web/ project root.
import { copyFileSync, mkdirSync, existsSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const shared = resolve(here, "../../shared/i18n");
const dest = resolve(here, "../src/i18n");
mkdirSync(dest, { recursive: true });

for (const loc of ["en", "hi", "ta"]) {
  const from = resolve(shared, `${loc}.json`);
  if (!existsSync(from)) {
    console.error(`missing ${from}`);
    process.exit(1);
  }
  copyFileSync(from, resolve(dest, `${loc}.json`));
  console.log(`i18n: ${loc}.json`);
}
