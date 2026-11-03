import type { IncomingMessage, ServerResponse } from "node:http";
import { query } from "../db.js";
export async function listUsers(_req: IncomingMessage, res: ServerResponse) {
  const rows = await query("select id, email from users limit 50");
  res.writeHead(200, { "content-type": "application/json" }).end(JSON.stringify(rows));
}
