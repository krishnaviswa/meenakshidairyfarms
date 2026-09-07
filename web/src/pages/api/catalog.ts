import type { APIRoute } from "astro";
import { getCatalog } from "../../lib/catalog";

export const prerender = false;

export const GET: APIRoute = async ({ url }) => {
  const lang = (url.searchParams.get("lang") || "en") as "en" | "hi" | "ta";
  const safe = lang === "hi" || lang === "ta" ? lang : "en";
  const catalog = await getCatalog(safe);
  return new Response(JSON.stringify(catalog), {
    headers: { "Content-Type": "application/json; charset=utf-8" },
  });
};
