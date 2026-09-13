import type { APIRoute } from "astro";
import { corsPreflight, json } from "../../../lib/cors";
import { query } from "../../../lib/db";
import { normalizePhone, generateCode, sendOtpSms, isDevMode, devCode, warnIfDevMode } from "../../../lib/otp";

export const prerender = false;

export const OPTIONS: APIRoute = () => corsPreflight();

export const POST: APIRoute = async ({ request }) => {
  warnIfDevMode();

  let body: Record<string, unknown>;
  try {
    body = await request.json();
  } catch {
    return json({ ok: false, error: "Invalid JSON" }, 400);
  }

  const phone = normalizePhone(String(body.phone ?? ""));
  if (!phone) return json({ ok: false, error: "Enter a valid 10-digit phone number." }, 400);

  const code = generateCode();
  const expiresInSec = 300;

  try {
    await query(
      `insert into otp_codes (phone, code, expires_at) values ($1, $2, now() + interval '${expiresInSec} seconds')`,
      [phone, code],
    );
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Could not create OTP";
    return json({ ok: false, error: msg }, 503);
  }

  await sendOtpSms(phone, code);

  const payload: Record<string, unknown> = { ok: true, expiresInSec };
  if (isDevMode()) payload.devCode = devCode();
  return json(payload);
};
