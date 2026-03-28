import { makeRelative, parseMarkdown } from "./links.ts";
import path from "node:path";
import { sentenceCase } from "change-case";
import { toString } from "mdast-util-to-string";
import { visit } from "unist-util-visit";

function extractYamlTitle(block: string): string | undefined {
  const m =
    block.match(/^title:\s*"([^"]*)"$/m) ??
    block.match(/^title:\s*'([^']*)'$/m) ??
    block.match(/^title:\s*(.+)$/m);
  return m?.[1]?.trim();
}

function extractTomlTitle(block: string): string | undefined {
  const m = block.match(/^title\s*=\s*"([^"]*)"$/m);
  return m?.[1];
}

export function extractFrontmatterTitle(content: string): string | undefined {
  const yamlMatch = content.match(/^---\n([\s\S]*?)\n---/);
  if (yamlMatch?.[1]) {
    return extractYamlTitle(yamlMatch[1]);
  }
  const tomlMatch = content.match(/^\+\+\+\n([\s\S]*?)\n\+\+\+/);
  if (tomlMatch?.[1]) {
    return extractTomlTitle(tomlMatch[1]);
  }
  return undefined;
}

export function extractFirstHeading(content: string): string | undefined {
  const tree = parseMarkdown(content);
  let title: string | undefined = undefined;
  visit(tree, "heading", (node) => {
    if (title === undefined) {
      title = toString(node);
    }
    return false;
  });
  return title;
}

export function titleFromFilename(filePath: string): string {
  const ext = path.extname(filePath);
  const base = path.basename(filePath, ext);
  return sentenceCase(base);
}

export function extractTitle(content: string, filePath: string): string {
  return (
    extractFrontmatterTitle(content) ?? extractFirstHeading(content) ?? titleFromFilename(filePath)
  );
}

export function toStarlightPath(filePath: string, root: string): string {
  const rel = path.relative(root, filePath);
  const segments = rel.split("/");
  const last = segments.at(-1) ?? "";
  const ext = path.extname(last);
  const stem = path.basename(last, ext);
  if (stem === "index") {
    segments.pop();
  } else {
    segments[segments.length - 1] = stem;
  }
  return `/${segments.join("/")}/`;
}

export interface GenerateLinkOptions {
  absolute?: boolean;
  root?: string;
}

export async function generateLink(
  target: string,
  opts: GenerateLinkOptions = {},
): Promise<string> {
  const resolved = path.resolve(target);
  const content = await Bun.file(resolved).text();
  const title = extractTitle(content, resolved);
  if (opts.absolute) {
    const root = path.resolve(opts.root ?? ".");
    const href = toStarlightPath(resolved, root);
    return `[${title}](${href})`;
  }
  const relativePath = makeRelative(path.resolve("dummy"), resolved);
  return `[${title}](${relativePath})`;
}
