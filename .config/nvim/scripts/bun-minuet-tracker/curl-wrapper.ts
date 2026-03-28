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

import { DEFAULT_DB_PATH, openDb } from "./db.ts";
import { readFileSync } from "node:fs";

const model = process.env["MINUET_MODEL"] ?? "unknown";
const dbPath = process.env["MINUET_DB_PATH"] ?? DEFAULT_DB_PATH;

interface ParsedArgs {
  url: string;
  headers: Record<string, string>;
  body: string | undefined;
  timeoutMs: number;
}

interface TokenUsage {
  prompt: number;
  completion: number;
  total: number;
}

function parseHeader(raw: string, headers: Record<string, string>): void {
  const colon = raw.indexOf(":");
  if (colon > 0) {
    headers[raw.slice(0, colon).trim()] = raw.slice(colon + 1).trim();
  }
}

function parseBodyArg(value: string): string | undefined {
  if (!value.startsWith("@")) {
    return undefined;
  }
  return readFileSync(value.slice(1), "utf8");
}

type ArgIter = IterableIterator<string>;
type FlagHandler = (iter: ArgIter, state: ParsedArgs) => void;

const IGNORED_FLAGS = new Set(["-L", "-s", "--compressed"]);

const FLAG_HANDLERS: Record<string, FlagHandler> = {
  "-H": (iter, state) => parseHeader(iter.next().value ?? "", state.headers),
  "--max-time": (iter, state) => {
    state.timeoutMs = Number(iter.next().value) * 1000;
  },
  "-d": (iter, state) => {
    state.body = parseBodyArg(iter.next().value ?? "");
  },
  "--proxy": (iter) => {
    iter.next();
  },
};

/** Parse minuet's curl-style arguments into fetch parameters. */
function parseArgs(argv: string[]): ParsedArgs {
  const raw = argv.slice(2);
  const state: ParsedArgs = { url: "", headers: {}, body: undefined, timeoutMs: 15_000 };
  const iter = raw[Symbol.iterator]();

  for (const arg of iter) {
    const handler = FLAG_HANDLERS[arg];
    if (handler) {
      handler(iter, state);
    } else if (!IGNORED_FLAGS.has(arg) && !arg.startsWith("-")) {
      state.url = arg;
    }
  }

  return state;
}

function matchTokenField(text: string, field: string): number {
  return Number(text.match(new RegExp(`"${field}":(\\d+)`))?.[1] ?? 0);
}

/** Extract token counts from response text via regex. */
function extractUsage(text: string): TokenUsage | undefined {
  const total = matchTokenField(text, "total_tokens");
  if (total === 0) {
    return undefined;
  }
  return {
    prompt: matchTokenField(text, "prompt_tokens"),
    completion: matchTokenField(text, "completion_tokens"),
    total,
  };
}

/** Record usage to SQLite. Fails silently to never break completions. */
function recordUsage(usage: TokenUsage): void {
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
