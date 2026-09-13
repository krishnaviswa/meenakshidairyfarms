/** Phone-OTP generation/delivery. One swap point for a real SMS provider
 * (e.g. MSG91) later — neither web nor the Flutter app need to change,
 * they only ever call the /api/auth/* routes.
 */

const DEV_CODE = "000000";

export function isDevMode(): boolean {
  const v = process.env.OTP_DEV_MODE;
  return v === "true" || v === "1";
}

let warnedDevMode = false;
export function warnIfDevMode(): void {
  if (isDevMode() && !warnedDevMode) {
    warnedDevMode = true;
    console.warn(
      "[auth] OTP_DEV_MODE is ON — any phone verifies with " + DEV_CODE + ". Do not deploy this to production.",
    );
  }
}

export function devCode(): string {
  return DEV_CODE;
}

export function generateCode(): string {
  return String(Math.floor(100000 + Math.random() * 900000));
}

/** Normalizes to the same "91XXXXXXXXXX" shape used by site_settings.wa_number. */
export function normalizePhone(raw: string): string | null {
  let digits = String(raw || "").replace(/\D/g, "");
  if (digits.length === 10) digits = "91" + digits;
  if (digits.length !== 12 || !digits.startsWith("91")) return null;
  return digits;
}

/** No SMS provider is wired up yet — this just logs. Replace this function's
 * body with a real provider call (MSG91, Twilio, ...) when one exists.
 */
export async function sendOtpSms(phone: string, code: string): Promise<void> {
  console.log(`[otp] would send code ${code} to +${phone}`);
}
