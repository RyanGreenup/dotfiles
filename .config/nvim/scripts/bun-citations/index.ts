import { type Format, processDoi, processUrl } from "./lib";
import { defineCommand, runMain } from "citty";
import { $ } from "bun";

async function clipboardUrl(): Promise<string> {
  const text = await $`wl-paste --no-newline`.quiet().text();
  return text.trim();
}

const main = defineCommand({
  meta: {
    description: "Add a URL citation to a references file",
    name: "cite",
    version: "1.0.0",
  },
  args: {
    url: {
      description: "URL to cite (defaults to clipboard)",
      required: false,
      type: "positional",
    },
    dir: {
      default: ".",
      description: "Target directory for output file",
      type: "string",
    },
    doi: {
      description: "DOI to cite directly (instead of a URL)",
      required: false,
      type: "string",
    },
    bib: {
      default: false,
      description: "Output BibTeX (.bib) instead of CSL-JSON (.json)",
      type: "boolean",
    },
  },
  async run({ args }) {
    const format: Format = args.bib ? "bibtex" : "csl-json";
    if (args.doi) {
      await processDoi(args.doi, args.dir, format);
    } else {
      const raw = args.url || (await clipboardUrl());
      await processUrl(raw, args.dir, format);
    }
  },
});

runMain(main);
