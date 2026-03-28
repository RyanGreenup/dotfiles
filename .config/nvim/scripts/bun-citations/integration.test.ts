import { describe, expect, test } from "bun:test";
import { mkdtemp, rm } from "node:fs/promises";
import { join } from "node:path";
import { tmpdir } from "node:os";

const BIN = join(import.meta.dir, "cite");

async function run(args: string[]): Promise<{ exitCode: number; stderr: string; stdout: string }> {
  const proc = Bun.spawn([BIN, ...args], { stderr: "pipe", stdout: "pipe" });
  const [stdout, stderr] = await Promise.all([
    new Response(proc.stdout).text(),
    new Response(proc.stderr).text(),
  ]);
  return { exitCode: await proc.exited, stderr, stdout };
}

async function makeTmpDir(): Promise<string> {
  return await mkdtemp(join(tmpdir(), "cite-int-"));
}

describe("binary: bibtex", () => {
  test("cites arxiv URL with --bib", async () => {
    const dir = await makeTmpDir();
    try {
      const result = await run(["https://arxiv.org/abs/2106.09685", "--bib", `--dir=${dir}`]);
      expect(result.exitCode).toBe(0);
      expect(result.stdout).toContain("Added @");
      const content = await Bun.file(join(dir, "references.bib")).text();
      expect(content).toContain("LoRA");
      expect(content).toContain("Hu, Edward J.");
    } finally {
      await rm(dir, { force: true, recursive: true });
    }
  }, 30_000);

  test("cites DOI with --bib", async () => {
    const dir = await makeTmpDir();
    try {
      const result = await run(["--doi=10.48550/arXiv.2403.03507", "--bib", `--dir=${dir}`]);
      expect(result.exitCode).toBe(0);
      const content = await Bun.file(join(dir, "references.bib")).text();
      expect(content).toContain("GaLore");
    } finally {
      await rm(dir, { force: true, recursive: true });
    }
  }, 30_000);

  test("detects duplicate", async () => {
    const dir = await makeTmpDir();
    try {
      await run(["https://arxiv.org/abs/2106.09685", "--bib", `--dir=${dir}`]);
      const second = await run(["https://arxiv.org/abs/2106.09685", "--bib", `--dir=${dir}`]);
      expect(second.stdout).toContain("Duplicate");
    } finally {
      await rm(dir, { force: true, recursive: true });
    }
  }, 60_000);
});

describe("binary: csl-json", () => {
  test("cites arxiv URL as JSON (default)", async () => {
    const dir = await makeTmpDir();
    try {
      const result = await run(["https://arxiv.org/abs/2106.09685", `--dir=${dir}`]);
      expect(result.exitCode).toBe(0);
      const items = JSON.parse(await Bun.file(join(dir, "references.json")).text());
      expect(items).toHaveLength(1);
      expect(items[0]?.title).toContain("LoRA");
    } finally {
      await rm(dir, { force: true, recursive: true });
    }
  }, 30_000);
});

describe("binary: web page fallback", () => {
  test("cites plain URL via HTML scraping", async () => {
    const dir = await makeTmpDir();
    try {
      const result = await run([
        "https://mise.jdx.dev/tasks/toml-tasks.html",
        "--bib",
        `--dir=${dir}`,
      ]);
      expect(result.exitCode).toBe(0);
      const content = await Bun.file(join(dir, "references.bib")).text();
      expect(content).toContain("mise");
      expect(content).toContain("TOML");
    } finally {
      await rm(dir, { force: true, recursive: true });
    }
  }, 30_000);
});

describe("binary: error handling", () => {
  test("rejects invalid URL", async () => {
    const result = await run(["not-a-url", "--bib"]);
    expect(result.exitCode).not.toBe(0);
  }, 10_000);
});
