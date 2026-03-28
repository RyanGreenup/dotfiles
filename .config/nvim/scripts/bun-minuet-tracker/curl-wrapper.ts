#!/usr/bin/env bun
/**
 * Native fetch-based drop-in replacement for curl, used as minuet's `curl_cmd`.
 *
 * Minuet passes curl-style args: -L -H "Key: val" --max-time N -d @file URL.
 * This script parses those args, makes the request with fetch(), writes the
 * response to stdout for plenary.job to read, and logs token usage to SQLite.
 *
 * No shell commands or child processes are spawned.
 */

import { openDb, DEFAULT_DB_PATH } from "./db.ts";

const model = process.env["MINUET_MODEL"] ?? "unknown";
const dbPath = process.env["MINUET_DB_PATH"] ?? DEFAULT_DB_PATH;

/** Parse minuet's curl-style arguments into fetch parameters. */
function parseArgs(argv: string[]): {
  url: string;
  headers: Record<string, string>;
  body: string | null;
  timeoutMs: number;
} {
  const args = argv.slice(2); // skip bun + script path
  const headers: Record<string, string> = {};
  let bodyFile: string | null = null;
  let timeoutMs = 15_000;
  let url = "";

  for (let i = 0; i < args.length; i++) {
    const arg = args[i]!;

    if (arg === "-H" && i + 1 < args.length) {
      const header = args[++i]!;
      const colon = header.indexOf(":");
      if (colon > 0) {
        headers[header.slice(0, colon).trim()] = header.slice(colon + 1).trim();
      }
    } else if (arg === "--max-time" && i + 1 < args.length) {
      timeoutMs = Number(args[++i]) * 1000;
    } else if (arg === "-d" && i + 1 < args.length) {
      const data = args[++i]!;
      bodyFile = data.startsWith("@") ? data.slice(1) : null;
    } else if (arg === "-L" || arg === "-s" || arg === "--compressed") {
      // Flags we accept but don't need to act on (fetch follows redirects by default)
    } else if (arg === "--proxy" && i + 1 < args.length) {
      i++; // skip proxy value; fetch doesn't support it natively
    } else if (!arg.startsWith("-")) {
      url = arg;
    }
  }

  let body: string | null = null;
  if (bodyFile) {
    body = require("fs").readFileSync(bodyFile, "utf-8");
  }

  return { url, headers, body, timeoutMs };
}

/** Extract token counts from response text via regex. */
function extractUsage(text: string): { prompt: number; completion: number; total: number } | null {
  const totalMatch = text.match(/"total_tokens":(\d+)/);
  if (!totalMatch) return null;
  return {
    prompt: Number(text.match(/"prompt_tokens":(\d+)/)?.[1] ?? 0),
    completion: Number(text.match(/"completion_tokens":(\d+)/)?.[1] ?? 0),
    total: Number(totalMatch[1]),
  };
}

/** Record usage to SQLite. Fails silently to never break completions. */
function recordUsage(usage: { prompt: number; completion: number; total: number }): void {
  try {
    const db = openDb(dbPath);
    db.run(
      "INSERT INTO usage (ts, model, prompt_tokens, completion_tokens, total_tokens) VALUES (?, ?, ?, ?, ?)",
      [Math.floor(Date.now() / 1000), model, usage.prompt, usage.completion, usage.total],
    );
    db.close();
  } catch {
    // Silent: logging must never interfere with the completion response
  }
}

// --- Main ---

const { url, headers, body, timeoutMs } = parseArgs(process.argv);

if (!url) {
  process.exit(1);
}

try {
  const response = await fetch(url, {
    method: body ? "POST" : "GET",
    headers,
    body,
    signal: AbortSignal.timeout(timeoutMs),
    redirect: "follow",
  });

  const text = await response.text();
  await Bun.write(Bun.stdout, text);

  const usage = extractUsage(text);
  if (usage) {
    recordUsage(usage);
  }
} catch {
  process.exit(1);
}
