import type { APIRoute } from "astro";
import { corsPreflight, json } from "../../../lib/cors";
import { query } from "../../../lib/db";
import { getUserFromRequest } from "../../../lib/auth";

export const prerender = false;

export const OPTIONS: APIRoute = () => corsPreflight();

export const GET: APIRoute = async ({ request }) => {
  const user = getUserFromRequest(request);
  if (!user) return json({ ok: false, error: "Not signed in." }, 401);

  const orders = await query(
    `select ref, items, total, frequency, start_date, notes, channel, language, status, created_at
       from orders
      where user_id = $1
      order by created_at desc`,
    [user.id],
  );

  return json({ ok: true, orders });
};
