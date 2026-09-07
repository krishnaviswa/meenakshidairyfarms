// Edge Function: notify the farm when a new order row is inserted.
//
// Wire it up as a Database Webhook:
//   Supabase Dashboard ▸ Database ▸ Webhooks ▸ Create
//     table: orders   events: INSERT
//     type: Supabase Edge Function   ▸ on-order-created
//
// Secrets (Dashboard ▸ Edge Functions ▸ Manage secrets):
//   NOTIFY_EMAIL       where order emails go (e.g. the farm's inbox)
//   RESEND_API_KEY     https://resend.com  (free tier: 100 emails/day) — or swap for any SMTP/API
//   RESEND_FROM        verified sender, e.g. "orders@meenakshidairyfarms.com"
//   GOOGLE_SHEET_URL   optional — the legacy Apps Script /exec URL, for parallel logging during cutover

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

interface OrderRow {
  ref: string; name: string; phone: string;
  address_line1: string; area: string; pincode: string;
  items: { key: string; litres: number; price_per_litre: number; amount: number }[];
  total: number; frequency: string; start_date: string | null;
  notes: string; channel: string; language: string;
}

const NOTIFY_EMAIL    = Deno.env.get("NOTIFY_EMAIL") ?? "";
const RESEND_API_KEY  = Deno.env.get("RESEND_API_KEY") ?? "";
const RESEND_FROM     = Deno.env.get("RESEND_FROM") ?? "";
const GOOGLE_SHEET_URL = Deno.env.get("GOOGLE_SHEET_URL") ?? "";

const FREQ: Record<string, string> = { daily: "Daily", alt: "Alternate days", once: "One-time" };
const NAME: Record<string, string> = { cow: "A2 Cow Milk (Sahiwal)", buffalo: "A2 Buffalo Milk (Murrah)" };

function orderEmailBody(o: OrderRow): string {
  const lines = o.items.map(
    (it) => `  • ${NAME[it.key] ?? it.key} — ${it.litres} L × ₹${it.price_per_litre} = ₹${it.amount}`,
  );
  const recurring = o.frequency !== "once";
  return [
    `Ref:      ${o.ref}`,
    `Channel:  ${o.channel}`,
    ``,
    `Name:     ${o.name}`,
    `Phone:    ${o.phone}`,
    `Address:  ${o.address_line1}`,
    `Area:     ${o.area || "-"}`,
    `Pincode:  ${o.pincode || "-"}`,
    ``,
    `Milk order${recurring ? " (per delivery)" : ""}:`,
    ...lines,
    `TOTAL:    ₹${o.total}${recurring ? " per delivery" : ""}`,
    ``,
    `Frequency:  ${FREQ[o.frequency] ?? o.frequency}`,
    `Start from: ${o.start_date ?? "-"}`,
    `Notes:      ${o.notes || "-"}`,
    `Language:   ${o.language}`,
  ].join("\n");
}

async function sendEmail(o: OrderRow) {
  if (!NOTIFY_EMAIL || !RESEND_API_KEY || !RESEND_FROM) return;
  const recurring = o.frequency !== "once";
  await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${RESEND_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: RESEND_FROM,
      to: NOTIFY_EMAIL,
      subject: `New milk order — ${o.name} (₹${o.total}${recurring ? " / delivery" : ""})`,
      text: orderEmailBody(o),
    }),
  }).catch((e) => console.error("email failed", e));
}

async function mirrorToSheet(o: OrderRow) {
  if (!GOOGLE_SHEET_URL) return;
  const cow = o.items.find((i) => i.key === "cow");
  const buf = o.items.find((i) => i.key === "buffalo");
  await fetch(GOOGLE_SHEET_URL, {
    method: "POST",
    headers: { "Content-Type": "text/plain;charset=utf-8" },
    body: JSON.stringify({
      ref: o.ref, name: o.name, phone: o.phone,
      address: o.address_line1, area: o.area, pincode: o.pincode,
      cow_litres: cow?.litres ?? 0, cow_amount: cow?.amount ?? 0,
      buffalo_litres: buf?.litres ?? 0, buffalo_amount: buf?.amount ?? 0,
      total_amount: o.total,
      frequency: FREQ[o.frequency] ?? o.frequency,
      start_date: o.start_date ?? "", notes: o.notes, language: o.language,
    }),
  }).catch((e) => console.error("sheet mirror failed", e));
}

serve(async (req) => {
  try {
    const payload = await req.json();
    const o: OrderRow = payload.record ?? payload;      // webhook wraps the row in { record }
    if (!o?.ref) return new Response("no order", { status: 400 });
    await Promise.all([sendEmail(o), mirrorToSheet(o)]);
    return new Response(JSON.stringify({ ok: true }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error(err);
    return new Response(JSON.stringify({ ok: false, error: String(err) }), {
      status: 500, headers: { "Content-Type": "application/json" },
    });
  }
});
