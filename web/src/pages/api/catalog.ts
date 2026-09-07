import type { APIRoute } from "astro";
import { getCatalog } from "../../lib/catalog";
import { corsPreflight, json } from "../../lib/cors";

export const prerender = false;

export const OPTIONS: APIRoute = () => corsPreflight();

export const GET: APIRoute = async ({ url }) => {
  const lang = (url.searchParams.get("lang") || "en") as "en" | "hi" | "ta";
  const safe = lang === "hi" || lang === "ta" ? lang : "en";
  const catalog = await getCatalog(safe);
  return json(catalog);
};
