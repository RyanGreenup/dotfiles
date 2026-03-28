import { afterEach, beforeEach, expect, test } from "bun:test";
import { mkdtemp, rm } from "node:fs/promises";
import { moveMarkdownFile } from "./move.ts";
import path from "node:path";
import { tmpdir } from "node:os";

let root = "";

function writeFile(rel: string, content: string): Promise<number> {
  return Bun.write(path.join(root, rel), content);
}

function readFile(rel: string): Promise<string> {
  return Bun.file(path.join(root, rel)).text();
}

function fileExists(rel: string): Promise<boolean> {
  return Bun.file(path.join(root, rel)).exists();
}

async function initGit(): Promise<void> {
  const proc = Bun.spawn(["git", "init"], { cwd: root, stdout: "ignore", stderr: "ignore" });
  await proc.exited;
}

function src(rel: string): string {
  return path.join(root, rel);
}

beforeEach(async () => {
  root = await mkdtemp(path.join(tmpdir(), "cite-test-"));
  await initGit();
});

afterEach(async () => {
  await rm(root, { recursive: true, force: true });
});

test("moves file to new location", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await fileExists("archive/guide.md")).toBe(true);
  expect(await fileExists("docs/guide.md")).toBe(false);
});

test("updates relative links inside moved file", async () => {
  await writeFile("docs/guide.md", "See [api](./api.md) for details.\n");
  await writeFile("docs/api.md", "# API\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("archive/guide.md")).toBe("See [api](../docs/api.md) for details.\n");
});

test("updates external files referencing moved file", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  await writeFile("docs/index.md", "Read the [guide](./guide.md).\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("docs/index.md")).toBe("Read the [guide](../archive/guide.md).\n");
});

test("preserves fragments in links", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  await writeFile("docs/index.md", "See [section](./guide.md#intro).\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("docs/index.md")).toBe("See [section](../archive/guide.md#intro).\n");
});

test("preserves absolute link style in external files", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  await writeFile("pages/index.md", "See [guide](/docs/guide.md).\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("pages/index.md")).toBe("See [guide](/archive/guide.md).\n");
});

test("preserves absolute link style inside moved file", async () => {
  await writeFile("docs/guide.md", "See [api](/docs/api.md) for details.\n");
  await writeFile("docs/api.md", "# API\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("archive/guide.md")).toBe("See [api](/docs/api.md) for details.\n");
});

test("updates multiple links in one file", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  await writeFile("docs/index.md", "Read [guide](./guide.md) and [guide again](./guide.md#faq).\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("docs/index.md")).toBe(
    "Read [guide](../archive/guide.md) and [guide again](../archive/guide.md#faq).\n",
  );
});

test("updates links across multiple external files", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  await writeFile("docs/a.md", "Link: [guide](./guide.md)\n");
  await writeFile("docs/b.md", "Link: [guide](./guide.md)\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("docs/a.md")).toBe("Link: [guide](../archive/guide.md)\n");
  expect(await readFile("docs/b.md")).toBe("Link: [guide](../archive/guide.md)\n");
});

test("does not modify files with no matching links", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  const original = "Link: [other](./other.md)\n";
  await writeFile("docs/unrelated.md", original);
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("docs/unrelated.md")).toBe(original);
});

test("dest as directory appends filename", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/"));
  expect(await fileExists("archive/guide.md")).toBe(true);
  expect(await readFile("archive/guide.md")).toBe("# Guide\n");
});

test("throws if source does not exist", () => {
  expect(moveMarkdownFile(src("nope.md"), src("dest.md"))).rejects.toThrow("does not exist");
});

test("handles image links in external files", async () => {
  await writeFile("assets/diagram.png", "PNG");
  await writeFile("docs/guide.md", "![diagram](../assets/diagram.png)\n");
  await moveMarkdownFile(src("assets/diagram.png"), src("img/diagram.png"));
  expect(await readFile("docs/guide.md")).toBe("![diagram](../img/diagram.png)\n");
});

test("handles deeply nested moves", async () => {
  await writeFile("a/b/c/file.md", "# Deep\n");
  await writeFile("index.md", "See [deep](./a/b/c/file.md).\n");
  await moveMarkdownFile(src("a/b/c/file.md"), src("x/y/file.md"));
  expect(await readFile("index.md")).toBe("See [deep](./x/y/file.md).\n");
});

test("updates .mdx files", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  await writeFile("pages/index.mdx", "Read [guide](../docs/guide.md).\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("pages/index.mdx")).toBe("Read [guide](../archive/guide.md).\n");
});

