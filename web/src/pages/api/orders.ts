import type { APIRoute } from "astro";
import { getCatalog, ratesFromCatalog } from "../../lib/catalog";
import { corsPreflight, json } from "../../lib/cors";
import { query } from "../../lib/db";
import { buildOrder, waLink } from "../../lib/order.js";

export const prerender = false;

export const OPTIONS: APIRoute = () => corsPreflight();

function asLang(v: unknown): "en" | "hi" | "ta" {
  return v === "hi" || v === "ta" ? v : "en";
}

export const POST: APIRoute = async ({ request }) => {
  let body: Record<string, unknown>;
  try {
    body = await request.json();
  } catch {
    return json({ ok: false, error: "Invalid JSON" }, 400);
  }

  const name = String(body.name ?? "").trim();
  const phone = String(body.phone ?? "").trim();
  const addr1 = String(body.addr1 ?? body.address_line1 ?? "").trim();
  const digits = phone.replace(/\D/g, "");
  if (!name || digits.length < 10 || !addr1) {
    return json({ ok: false, error: "Name, phone and address are required." }, 400);
  }

  const lang = asLang(body.language ?? body.lang);
  const catalog = await getCatalog(lang);
  const rates = ratesFromCatalog(catalog);
  const order = buildOrder(
    {
      name,
      phone,
      addr1,
      area: String(body.area ?? ""),
      pin: String(body.pin ?? body.pincode ?? ""),
      qtyCow: body.qtyCow ?? 0,
      qtyBuf: body.qtyBuf ?? 0,
      freq: body.freq ?? body.frequency ?? "daily",
      startdate: body.startdate ?? body.start_date ?? "",
      notes: String(body.notes ?? ""),
      channel: body.channel === "app" ? "app" : "web",
    },
    rates,
    lang,
  );

  if (!order.items.length) {
    return json({ ok: false, error: "Enter at least 0.5 litre of milk." }, 400);
  }

  try {
    await query(
      `insert into orders
         (ref, name, phone, address_line1, area, pincode, items, total,
          frequency, start_date, notes, channel, language)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)`,
      [
        order.ref,
        order.name,
        order.phone,
        order.address_line1,
        order.area || "",
        order.pincode || "",
        JSON.stringify(order.items),
        order.total,
        order.frequency,
        order.start_date || null,
        order.notes || "",
        order.channel,
        order.language,
      ],
    );
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Could not save order";
    return json({ ok: false, error: msg }, 503);
  }

  return json({
    ok: true,
    order,
    waUrl: waLink(catalog.settings.waNumber, order),
  });
};
