/**
 * Minuet token usage tracker.
 *
 * Reads the JSONL log written by `scripts/minuet-curl` and computes
 * session-scoped token counts and costs. Each log line is a JSON object:
 *
 *   {"ts": <unix_seconds>, "prompt": <n>, "completion": <n>, "total": <n>}
 *
 * The tracker filters lines by a start timestamp so callers can scope
 * to the current Neovim session or any arbitrary time window.
 */

/** A single usage record from the JSONL log. */
export interface UsageEntry {
  ts: number;
  prompt: number;
  completion: number;
  total: number;
}

/** Per-million-token pricing in USD. */
export interface Pricing {
  input: number;
  output: number;
}

/** Aggregated usage and cost for a session. */
export interface SessionSummary {
  requests: number;
  promptTokens: number;
  completionTokens: number;
  totalTokens: number;
  inputCost: number;
  outputCost: number;
  totalCost: number;
}

/** Default log path, matches the bash wrapper's default. */
export const DEFAULT_LOG_PATH = "/tmp/minuet-usage.jsonl";

/** Default pricing for Cerebras qwen-3-235b (USD per million tokens). */
export const DEFAULT_PRICING: Pricing = { input: 0.6, output: 1.2 };

/**
 * Parse a single JSONL line into a UsageEntry.
 * Returns null if the line is empty or malformed.
 */
export function parseEntry(line: string): UsageEntry | null {
  const trimmed = line.trim();
  if (!trimmed) return null;
  try {
    const obj = JSON.parse(trimmed) as Record<string, unknown>;
    if (typeof obj.ts !== "number" || typeof obj.total !== "number") return null;
    return {
      ts: obj.ts as number,
      prompt: (obj.prompt as number) ?? 0,
      completion: (obj.completion as number) ?? 0,
      total: (obj.total as number) ?? 0,
    };
  } catch {
    return null;
  }
}

/**
 * Calculate cost in USD for a given token count and per-million rate.
 */
export function tokenCost(tokens: number, perMillion: number): number {
  return (tokens / 1_000_000) * perMillion;
}

/**
 * Read the usage log and aggregate entries since `since` (unix seconds).
 * Pass `since = 0` to include all entries.
 */
export async function readSessionUsage(
  logPath: string = DEFAULT_LOG_PATH,
  since: number = 0,
  pricing: Pricing = DEFAULT_PRICING,
): Promise<SessionSummary> {
  const file = Bun.file(logPath);
  if (!(await file.exists())) {
    return { requests: 0, promptTokens: 0, completionTokens: 0, totalTokens: 0, inputCost: 0, outputCost: 0, totalCost: 0 };
  }

  const text = await file.text();
  const lines = text.split("\n");

  let promptTokens = 0;
  let completionTokens = 0;
  let totalTokens = 0;
  let requests = 0;

  for (const line of lines) {
    const entry = parseEntry(line);
    if (!entry || entry.ts < since) continue;
    promptTokens += entry.prompt;
    completionTokens += entry.completion;
    totalTokens += entry.total;
    requests++;
  }

  const inputCost = tokenCost(promptTokens, pricing.input);
  const outputCost = tokenCost(completionTokens, pricing.output);

  return {
    requests,
    promptTokens,
    completionTokens,
    totalTokens,
    inputCost,
    outputCost,
    totalCost: inputCost + outputCost,
  };
}

/**
 * Format a SessionSummary as a human-readable single-line string.
 */
export function formatSummary(s: SessionSummary): string {
  return `${s.requests} requests | ${s.promptTokens} in / ${s.completionTokens} out tokens | $${s.totalCost.toFixed(4)} ($${s.inputCost.toFixed(4)} in + $${s.outputCost.toFixed(4)} out)`;
}
