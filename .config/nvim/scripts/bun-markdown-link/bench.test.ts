import { test } from "bun:test";
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import {
  buildInternalRewriter,
  collectImportEdits,
  collectUrlEdits,
  parseMarkdown,
  parseMdx,
} from "./links.ts";
import { moveMarkdownFile } from "./move.ts";

const REAL_PROJECT = "/var/home/ryan/Sync/journals/2026/03/09/sunrice-strapi_current/docs";
const SRC_REL = "src/content/docs/meta/visualization/guides/data-visualization.mdx";
const DEST_REL = "src/content/docs/moved/deep/data-visualization.mdx";

const MDX_FILES = [
  "src/content/docs/meta/visualization/guides/data-visualization.mdx",
  "src/content/docs/meta/authoring/guides/server-side.mdx",
  "src/content/docs/index.mdx",
];

function median(nums: number[]): number {
  const sorted = nums.toSorted((a, b) => a - b);
  const mid = Math.floor(sorted.length / 2);
  return sorted.length % 2 === 0
    ? ((sorted[mid - 1] ?? 0) + (sorted[mid] ?? 0)) / 2
    : (sorted[mid] ?? 0);
}

test("parseMdx vs parseMarkdown: warm-JIT comparison", async () => {
  const exists = await Bun.file(path.join(REAL_PROJECT, ".git", "HEAD")).exists();
  if (!exists) {
    console.log("SKIP: real project not found");
    return;
  }

  const sources = await Promise.all(
    MDX_FILES.map((f) => Bun.file(path.join(REAL_PROJECT, f)).text()),
  );

  const ITERATIONS = 100;
  const dummy = "/project/old";
  const dummyNew = "/project/new/deep";
  const ctx = {
    oldDir: dummy,
    newDir: dummyNew,
    oldPath: `${dummy}/file.mdx`,
    newPath: `${dummyNew}/file.mdx`,
    root: "/project",
  };

  // Warm up JIT
  for (const src of sources) {
    parseMarkdown(src);
    parseMdx(src);
    collectImportEdits(parseMdx(src), ctx);
  }

  console.log(
    `\n=== parseMdx vs parseMarkdown (${ITERATIONS} iterations, ${sources.length} files) ===\n`,
  );

  // --- Full pipeline: parseMdx (links + imports in one pass) ---
  const timingsMdx: number[] = [];
  for (let i = 0; i < ITERATIONS; i++) {
    const t0 = performance.now();
    for (const src of sources) {
      const tree = parseMdx(src);
      collectUrlEdits(src, tree, buildInternalRewriter(ctx));
      collectImportEdits(tree, ctx);
    }
    timingsMdx.push(performance.now() - t0);
  }

  // --- Full pipeline: parseMarkdown (links only, no import support) ---
  const timingsMd: number[] = [];
  for (let i = 0; i < ITERATIONS; i++) {
    const t0 = performance.now();
    for (const src of sources) {
      const tree = parseMarkdown(src);
      collectUrlEdits(src, tree, buildInternalRewriter(ctx));
    }
    timingsMd.push(performance.now() - t0);
  }

  // --- Parse-only comparison ---
  const parseMdTimes: number[] = [];
  const parseMdxTimes: number[] = [];
  for (let i = 0; i < ITERATIONS; i++) {
    let t0 = performance.now();
    for (const src of sources) {
      parseMarkdown(src);
    }
    parseMdTimes.push(performance.now() - t0);

    t0 = performance.now();
    for (const src of sources) {
      parseMdx(src);
    }
    parseMdxTimes.push(performance.now() - t0);
  }

  console.log("Full pipeline median (all 3 files):");
  console.log(`  parseMdx  (links + imports): ${median(timingsMdx).toFixed(2)}ms`);
  console.log(`  parseMarkdown (links only):  ${median(timingsMd).toFixed(2)}ms`);
  console.log(
    `  Cost of MDX support:         +${(median(timingsMdx) - median(timingsMd)).toFixed(2)}ms`,
  );
  console.log();
  console.log("Parse-only median (all 3 files):");
  console.log(`  parseMarkdown: ${median(parseMdTimes).toFixed(2)}ms`);
  console.log(`  parseMdx:      ${median(parseMdxTimes).toFixed(2)}ms`);
  console.log(`  Delta:         +${(median(parseMdxTimes) - median(parseMdTimes)).toFixed(2)}ms`);
  console.log();

  console.log("Per-file parse median:");
  for (let fi = 0; fi < sources.length; fi++) {
    const src = sources[fi]!;
    const mdTimes: number[] = [];
    const mdxTimes: number[] = [];
    for (let i = 0; i < ITERATIONS; i++) {
      let t0 = performance.now();
      parseMarkdown(src);
      mdTimes.push(performance.now() - t0);
      t0 = performance.now();
      parseMdx(src);
      mdxTimes.push(performance.now() - t0);
    }
    const name = MDX_FILES[fi]!.split("/").pop();
    const delta = median(mdxTimes) - median(mdTimes);
    console.log(
      `  ${name} (${src.length}B): md=${median(mdTimes).toFixed(2)}ms  mdx=${median(mdxTimes).toFixed(2)}ms  delta=+${delta.toFixed(2)}ms`,
    );
  }
}, 60_000);

test("end-to-end move on real project", async () => {
  const exists = await Bun.file(path.join(REAL_PROJECT, ".git", "HEAD")).exists();
  if (!exists) {
    console.log("SKIP: real project not found");
    return;
  }

  console.log("\n=== End-to-end move ===\n");

  const tmp = await mkdtemp(path.join(tmpdir(), "cite-bench-"));
  const cp = Bun.spawn(["cp", "-a", `${REAL_PROJECT}/.`, tmp], {
    stdout: "ignore",
    stderr: "ignore",
  });
  await cp.exited;

  const srcFile = path.join(tmp, SRC_REL);
  const destFile = path.join(tmp, DEST_REL);

  const t0 = performance.now();
  await moveMarkdownFile(srcFile, destFile);
  console.log(`moveMarkdownFile: ${(performance.now() - t0).toFixed(0)}ms`);

  await rm(tmp, { recursive: true, force: true });
}, 120_000);
