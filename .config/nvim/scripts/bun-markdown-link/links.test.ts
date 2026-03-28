import {
  applyEdits,
  buildExternalRewriter,
  buildInternalRewriter,
  collectUrlEdits,
  findUrlOffset,
  isAbsoluteLink,
  isExternalUrl,
  makeAbsolute,
  makeRelative,
  parseMarkdown,
  rewriteHref,
  splitHref,
} from "./links.ts";
import { describe, expect, test } from "bun:test";

describe("isExternalUrl", () => {
  test("http urls", () => {
    expect(isExternalUrl("https://example.com")).toBe(true);
    expect(isExternalUrl("http://example.com/foo")).toBe(true);
  });

  test("fragment-only", () => {
    expect(isExternalUrl("#heading")).toBe(true);
  });

  test("mailto", () => {
    expect(isExternalUrl("mailto:a@b.com")).toBe(true);
  });

  test("relative paths", () => {
    expect(isExternalUrl("./foo.md")).toBe(false);
    expect(isExternalUrl("../bar.md")).toBe(false);
    expect(isExternalUrl("foo.md")).toBe(false);
  });

  test("absolute paths", () => {
    expect(isExternalUrl("/docs/foo.md")).toBe(false);
  });
});

describe("splitHref", () => {
  test("no fragment or query", () => {
    expect(splitHref("foo.md")).toEqual({ pathPart: "foo.md", query: "", fragment: "" });
  });

  test("with fragment", () => {
    expect(splitHref("foo.md#bar")).toEqual({ pathPart: "foo.md", query: "", fragment: "#bar" });
  });

  test("fragment only", () => {
    expect(splitHref("#bar")).toEqual({ pathPart: "", query: "", fragment: "#bar" });
  });

  test("with query string", () => {
    expect(splitHref("foo.md?v=2")).toEqual({ pathPart: "foo.md", query: "?v=2", fragment: "" });
  });

  test("with query and fragment", () => {
    expect(splitHref("foo.md?v=2#bar")).toEqual({
      pathPart: "foo.md",
      query: "?v=2",
      fragment: "#bar",
    });
  });
});

describe("isAbsoluteLink", () => {
  test("absolute", () => {
    expect(isAbsoluteLink("/docs/foo.md")).toBe(true);
  });

  test("relative", () => {
    expect(isAbsoluteLink("./foo.md")).toBe(false);
    expect(isAbsoluteLink("../foo.md")).toBe(false);
  });

  test("with fragment", () => {
    expect(isAbsoluteLink("/docs/foo.md#heading")).toBe(true);
  });
});

describe("makeRelative", () => {
  test("same directory", () => {
    expect(makeRelative("/a/b/from.md", "/a/b/to.md")).toBe("./to.md");
  });

  test("parent directory", () => {
    expect(makeRelative("/a/b/c/from.md", "/a/b/to.md")).toBe("../to.md");
  });

  test("child directory", () => {
    expect(makeRelative("/a/from.md", "/a/b/to.md")).toBe("./b/to.md");
  });
});

describe("makeAbsolute", () => {
  test("basic", () => {
    expect(makeAbsolute("/project", "/project/docs/foo.md")).toBe("/docs/foo.md");
  });

  test("nested", () => {
    expect(makeAbsolute("/project", "/project/a/b/c.md")).toBe("/a/b/c.md");
  });
});

describe("findUrlOffset", () => {
  test("finds url in link node", () => {
    const source = "[hello](./foo.md)";
    const tree = parseMarkdown(source);
    const para = tree.children[0] as unknown as { children: unknown[] };
    const [link] = para.children;
    expect(findUrlOffset(source, link as never)).toBe(8);
  });

  test("finds url in image node", () => {
    const source = "![alt](./img.png)";
    const tree = parseMarkdown(source);
    const para = tree.children[0] as unknown as { children: unknown[] };
    const [imgNode] = para.children;
    expect(findUrlOffset(source, imgNode as never)).toBe(7);
  });
});

test("rewriteHref: rewrites matching relative link", () => {
  const result = rewriteHref({
    href: "./old.md",
    fileDir: "/project/docs",
    oldTarget: "/project/docs/old.md",
    newTarget: "/project/archive/old.md",
    root: "/project",
  });
  expect(result).toBe("../archive/old.md");
});

test("rewriteHref: rewrites matching absolute link", () => {
  const result = rewriteHref({
    href: "/docs/old.md",
    fileDir: "/project/pages",
    oldTarget: "/project/docs/old.md",
    newTarget: "/project/archive/old.md",
    root: "/project",
  });
  expect(result).toBe("/archive/old.md");
});

test("rewriteHref: preserves fragment", () => {
  const result = rewriteHref({
    href: "./old.md#section",
    fileDir: "/project/docs",
    oldTarget: "/project/docs/old.md",
    newTarget: "/project/archive/old.md",
    root: "/project",
  });
  expect(result).toBe("../archive/old.md#section");
});

test("rewriteHref: preserves query string", () => {
  const result = rewriteHref({
    href: "./old.md?v=2",
    fileDir: "/project/docs",
    oldTarget: "/project/docs/old.md",
    newTarget: "/project/archive/old.md",
    root: "/project",
  });
  expect(result).toBe("../archive/old.md?v=2");
});

