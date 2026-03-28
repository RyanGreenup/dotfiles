import Cite from "citation-js";
import { join } from "node:path";
import { readdir } from "node:fs/promises";

export type Format = "bibtex" | "csl-json";

export function validateUrl(raw: string): string {
  if (!URL.canParse(raw)) {
    throw new Error(`Not a valid URL: ${raw}`);
  }
  const url = new URL(raw);
  if (url.protocol !== "http:" && url.protocol !== "https:") {
    throw new Error(`Not an HTTP URL: ${raw}`);
  }
  return url.href;
}

function escapeLatex(text: string): string {
  return text.replaceAll(/[&%$#_{}~^]/g, (ch) => `\\${ch}`);
}

interface PageMeta {
  author: string;
  title: string;
  year: number;
}

interface RawMeta {
  author: string;
  citationAuthor: string;
  citationDate: string;
  citationTitle: string;
  ogTitle: string;
  title: string;
}

function firstNonEmpty(...values: string[]): string | undefined {
  return values.find((v) => v.length > 0);
}

function resolvePageMeta(raw: RawMeta, url: string): PageMeta {
  const yearMatch = raw.citationDate.match(/\d{4}/);
  return {
    author: firstNonEmpty(raw.citationAuthor, raw.author) || new URL(url).hostname,
    title: firstNonEmpty(raw.citationTitle, raw.ogTitle, raw.title) || url,
    year: yearMatch ? Number(yearMatch[0]) : new Date().getFullYear(),
  };
}

function buildRewriter(raw: RawMeta, abort: AbortController): HTMLRewriter {
  return new HTMLRewriter()
    .on("title", {
      text(t) {
        raw.title += t.text;
      },
    })
    .on('meta[property="og:title"]', {
      element(e) {
        raw.ogTitle = e.getAttribute("content") ?? "";
      },
    })
    .on('meta[name="citation_title"]', {
      element(e) {
        raw.citationTitle = e.getAttribute("content") ?? "";
      },
    })
    .on('meta[name="citation_author"]', {
      element(e) {
        raw.citationAuthor ||= e.getAttribute("content") ?? "";
      },
    })
    .on('meta[name="author"]', {
      element(e) {
        raw.author = e.getAttribute("content") ?? "";
      },
    })
    .on('meta[name="citation_date"]', {
      element(e) {
        raw.citationDate = e.getAttribute("content") ?? "";
      },
    })
    .on("body", {
      element() {
        abort.abort();
      },
    });
}

export async function scrapeResponse(resp: Response, url: string): Promise<PageMeta> {
  const raw: RawMeta = {
    author: "",
    citationAuthor: "",
    citationDate: "",
    citationTitle: "",
    ogTitle: "",
    title: "",
  };
  const abort = new AbortController();
  const rewriter = buildRewriter(raw, abort);
  try {
    await rewriter.transform(resp).text();
  } catch {
    // AbortError expected — we stop at <body>
  }
  return resolvePageMeta(raw, url);
}

export async function scrapePage(html: string, url: string): Promise<PageMeta> {
  return await scrapeResponse(new Response(html), url);
}

// --- CSL-JSON types (minimal) ---

export interface CslName {
  family?: string;
  given?: string;
  literal?: string;
}

export interface CslItem {
  id: string;
  type: string;
  title: string;
  author?: CslName[];
  issued?: { "date-parts": number[][] };
  URL?: string;
  accessed?: { "date-parts": number[][] };
  DOI?: string;
  /** Set to true when built from HTML scraping rather than citation-js */
  _scraped?: boolean;
  [key: string]: unknown;
}

// --- Fetching citations ---

export function arxivToDoi(url: string): string | undefined {
  const match = url.match(/arxiv\.org\/abs\/([0-9.]+(?:v\d+)?)/);
  return match?.[1] ? `10.48550/arXiv.${match[1]}` : undefined;
}

export async function fetchCsl(input: string): Promise<CslItem[]> {
  const cite = await Cite.async(input);
  return cite.format("data", { format: "object" }) as unknown as CslItem[];
}

export async function buildWebCsl(url: string, html: string): Promise<CslItem> {
  const meta = await scrapePage(html, url);
  const today = new Date().toISOString().slice(0, 10).split("-").map(Number);
  return {
    id: url,
    type: "webpage",
    title: meta.title,
    author: [{ literal: meta.author }],
    issued: { "date-parts": [[meta.year]] },
    URL: url,
    accessed: { "date-parts": [today] },
    _scraped: true,
  };
}

async function fetchFromHtml(url: string): Promise<CslItem[]> {
  const resp = await fetch(url);
  if (!resp.ok) {
    throw new Error(`Failed to fetch ${url}: ${resp.status}`);
  }
  const meta = await scrapeResponse(resp, url);
  const today = new Date().toISOString().slice(0, 10).split("-").map(Number);
  return [
    {
      id: url,
      type: "webpage",
      title: meta.title,
      author: [{ literal: meta.author }],
      issued: { "date-parts": [[meta.year]] },
      URL: url,
      accessed: { "date-parts": [today] },
      _scraped: true,
    },
  ];
}

async function tryFetchCsl(input: string): Promise<CslItem[] | undefined> {
  try {
    const items = await fetchCsl(input);
    if (items.length > 0) {
      return items;
    }
  } catch {
    // Input not parseable by citation-js
  }
  return undefined;
}

export async function fetchCitation(url: string): Promise<CslItem[]> {
  const doi = arxivToDoi(url);
  if (doi) {
    const items = await tryFetchCsl(doi);
    if (items) {
      return items;
    }
  }
  const items = await tryFetchCsl(url);
  return items ?? (await fetchFromHtml(url));
}

// --- BibTeX formatting ---

function cslToBibtex(items: CslItem[]): string {
  const cite = new Cite(items);
  return cite.format("bibtex").trim();
}

function nameFromCslAuthor(author: CslName): string {
  return author.literal ?? author.family ?? "Unknown";
}

function cslAuthorName(item: CslItem): string {
  const first = item.author?.[0];
  return first ? nameFromCslAuthor(first) : "Unknown";
}

function cslYear(item: CslItem): number {
  return item.issued?.["date-parts"]?.[0]?.[0] ?? new Date().getFullYear();
}

function formatDateParts(parts: number[] | undefined): string {
  if (!parts) {
    return new Date().toISOString().slice(0, 10);
  }
  return parts.map((n) => String(n).padStart(2, "0")).join("-");
}

function domainSlug(url: string): string {
  return url ? new URL(url).hostname.replaceAll(/[^a-zA-Z]/g, "") : "unknown";
}

function titleSlug(title: string): string {
  return title
    .split(/\s+/)
    .slice(0, 2)
    .join("")
    .replaceAll(/[^a-zA-Z]/g, "");
}

function buildWebBibtex(item: CslItem): string {
  const author = cslAuthorName(item);
  const { title } = item;
  const year = cslYear(item);
  const url = item.URL ?? "";
  const accessed = formatDateParts(item.accessed?.["date-parts"]?.[0]);
  const domain = domainSlug(url);
  const slug = titleSlug(title);
  return [
    `@misc{${domain}${year}${slug},`,
    `\ttitle = {${escapeLatex(title)}},`,
    `\tauthor = {${escapeLatex(author)}},`,
    `\tyear = {${year}},`,
    `\turl = {${url}},`,
    `\tnote = {Accessed: ${accessed}},`,
    "}",
  ].join("\n");
}

export function formatBibtex(items: CslItem[]): string {
  if (items.some((i) => i._scraped)) {
    return items.map((i) => buildWebBibtex(i)).join("\n\n");
  }
  return cslToBibtex(items);
}

// --- CSL-JSON file operations ---

function formatCslJson(items: CslItem[]): string {
  return JSON.stringify(items, undefined, 2);
}

export async function resolveOutputPath(dir: string, format: Format): Promise<string> {
  const ext = format === "bibtex" ? ".bib" : ".json";
  const entries = await readdir(dir).catch(() => [] as string[]);
  const matches = entries.filter((e) => e.endsWith(ext));
  if (matches.length === 1 && matches[0]) {
    return join(dir, matches[0]);
  }
  const defaultName = format === "bibtex" ? "references.bib" : "references.json";
  return join(dir, defaultName);
}

// --- BibTeX key management ---

export function extractKey(bibtex: string): string {
  const match = bibtex.match(/@\w+\{([^,]+),/);
  if (!match?.[1]) {
    throw new Error("Could not parse BibTeX key");
  }
  return match[1].trim();
}

function sanitizeKey(key: string): string {
  return key.replaceAll(/[^a-zA-Z0-9]/g, "");
}

async function existingKeys(bibPath: string): Promise<Set<string>> {
  const file = Bun.file(bibPath);
  if (!(await file.exists())) {
    return new Set();
  }
  const content = await file.text();
  const keys = new Set<string>();
  for (const [, k] of content.matchAll(/@\w+\{([^,]+),/g)) {
    if (k) {
      keys.add(k.trim());
    }
  }
  return keys;
}

function uniqueKey(base: string, taken: Set<string>): string {
  if (!taken.has(base)) {
    return base;
  }
  for (let i = 0; i < 26; i++) {
    const candidate = base + String.fromCodePoint(97 + i);
    if (!taken.has(candidate)) {
      return candidate;
    }
  }
  throw new Error(`Too many key collisions for: ${base}`);
}

function replaceKey(bibtex: string, oldKey: string, newKey: string): string {
  return bibtex.replace(`{${oldKey},`, `{${newKey},`);
}

export async function deduplicateEntry(bibtex: string, bibPath: string): Promise<string> {
  const original = extractKey(bibtex);
  const clean = sanitizeKey(original);
  const taken = await existingKeys(bibPath);
  const key = uniqueKey(clean, taken);
  return replaceKey(bibtex, original, key);
}

// --- Duplicate detection ---

function isDuplicateUrl(prev: string, url: string | undefined): boolean {
  return Boolean(url && prev.includes(url));
}

function isDuplicateDoi(prev: string, doi: string | undefined): boolean {
  return Boolean(doi && prev.includes(doi));
}

function isDuplicateItem(existingJson: string, item: CslItem): boolean {
  return isDuplicateUrl(existingJson, item.URL) || isDuplicateDoi(existingJson, item.DOI);
}

// --- Append operations ---

async function readFileContent(path: string): Promise<string> {
  const file = Bun.file(path);
  return (await file.exists()) ? await file.text() : "";
}

export async function appendBib(bibPath: string, entry: string): Promise<void> {
  const prev = await readFileContent(bibPath);
  const url = entry.match(/url\s*=\s*\{([^}]+)\}/)?.[1];
  if (isDuplicateUrl(prev, url)) {
    console.log(`Duplicate — citation already exists in ${bibPath}`);
    return;
  }
  const sep = prev.length > 0 && !prev.endsWith("\n\n") ? "\n" : "";
  await Bun.write(bibPath, `${prev}${sep}${entry}\n`);
  console.log(`Added @${extractKey(entry)} to ${bibPath}`);
  console.log(entry);
}

// O(n) stringify per call — fine for typical reference lists (<1000 entries)
function filterNewItems(existing: CslItem[], items: CslItem[], jsonPath: string): CslItem[] {
  const existingJson = JSON.stringify(existing);
  return items.filter((item) => {
    if (isDuplicateItem(existingJson, item)) {
      console.log(`Duplicate — citation already exists in ${jsonPath}`);
      return false;
    }
    return true;
  });
}

export async function appendCslJson(jsonPath: string, items: CslItem[]): Promise<void> {
  const content = await readFileContent(jsonPath);
  const existing: CslItem[] = content ? (JSON.parse(content) as CslItem[]) : [];
  const newItems = filterNewItems(existing, items, jsonPath);
  if (newItems.length === 0) {
    return;
  }
  const merged = [...existing, ...newItems];
  await Bun.write(jsonPath, `${JSON.stringify(merged, undefined, 2)}\n`);
  for (const item of newItems) {
    console.log(`Added "${item.title}" to ${jsonPath}`);
  }
  console.log(formatCslJson(newItems));
}

// --- Main process functions ---

export async function processCitation(
  items: CslItem[],
  dir: string,
  format: Format,
): Promise<void> {
  const outPath = await resolveOutputPath(dir, format);
  if (format === "bibtex") {
    const bibtex = formatBibtex(items);
    const entry = await deduplicateEntry(bibtex, outPath);
    await appendBib(outPath, entry);
  } else {
    await appendCslJson(outPath, items);
  }
}

async function alreadyExists(dir: string, format: Format, identifiers: string[]): Promise<boolean> {
  const outPath = await resolveOutputPath(dir, format);
  const prev = await readFileContent(outPath);
  if (!prev) {
    return false;
  }
  const found = identifiers.find((id) => prev.includes(id));
  if (found) {
    console.log(`Duplicate — citation already exists in ${outPath}`);
  }
  return Boolean(found);
}

export async function processUrl(raw: string, dir: string, format: Format): Promise<void> {
  const url = validateUrl(raw);
  const doi = arxivToDoi(url);
  const identifiers = doi ? [url, doi] : [url];
  if (await alreadyExists(dir, format, identifiers)) {
    return;
  }
  console.log(`Fetching citation for ${url}...`);
  const items = await fetchCitation(url);
  await processCitation(items, dir, format);
}

export async function processDoi(doi: string, dir: string, format: Format): Promise<void> {
  if (await alreadyExists(dir, format, [doi])) {
    return;
  }
  console.log(`Fetching citation for DOI ${doi}...`);
  const items = await fetchCsl(doi);
  if (items.length === 0) {
    throw new Error(`No citation data found for DOI: ${doi}`);
  }
  await processCitation(items, dir, format);
}
