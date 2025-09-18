import { DOMParser } from "https://deno.land/x/deno_dom@v0.1.45/deno-dom-wasm.ts";

async function getClipboardContent(): Promise<string> {
  // Try different clipboard tools in order of preference
  const clipboardCommands = [
    // Linux X11
    { command: "xclip", args: ["-selection", "clipboard", "-o"] },
    // Linux Wayland
    { command: "wl-paste", args: [] },
    // macOS
    { command: "pbpaste", args: [] },
  ];

  for (const { command, args } of clipboardCommands) {
    try {
      const process = new Deno.Command(command, {
        args,
        stdout: "piped",
        stderr: "piped",
      });

      const { code, stdout } = await process.output();

      if (code === 0) {
        const content = new TextDecoder().decode(stdout).trim();
        if (content) {
          return content;
        }
      }
    } catch {
      // Command not found, try next one
      continue;
    }
  }

  throw new Error(
    "No clipboard tool found. Please install one of: xclip, wl-clipboard, or use macOS pbpaste"
  );
}

export async function createMarkdownLink(url: string): Promise<string> {
  try {
    // Fetch the page content
    const response = await fetch(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
      }
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const html = await response.text();
    const doc = new DOMParser().parseFromString(html, "text/html");
    
    if (!doc) {
      throw new Error("Failed to parse HTML");
    }
    
    // Try to get the best title in order of preference
    let title = '';
    
    // 1. Try Open Graph title (both property and name attributes)
    const ogTitle = doc.querySelector('meta[property="og:title"]')?.getAttribute('content') ||
                   doc.querySelector('meta[name="og:title"]')?.getAttribute('content');
    if (ogTitle) {
      title = ogTitle;
    }
    // 2. Try Twitter title
    else {
      const twitterTitle = doc.querySelector('meta[name="twitter:title"]')?.getAttribute('content');
      if (twitterTitle) {
        title = twitterTitle;
      }
      // 3. Fall back to regular title tag
      else {
        const titleElement = doc.querySelector('title');
        if (titleElement) {
          title = titleElement.textContent || '';
        }
      }
    }
    
    // Clean up the title
    title = title.trim();
    
    // If no title found, use the domain name
    if (!title) {
      const urlObj = new URL(url);
      title = urlObj.hostname;
    }
    
    // Create the markdown link
    return `[${title}](${url})`;
    
  } catch (error) {
    // If fetching fails, return a basic link with the domain
    try {
      const urlObj = new URL(url);
      return `[${urlObj.hostname}](${url})`;
    } catch {
      // If URL is invalid, return the original URL
      return url;
    }
  }
}

// Get URL from clipboard and create markdown link
if (import.meta.main) {
  try {
    // Get URL from clipboard
    const clipboardContent = await getClipboardContent();
    
    if (!clipboardContent) {
      console.error("Clipboard is empty");
      Deno.exit(1);
    }
    
    // Validate that it's a URL
    try {
      new URL(clipboardContent);
    } catch {
      console.error("Clipboard content is not a valid URL:", clipboardContent);
      Deno.exit(1);
    }
    
    // Create and output the markdown link
    const markdownLink = await createMarkdownLink(clipboardContent);
    console.log(markdownLink);
    
  } catch (error) {
    console.error("Error:", error.message);
    Deno.exit(1);
  }
}