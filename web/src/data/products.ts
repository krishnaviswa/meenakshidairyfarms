// Build-time fallback for product info. In Phase 2 this is replaced by a fetch
// from Supabase `products` + `site_settings`. Keep the shape identical.
//
// ⚠ Prices are placeholders — confirm with the owner (see supabase/seed.sql).

import type { Lang } from "../i18n";

export interface Product {
  key: "cow" | "buffalo";
  name: Record<Lang, string>;
  breed: Record<Lang, string>;
  pricePerLitre: number;
}

export const products: Product[] = [
  {
    key: "cow",
    name: { en: "A2 Cow Milk", hi: "A2 गाय का दूध", ta: "A2 பசும் பால்" },
    breed: { en: "Sahiwal breed", hi: "साहीवाल नस्ल", ta: "சிவால் இனம்" },
    pricePerLitre: 85,
  },
  {
    key: "buffalo",
    name: { en: "A2 Buffalo Milk", hi: "A2 भैंस का दूध", ta: "A2 எருமை பால்" },
    breed: { en: "Murrah breed", hi: "मुर्रा नस्ल", ta: "முர்ரா இனம்" },
    pricePerLitre: 90,
  },
];

export const byKey = (k: "cow" | "buffalo") => products.find((p) => p.key === k)!;

// WhatsApp number lives only here + in Supabase site_settings — never rendered as text.
export const WA_NUMBER = "919791836836";
