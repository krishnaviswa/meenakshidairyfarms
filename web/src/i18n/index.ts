import en from "./en.json";
import hi from "./hi.json";
import ta from "./ta.json";

export type Lang = "en" | "hi" | "ta";

export const LANGS: Lang[] = ["en", "hi", "ta"];
export const DEFAULT_LANG: Lang = "en";

export const dicts: Record<Lang, any> = { en, hi, ta };

export const langName: Record<Lang, string> = {
  en: "English",
  hi: "हिंदी",
  ta: "தமிழ்",
};

/** Short label for the language switcher pills. */
export const langShort: Record<Lang, string> = {
  en: "EN",
  hi: "हिं",
  ta: "த",
};

function dig(obj: any, path: string): any {
  return path.split(".").reduce((o, k) => (o == null ? undefined : o[k]), obj);
}

/** Translation getter. Falls back to English, then to the key itself. */
export function useT(lang: Lang) {
  const primary = dicts[lang] ?? dicts.en;
  return function t(path: string): any {
    const v = dig(primary, path);
    if (v !== undefined) return v;
    const f = dig(dicts.en, path);
    return f !== undefined ? f : path;
  };
}

/** Turn a canonical path ("/our-milk") into the localized one ("/ta/our-milk"). */
export function localizePath(path: string, lang: Lang): string {
  const clean = path === "" ? "/" : path.startsWith("/") ? path : `/${path}`;
  if (lang === DEFAULT_LANG) return clean;
  return clean === "/" ? `/${lang}/` : `/${lang}${clean}`;
}

/** Strip a leading /hi or /ta from a URL pathname → the canonical path. */
export function canonicalPath(pathname: string): string {
  const m = pathname.match(/^\/(hi|ta)(\/.*)?$/);
  if (m) return m[2] && m[2] !== "/" ? m[2] : "/";
  return pathname || "/";
}

export function langFromPathname(pathname: string): Lang {
  const m = pathname.match(/^\/(hi|ta)(\/|$)/);
  return m ? (m[1] as Lang) : DEFAULT_LANG;
}

/** Nav items in canonical-path form; labels come from t("nav.*"). */
export const NAV: { key: string; path: string }[] = [
  { key: "home", path: "/" },
  { key: "ourMilk", path: "/our-milk" },
  { key: "ourFarm", path: "/our-farm" },
  { key: "faq", path: "/faq" },
  { key: "order", path: "/order" },
];
