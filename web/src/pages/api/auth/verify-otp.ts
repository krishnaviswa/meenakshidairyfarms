import type { APIRoute } from "astro";
import { corsPreflight, json } from "../../../lib/cors";
import { query } from "../../../lib/db";
import { normalizePhone, isDevMode, devCode } from "../../../lib/otp";
import { signToken } from "../../../lib/auth";

export const prerender = false;

export const OPTIONS: APIRoute = () => corsPreflight();

export const POST: APIRoute = async ({ request }) => {
  let body: Record<string, unknown>;
  try {
    body = await request.json();
  } catch {
    return json({ ok: false, error: "Invalid JSON" }, 400);
  }

  const phone = normalizePhone(String(body.phone ?? ""));
  const code = String(body.code ?? "").trim();
  if (!phone || !code) return json({ ok: false, error: "Phone and code are required." }, 400);

  const usingDevCode = isDevMode() && code === devCode();

  try {
    if (!usingDevCode) {
      const rows = await query<{ id: string }>(
        `select id from otp_codes
          where phone = $1 and code = $2 and consumed_at is null and expires_at > now()
          order by created_at desc
          limit 1`,
        [phone, code],
      );
      if (!rows.length) return json({ ok: false, error: "Incorrect or expired code." }, 400);
      await query(`update otp_codes set consumed_at = now() where id = $1`, [rows[0].id]);
    }

    const existing = await query<{ id: string }>(`select id from users where phone = $1`, [phone]);
    let userId: string;
    if (existing.length) {
      userId = existing[0].id;
      await query(`update users set last_login_at = now() where id = $1`, [userId]);
    } else {
      const inserted = await query<{ id: string }>(
        `insert into users (phone, last_login_at) values ($1, now()) returning id`,
        [phone],
      );
      userId = inserted[0].id;
    }

    const token = signToken({ id: userId, phone });
    return json({ ok: true, token, user: { id: userId, phone } });
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Could not verify code";
    return json({ ok: false, error: msg }, 503);
  }
};
