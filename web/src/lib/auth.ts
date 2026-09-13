import jwt from "jsonwebtoken";

export interface AuthUser {
  id: string;
  phone: string;
}

function secret(): string {
  return process.env.JWT_SECRET || "dev-secret";
}

export function signToken(user: AuthUser): string {
  return jwt.sign({ sub: user.id, phone: user.phone }, secret(), { expiresIn: "30d" });
}

/** Never throws — returns null on any missing/invalid/expired token so
 * callers decide what to do (hard 401 on /api/account/*, soft-ignore on
 * /api/orders so guest checkout keeps working).
 */
export function getUserFromRequest(request: Request): AuthUser | null {
  const header = request.headers.get("authorization") || "";
  const match = header.match(/^Bearer\s+(.+)$/i);
  if (!match) return null;
  try {
    const payload = jwt.verify(match[1], secret()) as { sub: string; phone: string };
    if (!payload?.sub || !payload?.phone) return null;
    return { id: payload.sub, phone: payload.phone };
  } catch {
    return null;
  }
}
