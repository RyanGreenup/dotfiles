#!/usr/bin/env python3
# Path: ~/.local/scripts/python/ollama.py
# -*- coding: utf-8 -*-
import ollama
import os
import typer

os.chdir(os.path.dirname(os.path.abspath(__file__)))


def main(prompt_file: str, system_file: str, prompt: str):
    out_dir = "/tmp/ollama_responses"
    try:
        os.mkdir(out_dir)
    except FileExistsError:
        pass

    with open(prompt_file, "r") as f:
        system = f.read()

    with open(system_file, "r") as f:
        input = f.read()

    filename = make_filename(prompt)
    input += prompt

    stream = ollama.chat(
        model="llama3",
        messages=[
            {"role": "system", "content": system},
            {"role": "user", "content": input},
        ],
        stream=True,
    )

    write_and_stream(stream, filename)

    print("\n\nFile saved as:\n")
    print(os.path.join(out_dir, filename))


def make_filename(prompt: str) -> str:
    input = """
Convert the following into a filename for an article about that topic.

Here are three examples:

  * 1
      - input: How to convert a docker run command to a docker-compose file?
      - output: convert-docker-run-command-docker-compose-file.md

  * 2
      - input: How to install a package using pip?
      - output: install-package-using-pip.md

  * 3
      - input: How to install a package using apt-get?
      - output: install-package-using-apt-get.md

It is crucial that you only return the filename and no other context.
The replies should be as shown above, only the filename.

Here is the prompt that you will turn into a filename:

"""
    input += prompt
    stream = ollama.chat(
        model="llama3",
        messages=[{"role": "user", "content": input}],
        stream=False,
    )

    filename = stream["message"]["content"]  # pyright:ignore

    # If the filename is too long, try again
    if len(filename) > 100:
        filename = make_filename(prompt)

    # If the first character is / remove it
    if filename[0] == "/":
        filename = filename[1:]
    # If the last character is / remove it
    if filename[-1] == "/":
        filename = filename[:-1]

    replaces = [(" ", "-"), ("?", ""), (",", "")]
    for r in replaces:
        filename = filename.replace(r[0], r[1])

    return filename


def write_and_stream(stream, filename):
    filename = os.path.join("/tmp/ollama_responses", filename)
    with open(filename, "w") as f:
        f.write("")
    for chunk in stream:
        out = chunk["message"]["content"]
        print(out, end="", flush=True)
        with open(filename, "a") as f:
            f.write(out)


if __name__ == "__main__":
    typer.run(main)