test("updates internal links that go up then down", async () => {
  await writeFile("docs/guide.md", "See [ref](../ref/api.md) for details.\n");
  await writeFile("ref/api.md", "# API\n");
  await moveMarkdownFile(src("docs/guide.md"), src("deep/a/guide.md"));
  expect(await readFile("deep/a/guide.md")).toBe("See [ref](../../ref/api.md) for details.\n");
});

test("url-encoded paths in links", async () => {
  await writeFile("docs/my file.md", "# Spaces\n");
  await writeFile("docs/index.md", "See [it](./my%20file.md).\n");
  await moveMarkdownFile(src("docs/my file.md"), src("archive/my file.md"));
  expect(await readFile("docs/index.md")).toBe("See [it](../archive/my%20file.md).\n");
});

test("definition-style links are updated", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  await writeFile("docs/index.md", "[guide]: ./guide.md\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("docs/index.md")).toBe("[guide]: ../archive/guide.md\n");
});

test("links inside fenced code blocks are not rewritten", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  const original = "```md\n[guide](./guide.md)\n```\n";
  await writeFile("docs/index.md", original);
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("docs/index.md")).toBe(original);
});

test("links inside inline code are not rewritten", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  const original = "Use `[guide](./guide.md)` syntax.\n";
  await writeFile("docs/index.md", original);
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("docs/index.md")).toBe(original);
});

test("query strings in links are preserved", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  await writeFile("docs/index.md", "See [guide](./guide.md?v=2).\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("docs/index.md")).toBe("See [guide](../archive/guide.md?v=2).\n");
});

test("query string and fragment preserved together", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  await writeFile("docs/index.md", "See [guide](./guide.md?v=2#intro).\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("docs/index.md")).toBe("See [guide](../archive/guide.md?v=2#intro).\n");
});

test("rename within same directory", async () => {
  await writeFile("docs/old.md", "# Old\n");
  await writeFile("docs/index.md", "See [old](./old.md).\n");
  await moveMarkdownFile(src("docs/old.md"), src("docs/new.md"));
  expect(await fileExists("docs/new.md")).toBe(true);
  expect(await fileExists("docs/old.md")).toBe(false);
  expect(await readFile("docs/index.md")).toBe("See [old](./new.md).\n");
});

test("self-referencing link in moved file", async () => {
  await writeFile("docs/guide.md", "See [self](./guide.md#section).\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("archive/guide.md")).toBe("See [self](./guide.md#section).\n");
});

test("moved non-markdown file is not parsed for internal links", async () => {
  const binary = "\u0089PNG\r\n\u001A\n";
  await writeFile("assets/logo.png", binary);
  await writeFile("docs/index.md", "![logo](../assets/logo.png)\n");
  await moveMarkdownFile(src("assets/logo.png"), src("img/logo.png"));
  expect(await fileExists("img/logo.png")).toBe(true);
  expect(await readFile("docs/index.md")).toBe("![logo](../img/logo.png)\n");
});

test("updates .mdoc files", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  await writeFile("content/page.mdoc", "Read [guide](../docs/guide.md).\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("content/page.mdoc")).toBe("Read [guide](../archive/guide.md).\n");
});

test("updates .rmd files", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  await writeFile("analysis/report.rmd", "Read [guide](../docs/guide.md).\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("analysis/report.rmd")).toBe("Read [guide](../archive/guide.md).\n");
});

test("overwrites existing destination (matches mv behavior)", async () => {
  await writeFile("docs/a.md", "# A\n");
  await writeFile("docs/b.md", "# B\n");
  await moveMarkdownFile(src("docs/a.md"), src("docs/b.md"));
  expect(await fileExists("docs/a.md")).toBe(false);
  expect(await readFile("docs/b.md")).toBe("# A\n");
});

test("move to same path is a no-op", async () => {
  await writeFile("docs/a.md", "See [b](./b.md).\n");
  await writeFile("docs/b.md", "# B\n");
  await moveMarkdownFile(src("docs/a.md"), src("docs/a.md"));
  expect(await readFile("docs/a.md")).toBe("See [b](./b.md).\n");
});

test("file with mixed absolute and relative links", async () => {
  await writeFile("docs/guide.md", "See [a](./api.md) and [b](/docs/ref.md).\n");
  await writeFile("docs/api.md", "# API\n");
  await writeFile("docs/ref.md", "# Ref\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  const content = await readFile("archive/guide.md");
  expect(content).toBe("See [a](../docs/api.md) and [b](/docs/ref.md).\n");
});

test("angle-bracket autolinks are not rewritten", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  const original = "See <./guide.md> for details.\n";
  await writeFile("docs/index.md", original);
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("docs/index.md")).toBe(original);
});

test("HTML a href tags are not rewritten", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  const original = '<a href="./guide.md">guide</a>\n';
  await writeFile("docs/index.md", original);
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("docs/index.md")).toBe(original);
});

