import type { APIRoute } from "astro";
import { corsPreflight, json } from "../../../lib/cors";
import { getUserFromRequest } from "../../../lib/auth";

export const prerender = false;

export const OPTIONS: APIRoute = () => corsPreflight();

export const GET: APIRoute = async ({ request }) => {
  const user = getUserFromRequest(request);
  if (!user) return json({ ok: false, error: "Not signed in." }, 401);
  return json({ ok: true, user });
};
