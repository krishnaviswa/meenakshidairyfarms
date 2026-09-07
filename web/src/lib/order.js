/* Order model shared by the order form. Builds the canonical order object
 * (shared/schema/order.schema.json), the WhatsApp message and the UPI link.
 * Prices are passed in (from products data / Supabase), never hardcoded here.
 */

const PRODUCT_EN = {
  cow: "A2 Cow Milk (Sahiwal breed)",
  buffalo: "A2 Buffalo Milk (Murrah breed)",
};
const FREQ_EN = { daily: "Daily", alt: "Alternate days", once: "One-time" };

export function makeRef() {
  const d = new Date();
  const p = (x) => (x < 10 ? "0" : "") + x;
  const ymd = String(d.getFullYear()).slice(2) + p(d.getMonth() + 1) + p(d.getDate());
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  let s = "";
  for (let i = 0; i < 4; i++) s += chars[Math.floor(Math.random() * chars.length)];
  return "MDF-" + ymd + "-" + s;
}

export function round(n) { return Math.round(n); }

/** rates: { cow: number, buffalo: number } */
export function buildOrder(fields, rates, lang) {
  const cow = clampHalf(fields.qtyCow);
  const buf = clampHalf(fields.qtyBuf);
  const items = [];
  if (cow > 0) items.push({ key: "cow", litres: cow, price_per_litre: rates.cow, amount: round(cow * rates.cow) });
  if (buf > 0) items.push({ key: "buffalo", litres: buf, price_per_litre: rates.buffalo, amount: round(buf * rates.buffalo) });
  const total = items.reduce((s, it) => s + it.amount, 0);
  return {
    ref: makeRef(),
    name: fields.name.trim(),
    phone: fields.phone.trim(),
    address_line1: fields.addr1.trim(),
    area: (fields.area || "").trim(),
    pincode: (fields.pin || "").trim(),
    items,
    total,
    frequency: fields.freq,
    start_date: fields.startdate || undefined,
    notes: (fields.notes || "").trim(),
    channel: "web",
    language: lang,
  };
}

export function clampHalf(v) {
  let n = parseFloat(v);
  if (isNaN(n) || n < 0) n = 0;
  return Math.round(n * 2) / 2;
}

/** English message so the farm processes every order the same way. */
export function orderText(o) {
  const L = [];
  L.push("*New Milk Order — Meenakshi Dairy Farms*");
  L.push("*Order ref:* " + o.ref);
  L.push("");
  L.push("*Name:* " + o.name);
  L.push("*Phone:* " + o.phone);
  L.push("*Address:* " + o.address_line1);
  if (o.area) L.push("*Area / landmark:* " + o.area);
  if (o.pincode) L.push("*Pincode:* " + o.pincode);
  L.push("");
  L.push("*Milk order" + (o.frequency === "once" ? "" : " (per delivery)") + ":*");
  o.items.forEach((it) => {
    L.push("• " + PRODUCT_EN[it.key] + " — " + it.litres + " L × ₹" + it.price_per_litre + " = ₹" + it.amount);
  });
  L.push("*Frequency:* " + FREQ_EN[o.frequency]);
  if (o.start_date) L.push("*Start from:* " + o.start_date);
  L.push("*Estimated total:* ₹" + o.total + (o.frequency === "once" ? "" : " per delivery"));
  if (o.notes) { L.push(""); L.push("*Notes:* " + o.notes); }
  L.push("");
  L.push("_Sent from the Meenakshi order page_");
  return L.join("\n");
}

export function waLink(waNumber, o) {
  return "https://wa.me/" + waNumber + "?text=" + encodeURIComponent(orderText(o));
}

/** withAmount: true only for one-time orders (fixed total is knowable up front). */
export function upiLink(vpa, name, o, withAmount) {
  if (!vpa) return "";
  const q = [
    "pa=" + encodeURIComponent(vpa),
    "pn=" + encodeURIComponent(name || "Meenakshi Dairy Farms"),
    "cu=INR",
    "tn=" + encodeURIComponent("Milk order " + o.ref),
    "tr=" + encodeURIComponent(o.ref),
  ];
  if (withAmount) q.splice(3, 0, "am=" + encodeURIComponent(String(o.total)));
  return "upi://pay?" + q.join("&");
}

export { PRODUCT_EN, FREQ_EN };
