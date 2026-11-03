import pg from "pg";
import { logger } from "./logger.js";
const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });
export async function query<T>(sql: string, params: unknown[] = []): Promise<T[]> {
  const t = Date.now();
  const r = await pool.query(sql, params);
  logger.info("db query", { sql, ms: Date.now() - t, rows: r.rowCount });
  return r.rows as T[];
}
