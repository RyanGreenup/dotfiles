import { type CslItem, buildWebCsl, processCitation } from "./lib";
import { describe, expect, test } from "bun:test";
import { mkdtemp, readdir, rm } from "node:fs/promises";
import { join } from "node:path";
import { tmpdir } from "node:os";

// --- Fixtures (pre-recorded from real API calls) ---

const WIKI_URL = "https://en.wikipedia.org/wiki/Low-rank_approximation";

const loraItems: CslItem[] = await Bun.file(join(import.meta.dir, "fixtures/lora-csl.json")).json();
const galoreItems: CslItem[] = await Bun.file(
  join(import.meta.dir, "fixtures/galore-csl.json"),
).json();
const wikiHtml: string = await Bun.file(join(import.meta.dir, "fixtures/wiki-lowrank.html")).text();

// --- Helpers ---

async function makeTmpDir(): Promise<string> {
  return await mkdtemp(join(tmpdir(), "cite-test-"));
}

async function readFile(dir: string, name: string): Promise<string> {
  return await Bun.file(join(dir, name)).text();
}

function assertArxivBibtex(content: string): void {
  expect(content).toMatch(/@article\{/);
  expect(content).not.toMatch(/@misc\{/);
  expect(content).toMatch(/doi\s*=\s*\{/);
  expect(content).not.toContain("author = {arxiv.org}");
}

function assertCslArxivItem(item: Record<string, unknown>): void {
  expect(item.title).toContain("LoRA");
  expect(item.DOI).toBeDefined();
  const authors = item.author as Record<string, string>[];
  expect(authors.length).toBeGreaterThan(1);
}

// --- BibTeX output tests ---

describe("bibtex: arxiv (LoRA)", () => {
  test("produces @article with full metadata", async () => {
    const dir = await makeTmpDir();
    try {
      await processCitation(loraItems, dir, "bibtex");
      const content = await readFile(dir, "references.bib");
      assertArxivBibtex(content);
      expect(content).toContain("LoRA");
      expect(content).toContain("Hu, Edward J.");
      expect(content).toContain("Shen, Yelong");
      expect(content).toContain("year = {2021}");
    } finally {
      await rm(dir, { force: true, recursive: true });
    }
  });
  test("skips duplicate on second run", async () => {
    const dir = await makeTmpDir();
    try {
      await processCitation(loraItems, dir, "bibtex");
      await processCitation(loraItems, dir, "bibtex");
      const content = await readFile(dir, "references.bib");
      expect(content.match(/@article\{/g)).toHaveLength(1);
    } finally {
      await rm(dir, { force: true, recursive: true });
    }
  });
  test("uses existing .bib filename", async () => {
    const dir = await makeTmpDir();
    try {
      await Bun.write(join(dir, "papers.bib"), "");
      await processCitation(loraItems, dir, "bibtex");
      const files = await readdir(dir);
      expect(files).toContain("papers.bib");
      expect(files).not.toContain("references.bib");
      expect(await readFile(dir, "papers.bib")).toContain("LoRA");
    } finally {
      await rm(dir, { force: true, recursive: true });
    }
  });
});

describe("bibtex: wikipedia", () => {
  test("produces entry with title and URL", async () => {
    const dir = await makeTmpDir();
    try {
      const item = await buildWebCsl(WIKI_URL, wikiHtml);
      await processCitation([item], dir, "bibtex");
      const content = await readFile(dir, "references.bib");
      expect(content).toMatch(/Low-rank approximation/i);
      expect(content).toContain(WIKI_URL);
      expect(content).toMatch(/year\s*=\s*\{\d{4}\}/);
      expect(content).toMatch(/Accessed:\s*\d{4}-\d{2}-\d{2}/);
    } finally {
      await rm(dir, { force: true, recursive: true });
    }
  });
});

describe("bibtex: DOI (GaLore)", () => {
  test("produces @article with full metadata", async () => {
    const dir = await makeTmpDir();
    try {
      await processCitation(galoreItems, dir, "bibtex");
      const content = await readFile(dir, "references.bib");
      assertArxivBibtex(content);
      expect(content).toContain("GaLore");
      expect(content).toContain("Zhao, Jiawei");
      expect(content).toContain("Tian, Yuandong");
      expect(content).toContain("year = {2024}");
    } finally {
      await rm(dir, { force: true, recursive: true });
    }
  });
});

// --- CSL-JSON output tests ---

describe("csl-json: arxiv (LoRA)", () => {
  test("produces JSON with full metadata", async () => {
    const dir = await makeTmpDir();
    try {
      await processCitation(loraItems, dir, "csl-json");
      const files = await readdir(dir);
      expect(files).toContain("references.json");
      expect(files).not.toContain("references.bib");
      const items = JSON.parse(await readFile(dir, "references.json"));
      expect(items).toHaveLength(1);
      assertCslArxivItem(items[0] as Record<string, unknown>);
    } finally {
      await rm(dir, { force: true, recursive: true });
    }
  });

  test("skips duplicate on second run", async () => {
    const dir = await makeTmpDir();
    try {
      await processCitation(loraItems, dir, "csl-json");
      await processCitation(loraItems, dir, "csl-json");
      const items = JSON.parse(await readFile(dir, "references.json"));
      expect(items).toHaveLength(1);
    } finally {
      await rm(dir, { force: true, recursive: true });
    }
  });
});

describe("csl-json: DOI (GaLore)", () => {
  test("produces JSON", async () => {
    const dir = await makeTmpDir();
    try {
      await processCitation(galoreItems, dir, "csl-json");
      const items = JSON.parse(await readFile(dir, "references.json"));
      expect(items).toHaveLength(1);
      expect(items[0]?.title).toContain("GaLore");
    } finally {
      await rm(dir, { force: true, recursive: true });
    }
  });
});

describe("csl-json: wikipedia", () => {
  test("produces JSON with title and URL", async () => {
    const dir = await makeTmpDir();
    try {
      const item = await buildWebCsl(WIKI_URL, wikiHtml);
      await processCitation([item], dir, "csl-json");
      const items = JSON.parse(await readFile(dir, "references.json"));
      expect(items).toHaveLength(1);
      expect(items[0]?.title).toMatch(/Low-rank approximation/i);
      expect(items[0]?.URL).toBe(WIKI_URL);
    } finally {
      await rm(dir, { force: true, recursive: true });
    }
  });
});
