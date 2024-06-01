#!/usr/bin/env python3
# /home/ryan/.local/scripts/python/notes/yaml_remove.py
# remove_yaml_header.py

import sys
import re

def remove_yaml_header(file_path, max_yaml_lines=100, max_depth=5):
    """
    max_yaml_lines: Maximum number of lines to consider as Yaml header.
    max_depth: Maximum number of lines before start of yaml header
    """
    with open(file_path, 'r') as file:
        content = file.readlines()

    inside_code_block = False


    start_line_yaml_header: int
    yaml_header = []
    for i in range(min(max_depth, len(content))):
        lc = content[i].strip()
        if lc == '```':
            inside_code_block = not inside_code_block
        if lc == '---' and not inside_code_block:
            start_line_yaml_header = i
            for line in content[i+1:]:
                yaml_header.append(line)
                if (lc := line.strip()) == '---':
                    yaml_header.append(lc)
                    break
            break

    if len(yaml_header) > max_yaml_lines or len(yaml_header) == 0:
        print(f"No Yaml header found within the first 5 lines or Yaml header is more than {max_yaml_lines} lines.")
        return

    with open(file_path, 'w') as file:
        new_content = content[:start_line_yaml_header]
        new_content += content[start_line_yaml_header+len(yaml_header):]
        file.writelines(new_content)

    print(f'Removed Yaml header from file. Header had {len(yaml_header)} lines.')

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: remove_yaml_header.py <markdown_file_path>")
        sys.exit(1)

    markdown_file_path = sys.argv[1]
    remove_yaml_header(markdown_file_path)

