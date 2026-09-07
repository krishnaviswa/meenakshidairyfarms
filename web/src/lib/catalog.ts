import type { Lang } from "../i18n";
import { query } from "./db";
import { products as fallbackProducts, WA_NUMBER, CONTACT_EMAIL } from "../data/products";

export interface CatalogProduct {
  key: "cow" | "buffalo";
  name: string;
  breed: string;
  tagline: string;
  bullets: string[];
  pricePerLitre: number;
  pricePerHalfLitre: number;
}

export interface SiteSettings {
  waNumber: string;
  contactEmail: string;
  upiVpa: string;
  upiName: string;
}

export interface Catalog {
  products: CatalogProduct[];
  usps: string[];
  settings: SiteSettings;
  fromDb: boolean;
}

const FALLBACK_USPS: Record<Lang, string[]> = {
  en: [
    "Naturally grazed on green fodder",
    "Direct from our farm — no middlemen",
    "Ethical and humane animal care",
    "Freshly milked and handled hygienically",
    "Regular quality testing for purity and safety",
    "Supports local farmers and sustainable farming",
    "Cold chain from farm to your home",
    "Trusted by hundreds of families",
  ],
  hi: [
    "हरे चारे पर चरते हैं",
    "सीधे हमारे फार्म से — कोई बिचौलिया नहीं",
    "नैतिक और दयालु पशु देखभाल",
    "रोज़ दुहा, साफ़-सुथरे तरीके से संभाला",
    "शुद्धता और सुरक्षा के लिए नियमित जाँच",
    "स्थानीय किसानों और टिकाऊ खेती का साथ",
    "फार्म से आपके घर तक कोल्ड चेन",
    "सैकड़ों परिवारों का भरोसा",
  ],
  ta: [
    "பசுந்தீவனத்தில் இயற்கையாக மேய்கின்றன",
    "எங்கள் பண்ணையிலிருந்து நேரடி — இடைத்தரகர் இல்லை",
    "நெறிமுறை, அன்பான கால்நடைப் பராமரிப்பு",
    "தினமும் கறந்து சுகாதாரமாக கையாளப்படுகிறது",
    "தூய்மை மற்றும் பாதுகாப்புக்கு வழக்கமான தரச் சோதனை",
    "உள்ளூர் விவசாயிகளுக்கும் நிலையான வேளாண்மைக்கும் ஆதரவு",
    "பண்ணையிலிருந்து உங்கள் வீடு வரை குளிர்ச்சங்கிலி",
    "நூற்றுக்கணக்கான குடும்பங்களின் நம்பிக்கை",
  ],
};

function pickLang<T extends Record<string, string>>(row: T, lang: Lang, base: string): string {
  return (row[`${base}_${lang}` as keyof T] as string) || (row[`${base}_en` as keyof T] as string) || "";
}

function bulletsFor(raw: unknown, lang: Lang): string[] {
  if (!raw || typeof raw !== "object") return [];
  const bag = raw as Record<string, string[]>;
  return bag[lang] ?? bag.en ?? [];
}

function fallbackCatalog(lang: Lang): Catalog {
  return {
    fromDb: false,
    products: fallbackProducts.map((p) => ({
      key: p.key,
      name: p.name[lang],
      breed: p.breed[lang],
      tagline: p.tagline[lang],
      bullets: p.bullets[lang],
      pricePerLitre: p.pricePerLitre,
      pricePerHalfLitre: p.pricePerHalfLitre,
    })),
    usps: FALLBACK_USPS[lang],
    settings: {
      waNumber: WA_NUMBER,
      contactEmail: CONTACT_EMAIL,
      upiVpa: "",
      upiName: "Meenakshi Dairy Farms",
    },
  };
}

export async function getCatalog(lang: Lang): Promise<Catalog> {
  try {
    const [productRows, uspRows, settingRows] = await Promise.all([
      query<{
        key: "cow" | "buffalo";
        name_en: string; name_hi: string; name_ta: string;
        breed_en: string; breed_hi: string; breed_ta: string;
        tagline_en: string; tagline_hi: string; tagline_ta: string;
        bullets: unknown;
        price_per_litre: string;
        price_per_half_litre: string;
      }>(
        `select key, name_en, name_hi, name_ta, breed_en, breed_hi, breed_ta,
                tagline_en, tagline_hi, tagline_ta, bullets,
                price_per_litre, price_per_half_litre
           from products
          where active = true
          order by sort`,
      ),
      query<{ title_en: string; title_hi: string; title_ta: string }>(
        `select title_en, title_hi, title_ta from usps order by sort`,
      ),
      query<{ key: string; value: string }>(`select key, value from site_settings`),
    ]);

    if (!productRows.length) return fallbackCatalog(lang);

    const settingsMap = Object.fromEntries(settingRows.map((r) => [r.key, r.value]));
    return {
      fromDb: true,
      products: productRows.map((r) => ({
        key: r.key,
        name: pickLang(r, lang, "name"),
        breed: pickLang(r, lang, "breed"),
        tagline: pickLang(r, lang, "tagline"),
        bullets: bulletsFor(r.bullets, lang),
        pricePerLitre: Number(r.price_per_litre),
        pricePerHalfLitre: Number(r.price_per_half_litre),
      })),
      usps: uspRows.map((r) => pickLang(r, lang, "title")),
      settings: {
        waNumber: settingsMap.wa_number || WA_NUMBER,
        contactEmail: settingsMap.contact_email || CONTACT_EMAIL,
        upiVpa: settingsMap.upi_vpa || "",
        upiName: settingsMap.upi_name || "Meenakshi Dairy Farms",
      },
    };
  } catch (err) {
    console.warn("[catalog] using fallback —", err instanceof Error ? err.message : err);
    return fallbackCatalog(lang);
  }
}

export function ratesFromCatalog(catalog: Catalog): { cow: number; buffalo: number } {
  const cow = catalog.products.find((p) => p.key === "cow");
  const buffalo = catalog.products.find((p) => p.key === "buffalo");
  return {
    cow: cow?.pricePerLitre ?? 80,
    buffalo: buffalo?.pricePerLitre ?? 90,
  };
}

export function formatInr(n: number): string {
  return "₹" + Math.round(n).toLocaleString("en-IN");
}

/** 919087282939 → "90872 82939" for display. Never invent a number. */
export function displayPhone(waNumber: string): string {
  const digits = waNumber.replace(/\D/g, "").replace(/^91/, "");
  if (digits.length === 10) return `${digits.slice(0, 5)} ${digits.slice(5)}`;
  return digits;
}
