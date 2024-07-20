#!/usr/bin/env python3

import os
import pyperclip
from openai import OpenAI
import sys


def main(prompt: str | None):
    if not prompt:
        prompt = pyperclip.paste()

    client = OpenAI(
        base_url="http://localhost:11434/v1",
        api_key="ollama",  # required, but unused
    )

    HOME = os.path.expanduser("~")
    with open(f"{HOME}/.local/scripts/assets/latex/sys.md") as f:
        sys = f.read()
    with open(f"{HOME}/.local/scripts/assets/latex/user.md") as f:
        user = f.read() + prompt

    response = client.chat.completions.create(
        model="codellama",
        messages=[
            {"role": "system", "content": sys},
            {"role": "user", "content": user},
        ],
        stream=True,
    )

    output = ""
    for chunk in response:  # Iterate over the real-time stream of text
        c: str = chunk.choices[0].delta.content  # type:ignore
        output += c
        print(c, end="", flush=True)

    pyperclip.copy(output)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        main(sys.argv[1])
    else:
        main(None)
