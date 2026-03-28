import { defineCommand, runMain } from "citty";
import { generateLink } from "./link.ts";
import { moveMarkdownFile } from "./move.ts";

const move = defineCommand({
  meta: { name: "move", description: "Move a markdown file and update links" },
  args: {
    source: { type: "positional", description: "Source file path", required: true },
    destination: { type: "positional", description: "Destination path", required: true },
  },
  run: async ({ args }) => {
    await moveMarkdownFile(args.source, args.destination);
  },
});

const link = defineCommand({
  meta: { name: "link", description: "Generate a markdown link to a file" },
  args: {
    target: { type: "positional", description: "Target file path", required: true },
    absolute: {
      type: "boolean",
      description: "Generate absolute path (Starlight-style)",
      default: false,
    },
    root: { type: "string", description: "Content root directory (used with --absolute)" },
  },
  run: async ({ args }) => {
    console.log(await generateLink(args.target, { absolute: args.absolute, root: args.root }));
  },
});

const main = defineCommand({
  meta: { name: "cite", description: "Markdown link management" },
  subCommands: { move, link },
});

runMain(main);
