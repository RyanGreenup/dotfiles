import type { Node, Parent } from "unist";
import path from "node:path";
import remarkFrontmatter from "remark-frontmatter";
import remarkMdx from "remark-mdx";
import remarkParse from "remark-parse";
import { unified } from "unified";
import { visit } from "unist-util-visit";

export interface Edit {
  offset: number;
  length: number;
  replacement: string;
}

interface LinkNode extends Node {
  url?: string;
  type: string;
}

interface EsmNode extends Node {
  value: string;
  type: "mdxjsEsm";
}

interface SplitResult {
  pathPart: string;
  query: string;
  fragment: string;
}

type Rewriter = (href: string, node: LinkNode) => string | undefined;

interface RewritePaths {
  old: string;
  new: string;
  root: string;
}

export function parseMarkdown(source: string): Parent {
  return unified().use(remarkParse).use(remarkFrontmatter).parse(source);
}

export function parseMdx(source: string): Parent {
  return unified().use(remarkParse).use(remarkFrontmatter).use(remarkMdx).parse(source);
}

export function isExternalUrl(href: string): boolean {
  if (href.startsWith("#") || href.startsWith("mailto:")) {
    return true;
  }
  try {
    const url = new URL(href);
    return url.protocol !== "";
  } catch {
    return false;
  }
}

export function splitHref(href: string): SplitResult {
  const hashIdx = href.indexOf("#");
  const fragment = hashIdx === -1 ? "" : href.slice(hashIdx);
  const beforeHash = hashIdx === -1 ? href : href.slice(0, hashIdx);
  const qIdx = beforeHash.indexOf("?");
  const query = qIdx === -1 ? "" : beforeHash.slice(qIdx);
  const pathPart = qIdx === -1 ? beforeHash : beforeHash.slice(0, qIdx);
  return { pathPart, query, fragment };
}

export function isAbsoluteLink(href: string): boolean {
  const { pathPart } = splitHref(href);
  return path.isAbsolute(decodeURIComponent(pathPart));
}

function getNodeOffsets(node: LinkNode): [number, number] | undefined {
  const pos = node.position;
  if (!pos) {
    return undefined;
  }
  const { start, end } = pos;
  if (start.offset === undefined || end.offset === undefined) {
    return undefined;
  }
  return [start.offset, end.offset];
}

export function findUrlOffset(source: string, node: LinkNode): number {
  const offsets = getNodeOffsets(node);
  if (!offsets) {
    return -1;
  }
  const raw = source.slice(offsets[0], offsets[1]);
  const idx = raw.indexOf(node.url ?? "");
  return idx === -1 ? -1 : offsets[0] + idx;
}

export function makeRelative(from: string, to: string): string {
  const rel = path.relative(path.dirname(from), to);
  const prefixed = rel.startsWith(".") ? rel : `./${rel}`;
  return prefixed
    .split("/")
    .map((s) => encodeURIComponent(s))
    .join("/");
}

export function makeRelativePlain(from: string, to: string): string {
  const rel = path.relative(path.dirname(from), to);
  return rel.startsWith(".") ? rel : `./${rel}`;
}

export function makeAbsolute(root: string, target: string): string {
  const rel = path.relative(root, target);
  return `/${rel
    .split("/")
    .map((s) => encodeURIComponent(s))
    .join("/")}`;
}

function resolveLink(href: string, fileDir: string, root: string): string {
  const { pathPart } = splitHref(href);
  const decoded = decodeURIComponent(pathPart);
  return isAbsoluteLink(href)
    ? path.resolve(root, decoded.slice(1))
    : path.resolve(fileDir, decoded);
}

interface NewPathOpts {
  href: string;
  resolved: string;
  fileDir: string;
  root: string;
}

function computeNewPath(opts: NewPathOpts): string {
  return isAbsoluteLink(opts.href)
    ? makeAbsolute(opts.root, opts.resolved)
    : makeRelative(path.join(opts.fileDir, "dummy"), opts.resolved);
}

interface RewriteOpts {
  href: string;
  fileDir: string;
  oldTarget: string;
  newTarget: string;
  root: string;
}

export function rewriteHref(opts: RewriteOpts): string | undefined {
  const { href, oldTarget, newTarget } = opts;
  if (isExternalUrl(href)) {
    return undefined;
  }
  const { pathPart, query, fragment } = splitHref(href);
  if (pathPart === "") {
    return undefined;
  }
  const resolved = resolveLink(href, opts.fileDir, opts.root);
  if (path.resolve(resolved) !== path.resolve(oldTarget)) {
    return undefined;
  }
  return (
    computeNewPath({ href, resolved: newTarget, fileDir: opts.fileDir, root: opts.root }) +
    query +
    fragment
  );
}

interface InternalCtx {
  oldDir: string;
  newDir: string;
  oldPath: string;
  newPath: string;
  root: string;
}

