import type { APIRoute } from "astro";
import { corsPreflight, json } from "../../../lib/cors";
import { query } from "../../../lib/db";
import { getUserFromRequest } from "../../../lib/auth";

export const prerender = false;

export const OPTIONS: APIRoute = () => corsPreflight();

export const GET: APIRoute = async ({ request }) => {
  const user = getUserFromRequest(request);
  if (!user) return json({ ok: false, error: "Not signed in." }, 401);

  const payments = await query(
    `select p.id, p.amount, p.status, p.self_reported_at, p.created_at, o.ref as order_ref
       from payments p
       left join orders o on o.id = p.order_id
      where p.user_id = $1
      order by p.created_at desc`,
    [user.id],
  );

  return json({ ok: true, payments });
};
