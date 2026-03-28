/**
 * CLI for the minuet token usage tracker.
 *
 * Reads directly from the SQLite database populated by `curl-wrapper.ts`.
 *
 * Usage:
 *   bun run index.ts                     # session (last hour) + today
 *   bun run index.ts --since 1774686000  # since unix timestamp
 *   bun run index.ts --today             # today only
 *   bun run index.ts --all               # all time
 *   bun run index.ts --json              # machine-readable output
 */

import { DEFAULT_DB_PATH, openDb } from "./db.ts";
import { defineCommand, runMain } from "citty";
import { formatCard, formatSummary, querySince, queryToday } from "./tracker.ts";

function print(
  label: string,
  summary: ReturnType<typeof querySince>,
  json: boolean | undefined,
): void {
  if (json) {
    console.log(JSON.stringify({ [label]: summary }, undefined, 2));
  } else {
    console.log(formatSummary(label, summary));
  }
}

function printDefault(db: ReturnType<typeof openDb>, json: boolean | undefined): void {
  const hour = Math.floor(Date.now() / 1000) - 3600;
  const session = querySince(db, hour);
  const today = queryToday(db);

  if (json) {
    console.log(JSON.stringify({ session, today }, undefined, 2));
  } else {
    console.log(formatCard(session, today));
  }
}

const main = defineCommand({
  meta: {
    name: "minuet-tracker",
    description: "Show minuet LLM completion token usage and cost",
    version: "3.0.0",
  },
  args: {
    since: {
      description: "Unix timestamp to start counting from",
      type: "string",
    },
    today: {
      description: "Show today's usage only",
      type: "boolean",
    },
    all: {
      description: "Show all-time usage",
      type: "boolean",
    },
    db: {
      description: "Path to the SQLite database",
      type: "string",
      default: DEFAULT_DB_PATH,
    },
    json: {
      description: "Output as JSON",
      type: "boolean",
    },
  },
  run({ args }) {
    const db = openDb(args.db);

    if (args.all) {
      print("all-time", querySince(db, 0), args.json);
    } else if (args.today) {
      print("today", queryToday(db), args.json);
    } else if (args.since) {
      print("session", querySince(db, Number(args.since)), args.json);
    } else {
      printDefault(db, args.json);
    }

    db.close();
  },
});

runMain(main);
