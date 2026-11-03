import type { IncomingMessage, ServerResponse } from "node:http";
import { query } from "../db.js";
import { logger } from "../logger.js";
export async function listOrders(_req: IncomingMessage, res: ServerResponse) {
  const rows = await query("select * from orders order by created_at desc limit 50");
  res.writeHead(200, { "content-type": "application/json" }).end(JSON.stringify(rows));
}
export async function createOrder(req: IncomingMessage, res: ServerResponse) {
  let body = ""; for await (const c of req) body += c;
  const { sku, qty } = JSON.parse(body);
  const [o] = await query("insert into orders (sku, qty) values ($1, $2) returning *", [sku, qty]);
  logger.info("order created", { id: (o as { id: string }).id });
  res.writeHead(201, { "content-type": "application/json" }).end(JSON.stringify(o));
}