test("HTML img src tags are not rewritten", async () => {
  await writeFile("assets/logo.png", "PNG");
  const original = '<img src="./assets/logo.png" />\n';
  await writeFile("docs/index.md", original);
  await moveMarkdownFile(src("assets/logo.png"), src("img/logo.png"));
  expect(await readFile("docs/index.md")).toBe(original);
});

test("parentheses in filenames", async () => {
  await writeFile("docs/file (1).md", "# File\n");
  await writeFile("docs/index.md", "See [it](./file%20(1).md).\n");
  await moveMarkdownFile(src("docs/file (1).md"), src("archive/file (1).md"));
  expect(await readFile("docs/index.md")).toBe("See [it](../archive/file%20(1).md).\n");
});

test("dest is existing directory without trailing slash", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  await writeFile("archive/.gitkeep", "");
  await moveMarkdownFile(src("docs/guide.md"), src("archive"));
  expect(await fileExists("archive/guide.md")).toBe(true);
  expect(await readFile("archive/guide.md")).toBe("# Guide\n");
});

test("wiki-style links are left alone", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  const original = "See [[guide]] for details.\n";
  await writeFile("docs/index.md", original);
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("docs/index.md")).toBe(original);
});

test("definition-style links with fragment and query", async () => {
  await writeFile("docs/guide.md", "# Guide\n");
  await writeFile("docs/index.md", "[guide]: ./guide.md?v=2#intro\n");
  await moveMarkdownFile(src("docs/guide.md"), src("archive/guide.md"));
  expect(await readFile("docs/index.md")).toBe("[guide]: ../archive/guide.md?v=2#intro\n");
});

test("mdx import paths are updated when file moves", async () => {
  const mdx = `---
title: Test
---

import Hero from "../components/Hero.astro";

# Hello

[link](./other.md)
`;
  await writeFile("components/Hero.astro", "<div>Hero</div>");
  await writeFile("docs/other.md", "# Other\n");
  await writeFile("docs/page.mdx", mdx);
  await moveMarkdownFile(src("docs/page.mdx"), src("pages/nested/page.mdx"));
  const result = await readFile("pages/nested/page.mdx");
  expect(result).toContain('import Hero from "../../components/Hero.astro"');
  expect(result).toContain("[link](../../docs/other.md)");
});

test("mdx multiple imports are all updated", async () => {
  const mdx = `import A from '../a.ts';
import B from "../b.ts";

# Hello
`;
  await writeFile("a.ts", "export default 1;");
  await writeFile("b.ts", "export default 2;");
  await writeFile("docs/page.mdx", mdx);
  await moveMarkdownFile(src("docs/page.mdx"), src("deep/nested/page.mdx"));
  const result = await readFile("deep/nested/page.mdx");
  expect(result).toContain("from '../../a.ts'");
  expect(result).toContain('from "../../b.ts"');
});

test("mdx import with named exports is updated", async () => {
  const mdx = `import { Foo, Bar } from '../lib/utils.ts';

# Hello
`;
  await writeFile("lib/utils.ts", "export const Foo = 1;");
  await writeFile("docs/page.mdx", mdx);
  await moveMarkdownFile(src("docs/page.mdx"), src("pages/page.mdx"));
  const result = await readFile("pages/page.mdx");
  expect(result).toContain("from '../lib/utils.ts'");
});

test("mdx non-relative imports are left alone", async () => {
  const mdx = `import React from 'react';
import { useState } from "react";
import Comp from './Comp.astro';

# Hello
`;
  await writeFile("docs/Comp.astro", "<div />");
  await writeFile("docs/page.mdx", mdx);
  await moveMarkdownFile(src("docs/page.mdx"), src("pages/page.mdx"));
  const result = await readFile("pages/page.mdx");
  expect(result).toContain("from 'react'");
  expect(result).toContain('from "react"');
  expect(result).toContain("from '../docs/Comp.astro'");
});
