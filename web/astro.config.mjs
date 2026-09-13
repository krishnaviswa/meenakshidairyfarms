import { defineConfig } from "astro/config";
import sitemap from "@astrojs/sitemap";
import node from "@astrojs/node";
import { loadEnv } from "vite";

const env = loadEnv(process.env.NODE_ENV || "development", process.cwd(), "");
if (env.DATABASE_URL) process.env.DATABASE_URL = env.DATABASE_URL;
if (env.SITE_URL) process.env.SITE_URL = env.SITE_URL;
if (env.JWT_SECRET) process.env.JWT_SECRET = env.JWT_SECRET;
if (env.OTP_DEV_MODE) process.env.OTP_DEV_MODE = env.OTP_DEV_MODE;

const SITE = process.env.SITE_URL || "https://meenakshidairyfarms.example";

export default defineConfig({
  site: SITE,
  output: "server",
  adapter: node({ mode: "standalone" }),
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