test("rewriteHref: preserves query and fragment", () => {
  const result = rewriteHref({
    href: "./old.md?v=2#section",
    fileDir: "/project/docs",
    oldTarget: "/project/docs/old.md",
    newTarget: "/project/archive/old.md",
    root: "/project",
  });
  expect(result).toBe("../archive/old.md?v=2#section");
});

test("rewriteHref: returns undefined for non-matching", () => {
  const result = rewriteHref({
    href: "./other.md",
    fileDir: "/project/docs",
    oldTarget: "/project/docs/old.md",
    newTarget: "/project/archive/old.md",
    root: "/project",
  });
  expect(result).toBeUndefined();
});

test("rewriteHref: returns undefined for external", () => {
  const result = rewriteHref({
    href: "https://example.com",
    fileDir: "/project/docs",
    oldTarget: "/project/docs/old.md",
    newTarget: "/project/archive/old.md",
    root: "/project",
  });
  expect(result).toBeUndefined();
});

describe("buildInternalRewriter", () => {
  const ctx = {
    oldDir: "/project/docs",
    newDir: "/project/archive",
    oldPath: "/project/docs/file.md",
    newPath: "/project/archive/file.md",
    root: "/project",
  };

  test("rewrites relative link after move", () => {
    const rw = buildInternalRewriter(ctx);
    expect(rw("./sibling.md", {} as never)).toBe("../docs/sibling.md");
  });

  test("preserves absolute link style", () => {
    const rw = buildInternalRewriter(ctx);
    expect(rw("/docs/sibling.md", {} as never)).toBe("/docs/sibling.md");
  });

  test("skips external urls", () => {
    const rw = buildInternalRewriter(ctx);
    expect(rw("https://example.com", {} as never)).toBeUndefined();
  });

  test("skips fragment-only", () => {
    const rw = buildInternalRewriter(ctx);
    expect(rw("#heading", {} as never)).toBeUndefined();
  });

  test("self-reference rewrites to new location", () => {
    const rw = buildInternalRewriter(ctx);
    expect(rw("./file.md", {} as never)).toBe("./file.md");
  });
});

describe("buildExternalRewriter", () => {
  test("rewrites link pointing to moved file", () => {
    const paths = {
      old: "/project/docs/guide.md",
      new: "/project/archive/guide.md",
      root: "/project",
    };
    const rw = buildExternalRewriter("/project/pages", paths);
    expect(rw("../docs/guide.md", {} as never)).toBe("../archive/guide.md");
  });

  test("ignores unrelated links", () => {
    const paths = {
      old: "/project/docs/guide.md",
      new: "/project/archive/guide.md",
      root: "/project",
    };
    const rw = buildExternalRewriter("/project/pages", paths);
    expect(rw("./other.md", {} as never)).toBeUndefined();
  });
});

describe("collectUrlEdits + applyEdits", () => {
  const paths = { old: "/project/docs/old.md", new: "/project/archive/old.md", root: "/project" };

  test("rewrites links in markdown source", () => {
    const source = "See [guide](./old.md) and [ref](./old.md#api).\n";
    const tree = parseMarkdown(source);
    const rw = buildExternalRewriter("/project/docs", paths);
    const edits = collectUrlEdits(source, tree, rw);
    expect(edits).toHaveLength(2);
    expect(applyEdits(source, edits)).toBe(
      "See [guide](../archive/old.md) and [ref](../archive/old.md#api).\n",
    );
  });

  test("no edits for unrelated content", () => {
    const source = "See [other](./other.md)\n";
    const tree = parseMarkdown(source);
    const rw = buildExternalRewriter("/project/docs", paths);
    expect(collectUrlEdits(source, tree, rw)).toHaveLength(0);
  });

  test("ignores links inside fenced code blocks", () => {
    const source = "```md\n[guide](./old.md)\n```\n";
    const tree = parseMarkdown(source);
    const rw = buildExternalRewriter("/project/docs", paths);
    expect(collectUrlEdits(source, tree, rw)).toHaveLength(0);
  });

  test("ignores links inside inline code", () => {
    const source = "Use `[guide](./old.md)` syntax.\n";
    const tree = parseMarkdown(source);
    const rw = buildExternalRewriter("/project/docs", paths);
    expect(collectUrlEdits(source, tree, rw)).toHaveLength(0);
  });
});

test("collectUrlEdits rewrites image links", () => {
  const source = "![diagram](./old.png)\n";
  const tree = parseMarkdown(source);
  const paths = { old: "/project/docs/old.png", new: "/project/assets/old.png", root: "/project" };
  const rw = buildExternalRewriter("/project/docs", paths);
  const edits = collectUrlEdits(source, tree, rw);
  expect(edits).toHaveLength(1);
  expect(applyEdits(source, edits)).toBe("![diagram](../assets/old.png)\n");
});

describe("applyEdits", () => {
  test("applies multiple non-overlapping edits", () => {
    const result = applyEdits("abcdefgh", [
      { offset: 0, length: 2, replacement: "XY" },
      { offset: 5, length: 3, replacement: "ZZZ" },
    ]);
    expect(result).toBe("XYcdeZZZ");
  });

  test("handles empty edits", () => {
    expect(applyEdits("hello", [])).toBe("hello");
  });
});
