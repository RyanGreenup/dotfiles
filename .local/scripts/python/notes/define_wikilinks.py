#!/usr/bin/env python3
import sys
import re


def process_lines(input_lines):
    # The ?: is a non-capturing group
    pattern = re.compile(r"(?:^|\s)\[\[(.*?)\]\](?:$|\s)")
    links = []
    for line in input_lines:
        try:
            matches = pattern.findall(line)
            links.extend(m for m in matches)
        except re.error as e:
            print(f"Error with Regex: {e}")
        except Exception as e:
            print(f"Unexpected error: {e}")

    return links


def main():
    links = process_lines(sys.stdin)
    for link in links:
        print(f"[{link}]: {link}.md")


if __name__ == "__main__":
    main()
