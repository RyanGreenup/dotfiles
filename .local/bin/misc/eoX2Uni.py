#!/usr/bin/env python3
import sys

# Convert esperanto using the h-system or x-system into english

replace_dict = {
        "ch": "ĉ",
        "gh": "ĝ",
        "jh": "ĵ",
        "sh": "ŝ",
        "kh": "ĥ",
         "u": "ŭ",
        "cx": "ĉ",
        "gx": "ĝ",
        "hx": "ĥ",
        "jx": "ĵ",
        "sx": "ŝ",
        "ux": "ŭ",
        }

for line in sys.stdin:
    for key in replace_dict:
        value = replace_dict[key]
        line = line.replace(key, value)


print(line, end = "")
