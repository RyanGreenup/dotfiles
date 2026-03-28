/**
 * SQLite database for minuet token usage tracking.
 *
 * Schema:
 *   - `model_pricing`: per-million-token rates for each model.
 *   - `usage`:         one row per API request with token counts.
 *   - `v_usage_cost`:  view joining usage with pricing to compute per-request cost.
 *
 * The `setup()` function is idempotent: call it on every startup and it will
 * create tables/views only if they don't already exist, then seed default
 * pricing rows without duplicating them.
 */

import { Database } from "bun:sqlite";
import { join } from "node:path";

/** Default database path: ~/.local/share/minuet/usage.db */
export const DEFAULT_DB_PATH = join(
  process.env["XDG_DATA_HOME"] ?? join(process.env["HOME"] ?? "/tmp", ".local/share"),
  "minuet",
  "usage.db",
);

/**
 * Open (or create) the database at the given path and run idempotent setup.
 * Safe to call on every invocation.
 */
function createTables(db: Database): void {
  db.run(`
    CREATE TABLE IF NOT EXISTS model_pricing (
      model         TEXT PRIMARY KEY,
      provider      TEXT NOT NULL,
      input_per_m   REAL NOT NULL,
      output_per_m  REAL NOT NULL,
      updated_at    TEXT NOT NULL DEFAULT (datetime('now'))
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS usage (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      ts              INTEGER NOT NULL,
      model           TEXT NOT NULL,
      prompt_tokens   INTEGER NOT NULL DEFAULT 0,
      completion_tokens INTEGER NOT NULL DEFAULT 0,
      total_tokens    INTEGER NOT NULL DEFAULT 0
    )
  `);

  db.run(`CREATE INDEX IF NOT EXISTS idx_usage_ts ON usage(ts)`);
}

function createCostView(db: Database): void {
  db.run(`
    CREATE VIEW IF NOT EXISTS v_usage_cost AS
    SELECT
      u.id,
      u.ts,
      u.model,
      u.prompt_tokens,
      u.completion_tokens,
      u.total_tokens,
      p.input_per_m,
      p.output_per_m,
      (u.prompt_tokens / 1000000.0) * COALESCE(p.input_per_m, 0)  AS input_cost,
      (u.completion_tokens / 1000000.0) * COALESCE(p.output_per_m, 0) AS output_cost,
      (u.prompt_tokens / 1000000.0) * COALESCE(p.input_per_m, 0)
        + (u.completion_tokens / 1000000.0) * COALESCE(p.output_per_m, 0) AS total_cost
    FROM usage u
    LEFT JOIN model_pricing p ON u.model = p.model
  `);
}

function seedPricing(db: Database): void {
  const stmt = db.query(`
    INSERT OR IGNORE INTO model_pricing (model, provider, input_per_m, output_per_m)
    VALUES ($model, $provider, $input, $output)
  `);

  stmt.run({
    $model: "qwen-3-235b-a22b-instruct-2507",
    $provider: "cerebras",
    $input: 0.6,
    $output: 1.2,
  });
  stmt.run({ $model: "llama3.1-8b", $provider: "cerebras", $input: 0.1, $output: 0.1 });
  stmt.run({ $model: "gpt-oss-120b", $provider: "cerebras", $input: 0.35, $output: 0.75 });
  stmt.run({ $model: "gpt-4.1-mini", $provider: "openai", $input: 0.4, $output: 1.6 });
}

export function openDb(dbPath = DEFAULT_DB_PATH): Database {
  const dir = dbPath.slice(0, dbPath.lastIndexOf("/"));
  Bun.spawnSync(["mkdir", "-p", dir]);

  const db = new Database(dbPath);
  db.run("PRAGMA journal_mode = WAL");
  db.run("PRAGMA foreign_keys = ON");

  createTables(db);
  createCostView(db);
  seedPricing(db);
  return db;
}
