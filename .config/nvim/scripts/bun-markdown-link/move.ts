import {
  type Edit,
  applyEdits,
  buildExternalRewriter,
  buildInternalRewriter,
  collectImportEdits,
  collectUrlEdits,
  parseMarkdown,
  parseMdx,
} from "./links.ts";
import { mkdir, rename } from "node:fs/promises";
import type { Parent } from "unist";
import { existsSync } from "node:fs";
import path from "node:path";

const MD_EXTS = new Set([".md", ".mdx", ".mdoc", ".rmd"]);

export function findProjectRoot(startDir: string): string {
  let dir = path.resolve(startDir);
  const { root } = path.parse(dir);
  while (dir !== root) {
    if (existsSync(path.join(dir, ".git"))) {
      return dir;
    }
    dir = path.dirname(dir);
  }
  return path.resolve(startDir);
}

function readText(filePath: string): Promise<string> {
  return Bun.file(filePath).text();
}

function isMdx(filePath: string): boolean {
  return path.extname(filePath).toLowerCase() === ".mdx";
}

function parse(source: string, filePath: string): Parent {
  return isMdx(filePath) ? parseMdx(source) : parseMarkdown(source);
}

interface InternalOpts {
  dest: string;
  oldPath: string;
  source: string;
  tree: Parent;
}

function collectInternalEdits(opts: InternalOpts): Edit[] {
  const { dest, oldPath, source, tree } = opts;
  const root = findProjectRoot(path.dirname(dest));
  const ctx = {
    oldDir: path.dirname(oldPath),
    newDir: path.dirname(dest),
    oldPath,
    newPath: dest,
    root,
  };
  const linkEdits = collectUrlEdits(source, tree, buildInternalRewriter(ctx));
  const importEdits = isMdx(dest) ? collectImportEdits(tree, ctx) : [];
  return [...linkEdits, ...importEdits];
}

export async function updateInternalLinks(dest: string, oldPath: string): Promise<void> {
  const source = await readText(dest);
  const tree = parse(source, dest);
  const edits = collectInternalEdits({ dest, oldPath, source, tree });
  if (edits.length === 0) {
    return;
  }
  await Bun.write(dest, applyEdits(source, edits));
}

interface ExternalPaths {
  old: string;
  new: string;
  root: string;
}

function couldReference(source: string, oldPath: string): boolean {
  const base = path.basename(oldPath);
  return source.includes(base) || source.includes(encodeURIComponent(base));
}

export async function updateExternalFile(filePath: string, paths: ExternalPaths): Promise<void> {
  const source = await readText(filePath);
  if (!couldReference(source, paths.old)) {
    return;
  }
  const tree = parse(source, filePath);
  const fileDir = path.dirname(filePath);
  const rewriter = buildExternalRewriter(fileDir, paths);
  const edits = collectUrlEdits(source, tree, rewriter);
  if (edits.length === 0) {
    return;
  }
  await Bun.write(filePath, applyEdits(source, edits));
}

async function listMarkdownFilesFallback(root: string): Promise<string[]> {
  const glob = new Bun.Glob("**/*.{md,mdx,mdoc,rmd}");
  const files: string[] = [];
  for await (const entry of glob.scan({ cwd: root, absolute: true })) {
    files.push(entry);
  }
  return files;
}

function warnNoGit(root: string): void {
  const lines = [
    "Warning: git is not available or this is not a git repository.",
    "Falling back to scanning all files including node_modules/.",
    "This may be slow in large projects.",
    "",
    "To fix this, either:",
    "  1. Install git: https://git-scm.com/downloads",
    `  2. Run 'git init' in ${root}`,
    "  3. Add a .gitignore to exclude node_modules/ and other large directories",
  ];
  console.warn(lines.join("\n"));
}

async function listMarkdownFiles(root: string): Promise<string[]> {
  const args = ["ls-files", "--cached", "--others", "--exclude-standard", "-z"];
  try {
    const proc = Bun.spawn(["git", ...args], { cwd: root, stdout: "pipe", stderr: "ignore" });
    const out = await new Response(proc.stdout).text();
    const code = await proc.exited;
    if (code === 0) {
      return out
        .split("\0")
        .filter((f) => MD_EXTS.has(path.extname(f).toLowerCase()))
        .map((f) => path.resolve(root, f));
    }
  } catch {
    // Git binary not found
  }
  warnNoGit(root);
  return listMarkdownFilesFallback(root);
}

export async function scanExternalFiles(
  root: string,
  oldPath: string,
  newPath: string,
): Promise<void> {
  const files = await listMarkdownFiles(root);
  const paths = { old: oldPath, new: newPath, root };
  const resolvedOld = path.resolve(oldPath);
  const resolvedNew = path.resolve(newPath);
  const skip = new Set([resolvedOld, resolvedNew]);
  const updates = files
    .filter((entry) => !skip.has(path.resolve(entry)))
    .map((entry) => updateExternalFile(entry, paths));
  await Promise.all(updates);
}

function resolveDest(src: string, dest: string): string {
  const absDest = path.resolve(dest);
  if (absDest.endsWith("/") || path.extname(absDest) === "") {
    return path.join(absDest, path.basename(src));
  }
  return absDest;
}

function isMarkdownExt(filePath: string): boolean {
  return MD_EXTS.has(path.extname(filePath).toLowerCase());
}

function resolvePaths(src: string, dest: string): { absSrc: string; absDest: string } {
  const absSrc = path.resolve(src);
  if (!existsSync(absSrc)) {
    throw new Error(`Source file does not exist: ${absSrc}`);
  }
  return { absSrc, absDest: resolveDest(absSrc, dest) };
}

export async function moveMarkdownFile(src: string, dest: string): Promise<void> {
  const { absSrc, absDest } = resolvePaths(src, dest);
  await mkdir(path.dirname(absDest), { recursive: true });
  await rename(absSrc, absDest);
  const root = findProjectRoot(path.dirname(absDest));
  if (isMarkdownExt(absDest)) {
    await updateInternalLinks(absDest, absSrc);
  }
  await scanExternalFiles(root, absSrc, absDest);
  console.log(`Moved ${absSrc} → ${absDest}`);
}
