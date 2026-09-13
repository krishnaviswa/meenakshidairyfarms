import { Pool, type QueryResultRow } from "pg";

let pool: Pool | null = null;

export function getPool(): Pool | null {
  const connectionString =
    (import.meta.env.DATABASE_URL as string | undefined) || process.env.DATABASE_URL;
  if (!connectionString) return null;
  if (!pool) {
    pool = new Pool({
      connectionString,
      max: 5,
      idleTimeoutMillis: 10_000,
    });
    // Without this, an idle client error (e.g. the DB restarting) is an
    // unhandled 'error' event and crashes the whole Node process.
    pool.on("error", (err) => {
      console.warn("[db] idle client error —", err instanceof Error ? err.message : err);
    });
  }
  return pool;
}

export async function query<T extends QueryResultRow = QueryResultRow>(
  text: string,
  params?: unknown[],
): Promise<T[]> {
  const p = getPool();
  if (!p) throw new Error("DATABASE_URL is not set");
  const res = await p.query<T>(text, params);
  return res.rows;
}
