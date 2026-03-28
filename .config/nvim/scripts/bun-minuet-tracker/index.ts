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

import { defineCommand, runMain } from "citty";
import { openDb, DEFAULT_DB_PATH } from "./db.ts";
import { querySince, queryToday, formatSummary, formatCard } from "./tracker.ts";

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
      default: false,
    },
    all: {
      description: "Show all-time usage",
      type: "boolean",
      default: false,
    },
    db: {
      description: "Path to the SQLite database",
      type: "string",
      default: DEFAULT_DB_PATH,
    },
    json: {
      description: "Output as JSON",
      type: "boolean",
      default: false,
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
      // Default: session (last hour) + today
      const hour = Math.floor(Date.now() / 1000) - 3600;
      const session = querySince(db, hour);
      const today = queryToday(db);

      if (args.json) {
        console.log(JSON.stringify({ session, today }, null, 2));
      } else {
        console.log(formatCard(session, today));
      }
    }

    db.close();
  },
});

function print(label: string, summary: ReturnType<typeof querySince>, json: boolean): void {
  if (json) {
    console.log(JSON.stringify({ [label]: summary }, null, 2));
  } else {
    console.log(formatSummary(label, summary));
  }
}

runMain(main);
