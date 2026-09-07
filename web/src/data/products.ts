// Build-time / offline fallback. Live prices come from Postgres (`products`).
// Flyer: ₹40 cow / ₹45 buffalo per half litre.

import type { Lang } from "../i18n";

export interface Product {
  key: "cow" | "buffalo";
  name: Record<Lang, string>;
  breed: Record<Lang, string>;
  tagline: Record<Lang, string>;
  bullets: Record<Lang, string[]>;
  pricePerLitre: number;
  pricePerHalfLitre: number;
}

export const products: Product[] = [
  {
    key: "cow",
    name: { en: "A2 Cow Milk", hi: "A2 गाय का दूध", ta: "A2 பசும் பால்" },
    breed: { en: "Sahiwal breed", hi: "साहीवाल नस्ल", ta: "சிவால் இனம்" },
    tagline: {
      en: "Light & gentle for everyday wellness",
      hi: "रोज़ की सेहत के लिए हल्का और सौम्य",
      ta: "தினசரி நலனுக்கு இலகுவான, மென்மையான பால்",
    },
    bullets: {
      en: ["From Sahiwal breed", "Easy to digest", "Rich in calcium & nutrients", "100% natural & unprocessed"],
      hi: ["साहीवाल नस्ल से", "पचने में आसान", "कैल्शियम और पोषक तत्वों से भरपूर", "100% प्राकृतिक, बिना प्रोसेस"],
      ta: ["சிவால் இனத்திலிருந்து", "செரிமானத்திற்கு எளிது", "கால்சியம் மற்றும் ஊட்டச்சத்து நிறைந்தது", "100% இயற்கை, பதப்படுத்தப்படாதது"],
    },
    pricePerLitre: 80,
    pricePerHalfLitre: 40,
  },
  {
    key: "buffalo",
    name: { en: "A2 Buffalo Milk", hi: "A2 भैंस का दूध", ta: "A2 எருமை பால்" },
    breed: { en: "Murrah breed", hi: "मुर्रा नस्ल", ta: "முர்ரா இனம்" },
    tagline: {
      en: "Rich & nourishing for a stronger you",
      hi: "मज़बूती के लिए गाढ़ा और पोषक",
      ta: "வலுவான உடலுக்கு சத்தான, நிறைவான பால்",
    },
    bullets: {
      en: ["From Murrah breed", "Naturally rich in fat & minerals", "Great taste & energy", "100% natural & unprocessed"],
      hi: ["मुर्रा नस्ल से", "स्वाभाविक रूप से वसा और खनिजों से भरपूर", "स्वाद और ऊर्जा", "100% प्राकृतिक, बिना प्रोसेस"],
      ta: ["முர்ரா இனத்திலிருந்து", "இயற்கையாகவே கொழுப்பு மற்றும் கனிமங்கள் நிறைந்தது", "சுவையும் சக்தியும்", "100% இயற்கை, பதப்படுத்தப்படாதது"],
    },
    pricePerLitre: 90,
    pricePerHalfLitre: 45,
  },
];

export const byKey = (k: "cow" | "buffalo") => products.find((p) => p.key === k)!;

// WhatsApp digits only — used in wa.me links. Matches the current flyer / order HTML.
export const WA_NUMBER = "919087282939";
export const CONTACT_EMAIL = "meenakshidairyfarms@gmail.com";
