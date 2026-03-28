/**
 * Minuet token usage tracker backed by SQLite.
 *
 * Queries aggregate token counts and costs from the `v_usage_cost` view,
 * scoped by time range (session, daily, all-time). Rows are inserted by
 * `curl-wrapper.ts` at request time, so this module is read-only.
 */

import type { Database } from "bun:sqlite";

/** Aggregated usage and cost returned by query functions. */
export interface UsageSummary {
  requests: number;
  promptTokens: number;
  completionTokens: number;
  totalTokens: number;
  inputCost: number;
  outputCost: number;
  totalCost: number;
}

/**
 * Query usage aggregated since `since` (unix seconds).
 * Costs are computed by the `v_usage_cost` view using the `model_pricing` table.
 */
export function querySince(db: Database, since: number = 0): UsageSummary {
  const row = db.query(`
    SELECT
      COUNT(*)                                AS requests,
      COALESCE(SUM(prompt_tokens), 0)         AS promptTokens,
      COALESCE(SUM(completion_tokens), 0)     AS completionTokens,
      COALESCE(SUM(total_tokens), 0)          AS totalTokens,
      COALESCE(SUM(input_cost), 0)            AS inputCost,
      COALESCE(SUM(output_cost), 0)           AS outputCost,
      COALESCE(SUM(total_cost), 0)            AS totalCost
    FROM v_usage_cost
    WHERE ts >= $since
  `).get({ $since: since }) as UsageSummary | undefined;

  return row ?? { requests: 0, promptTokens: 0, completionTokens: 0, totalTokens: 0, inputCost: 0, outputCost: 0, totalCost: 0 };
}

/**
 * Query usage for today (since midnight UTC).
 */
export function queryToday(db: Database): UsageSummary {
  const now = new Date();
  const midnightUtc = Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()) / 1000;
  return querySince(db, midnightUtc);
}

/**
 * Format a single section (session/today/all-time) as two lines.
 */
function formatSection(icon: string, label: string, s: UsageSummary, last: boolean): string {
  const branch = last ? "╰─" : "├─";
  const pipe = last ? "  " : "│ ";
  const cost = `$${s.totalCost.toFixed(4)}`;
  return `${branch} ${icon} ${label}: ${cost}\n${pipe}  ${s.requests} reqs  ⬇ ${s.promptTokens}  ⬆ ${s.completionTokens}`;
}

/**
 * Format a full display card with session and today summaries.
 */
export function formatCard(session: UsageSummary, today: UsageSummary): string {
  const lines = [
    "   🎵 minuet",
    formatSection("🕐", "session", session, false),
    formatSection("📅", "today", today, true),
  ];
  return lines.join("\n");
}

/**
 * Format a single summary with label (for --today, --all, etc.).
 */
export function formatSummary(label: string, s: UsageSummary): string {
  const cost = `$${s.totalCost.toFixed(4)}`;
  return `🎵 minuet\n   ${label}: ${cost}\n   ${s.requests} reqs  ⬇ ${s.promptTokens}  ⬆ ${s.completionTokens}`;
}
