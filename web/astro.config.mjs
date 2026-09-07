import { defineConfig } from "astro/config";
import sitemap from "@astrojs/sitemap";

// Set this to the real domain before deploying (used for sitemap + canonical URLs).
const SITE = process.env.SITE_URL || "https://meenakshidairyfarms.example";

export default defineConfig({
  site: SITE,
  i18n: {
    defaultLocale: "en",
    locales: ["en", "hi", "ta"],
    routing: { prefixDefaultLocale: false },
  },
  integrations: [
    sitemap({
      i18n: {
        defaultLocale: "en",
        locales: { en: "en", hi: "hi", ta: "ta" },
      },
    }),
  ],
  devToolbar: { enabled: false },
});
