#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

# This calls Ollama on the CPU not connecting to the server
import ollama
import pyperclip

with open("/tmp/ollama_top") as f:
    top = f.read().strip()

with open("/tmp/ollama_bottom") as f:
    bottom = f.read().strip()


prompt = f"""<PRE> {top} <SUF>{bottom} <MID>"""
print(prompt)

stream = ollama.chat(
        model="codellama:7b-code",
    messages=[
        {"role": "user", "content": prompt},
    ],
    stream=True,
)


s = ""
for chunk in stream:
    content = chunk["message"]["content"]
    s += content
    print(content, end="", flush=True)

with open("/tmp/ollama_out", "w") as f:
    f.write(s)

s = s.replace('<EOT>', '')
# Now join them all together
s = top + s + bottom

pyperclip.copy(s)
