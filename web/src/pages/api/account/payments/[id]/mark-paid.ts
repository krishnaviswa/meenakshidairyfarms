import type { APIRoute } from "astro";
import { corsPreflight, json } from "../../../../../lib/cors";
import { query } from "../../../../../lib/db";
import { getUserFromRequest } from "../../../../../lib/auth";

export const prerender = false;

export const OPTIONS: APIRoute = () => corsPreflight();

export const POST: APIRoute = async ({ request, params }) => {
  const user = getUserFromRequest(request);
  if (!user) return json({ ok: false, error: "Not signed in." }, 401);

  const id = params.id;
  const rows = await query<{ id: string; status: string }>(
    `update payments
        set status = 'paid_self_reported', self_reported_at = now()
      where id = $1 and user_id = $2 and status = 'due'
      returning id, status`,
    [id, user.id],
  );

  if (!rows.length) {
    return json({ ok: false, error: "Payment not found or already marked paid." }, 404);
  }

  return json({ ok: true, payment: rows[0] });
};