function rewriteInternalHref(href: string, ctx: InternalCtx): string | undefined {
  if (isExternalUrl(href)) {
    return undefined;
  }
  const { pathPart, query, fragment } = splitHref(href);
  if (pathPart === "") {
    return undefined;
  }
  const resolved = resolveLink(href, ctx.oldDir, ctx.root);
  const isSelfRef = path.resolve(resolved) === path.resolve(ctx.oldPath);
  const target = isSelfRef ? ctx.newPath : resolved;
  return (
    computeNewPath({ href, resolved: target, fileDir: ctx.newDir, root: ctx.root }) +
    query +
    fragment
  );
}

export function buildInternalRewriter(ctx: InternalCtx): Rewriter {
  return (href: string) => rewriteInternalHref(href, ctx);
}

export function buildExternalRewriter(fileDir: string, paths: RewritePaths): Rewriter {
  return (href: string) =>
    rewriteHref({
      href,
      fileDir,
      oldTarget: paths.old,
      newTarget: paths.new,
      root: paths.root,
    });
}

function isLinkNode(node: Node): node is LinkNode {
  const t = node.type;
  return t === "link" || t === "image" || t === "definition";
}

interface VisitCtx {
  source: string;
  rewriter: Rewriter;
  edits: Edit[];
}

function visitNode(ctx: VisitCtx, node: Node): void {
  if (!isLinkNode(node) || node.url === undefined) {
    return;
  }
  const replacement = ctx.rewriter(node.url, node);
  if (replacement === undefined) {
    return;
  }
  const offset = findUrlOffset(ctx.source, node);
  if (offset === -1) {
    return;
  }
  ctx.edits.push({ offset, length: node.url.length, replacement });
}

export function collectUrlEdits(source: string, tree: Parent, rewriter: Rewriter): Edit[] {
  const ctx: VisitCtx = { source, rewriter, edits: [] };
  visit(tree, (node: Node) => {
    visitNode(ctx, node);
  });
  return ctx.edits;
}

function isEsmNode(node: Node): node is EsmNode {
  return node.type === "mdxjsEsm";
}

const IMPORT_RE = /from\s+(['"])(\.{1,2}\/[^'"]*)\1/g;

export interface ImportCtx {
  oldDir: string;
  newDir: string;
  oldPath: string;
  newPath: string;
}

function rewriteImportSpec(specifier: string, ctx: ImportCtx): string {
  const resolved = path.resolve(ctx.oldDir, specifier);
  const isSelfRef = path.resolve(resolved) === path.resolve(ctx.oldPath);
  const target = isSelfRef ? ctx.newPath : resolved;
  return makeRelativePlain(path.join(ctx.newDir, "dummy"), target);
}

interface ImportMatch {
  specifier: string;
  quote: string;
  index: number;
}

function findImportMatches(value: string): ImportMatch[] {
  IMPORT_RE.lastIndex = 0;
  const matches: ImportMatch[] = [];
  let match = IMPORT_RE.exec(value);
  while (match) {
    matches.push({ specifier: match[2] ?? "", quote: match[1] ?? "'", index: match.index });
    match = IMPORT_RE.exec(value);
  }
  return matches;
}

interface EsmEditCtx {
  value: string;
  baseOffset: number;
  importCtx: ImportCtx;
}

function importMatchToEdit(m: ImportMatch, ctx: EsmEditCtx): Edit | undefined {
  const newSpec = rewriteImportSpec(m.specifier, ctx.importCtx);
  if (newSpec === m.specifier) {
    return undefined;
  }
  const qIdx = ctx.value.indexOf(`${m.quote}${m.specifier}${m.quote}`, m.index);
  return { offset: ctx.baseOffset + qIdx + 1, length: m.specifier.length, replacement: newSpec };
}

function collectEsmNodeEdits(node: EsmNode, importCtx: ImportCtx): Edit[] {
  const ctx: EsmEditCtx = {
    value: node.value,
    baseOffset: node.position?.start?.offset ?? 0,
    importCtx,
  };
  return findImportMatches(node.value)
    .map((m) => importMatchToEdit(m, ctx))
    .filter((e): e is Edit => e !== undefined);
}

export function collectImportEdits(source: string, tree: Parent, ctx: ImportCtx): Edit[] {
  const edits: Edit[] = [];
  visit(tree, (node: Node) => {
    if (isEsmNode(node)) {
      edits.push(...collectEsmNodeEdits(node, ctx));
    }
  });
  return edits;
}

export function applyEdits(source: string, edits: Edit[]): string {
  const sorted = edits.toSorted((a, b) => b.offset - a.offset);
  let result = source;
  for (const { offset, length, replacement } of sorted) {
    result = result.slice(0, offset) + replacement + result.slice(offset + length);
  }
  return result;
}
