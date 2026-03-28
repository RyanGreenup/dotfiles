/**
 * CLI for the minuet token usage tracker.
 *
 * Usage:
 *   bun run index.ts                     # all-time summary
 *   bun run index.ts --since 1774686000  # since unix timestamp
 *   bun run index.ts --session           # since current hour (rough session proxy)
 *   bun run index.ts --log /path/to.jsonl
 *   bun run index.ts --input-rate 0.10 --output-rate 0.10  # llama3.1-8b pricing
 *   bun run index.ts --json              # machine-readable output
 */

import { defineCommand, runMain } from "citty";
import { readSessionUsage, formatSummary, DEFAULT_LOG_PATH, DEFAULT_PRICING } from "./tracker.ts";

const main = defineCommand({
  meta: {
    name: "minuet-tracker",
    description: "Show minuet LLM completion token usage and cost",
    version: "1.0.0",
  },
  args: {
    since: {
      description: "Unix timestamp to start counting from (0 = all time)",
      type: "string",
      default: "0",
    },
    session: {
      description: "Scope to the last hour (approximate session)",
      type: "boolean",
      default: false,
    },
    log: {
      description: "Path to the JSONL usage log",
      type: "string",
      default: DEFAULT_LOG_PATH,
    },
    "input-rate": {
      description: "USD per million input tokens",
      type: "string",
      default: String(DEFAULT_PRICING.input),
    },
    "output-rate": {
      description: "USD per million output tokens",
      type: "string",
      default: String(DEFAULT_PRICING.output),
    },
    json: {
      description: "Output as JSON",
      type: "boolean",
      default: false,
    },
  },
  async run({ args }) {
    const since = args.session
      ? Math.floor(Date.now() / 1000) - 3600
      : Number(args.since);

    const pricing = {
      input: Number(args["input-rate"]),
      output: Number(args["output-rate"]),
    };

    const summary = await readSessionUsage(args.log, since, pricing);

    if (args.json) {
      console.log(JSON.stringify(summary, null, 2));
    } else {
      console.log(formatSummary(summary));
    }
  },
});

runMain(main);
