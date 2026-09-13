import { createHash } from "node:crypto";
import { copyFile, mkdir, readFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const sharedDir = join(dirname(fileURLToPath(import.meta.url)), "assets", "images");
const rootDir = join(sharedDir, "..", "..", "..");
const destinations = [
  join(rootDir, "web", "public", "images"),
  join(rootDir, "app", "assets", "images"),
];
const files = [
  "hero-natural.webp",
  "sahiwal-natural.webp",
  "murrah-natural.webp",
];

const digest = (bytes) => createHash("sha256").update(bytes).digest("hex");

for (const destination of destinations) {
  await mkdir(destination, { recursive: true });
  for (const file of files) {
    const source = join(sharedDir, file);
    const target = join(destination, file);
    await copyFile(source, target);

    const [sourceBytes, targetBytes] = await Promise.all([
      readFile(source),
      readFile(target),
    ]);
    if (digest(sourceBytes) !== digest(targetBytes)) {
      throw new Error(`Visual asset sync failed for ${target}`);
    }
  }
}

console.log(`Visual assets synced: ${files.join(", ")}`);
