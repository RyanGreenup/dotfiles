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
export function openDb(dbPath: string = DEFAULT_DB_PATH): Database {
  // Ensure parent directory exists
  const dir = dbPath.slice(0, dbPath.lastIndexOf("/"));
  Bun.spawnSync(["mkdir", "-p", dir]);

  const db = new Database(dbPath);
  db.run("PRAGMA journal_mode = WAL");
  db.run("PRAGMA foreign_keys = ON");

  setup(db);
  return db;
}

/**
 * Idempotent schema setup. Creates tables, views, and seeds default pricing.
 * Running this multiple times is a no-op.
 */
function setup(db: Database): void {
  db.run(`
    CREATE TABLE IF NOT EXISTS model_pricing (
      model         TEXT PRIMARY KEY,
      provider      TEXT NOT NULL,
      input_per_m   REAL NOT NULL,  -- USD per million input tokens
      output_per_m  REAL NOT NULL,  -- USD per million output tokens
      updated_at    TEXT NOT NULL DEFAULT (datetime('now'))
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS usage (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      ts              INTEGER NOT NULL,  -- unix seconds
      model           TEXT NOT NULL,
      prompt_tokens   INTEGER NOT NULL DEFAULT 0,
      completion_tokens INTEGER NOT NULL DEFAULT 0,
      total_tokens    INTEGER NOT NULL DEFAULT 0
    )
  `);

  // Index for time-range queries (session, daily)
  db.run(`CREATE INDEX IF NOT EXISTS idx_usage_ts ON usage(ts)`);

  // View: each usage row joined with its model's pricing to compute cost.
  // If a model has no pricing row, cost columns are NULL.
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

  // Seed default pricing (INSERT OR IGNORE = idempotent)
  // TODO: add pricing for other models as we add providers:
  //   - openai gpt-4.1-mini
  //   - cerebras llama3.1-8b
  //   - codestral / deepseek for FIM
  const seedPricing = db.query(`
    INSERT OR IGNORE INTO model_pricing (model, provider, input_per_m, output_per_m)
    VALUES ($model, $provider, $input, $output)
  `);

  seedPricing.run({ $model: "qwen-3-235b-a22b-instruct-2507", $provider: "cerebras", $input: 0.60, $output: 1.20 });
  seedPricing.run({ $model: "llama3.1-8b", $provider: "cerebras", $input: 0.10, $output: 0.10 });
  seedPricing.run({ $model: "gpt-oss-120b", $provider: "cerebras", $input: 0.35, $output: 0.75 });
  seedPricing.run({ $model: "gpt-4.1-mini", $provider: "openai", $input: 0.40, $output: 1.60 });
}
