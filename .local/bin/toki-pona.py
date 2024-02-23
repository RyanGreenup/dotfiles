#!/usr/bin/env python
import subprocess as sp
import sys
import os
from openai import OpenAI


def main():
    parse_args()


def help():
    print('''Toki Pona Helper

ai         Type English and get back toki Pona
dict       Get a fzf dictionary

          ''')


def parse_args():
    if len(sys.argv) < 2:
        help()
        sys.exit(1)
    match sys.argv[1]:
        case "ai":
            ai(' '.join(sys.argv[2:]))
        case "dict":
            fzf_dict()


def ai(input: str):
    client = OpenAI(
        # This is the default and can be omitted
        api_key=os.environ.get("OPENAI_API_KEY"),
    )

    stream = client.chat.completions.create(
        model="gpt-4",
        messages=[
            {
                "role": "system",
                "content": "You will take text in either English or Toki Pona and reply with the translation",
            },
            {
                "role": "user",
                "content": "This is a person.",
            },
            {
                "role": "assistant",
                "content": "ni li jan.",
            },
            {
                "role": "user",
                "content": "ni li kili.",
            },
            {
                "role": "assistant",
                "content": "This is fruit",
            },
            {
                "role": "user",
                "content": input,
            },
        ],
        stream=True,
    )
    for chunk in stream:
        print(chunk.choices[0].delta.content or "", end="")


def ai_b(input: str):
    client = OpenAI(
        # This is the default and can be omitted
        api_key=os.environ.get("OPENAI_API_KEY"),
    )

    chat_completion = client.chat.completions.create(
        messages=[
            {
                "role": "system",
                "content": "You will take text in either English or Toki Pona and reply with the translation",
            },
            {
                "role": "user",
                "content": "This is a person.",
            },
            {
                "role": "assistant",
                "content": "ni li jan.",
            },
            {
                "role": "user",
                "content": "ni li kili.",
            },
            {
                "role": "assistant",
                "content": "This is fruit",
            },
            {
                "role": "user",
                "content": input,
            },
        ],
        model="gpt-4",
    )

    print(chat_completion.choices[0].message.content)


def fzf_dict():
    HOME = os.getenv("HOME")
    assert HOME is not None, "Unable to get home directory"
    dict_file = f"{HOME}/Notes/Flashcards/toki-pona-dictionary.md"
    if not check_installed('fzf'):
        return
    sp.run(f"cat {dict_file} | fzf", check=True, shell=True)


def check_installed(bin: str) -> bool:
    PATH = os.environ.get("PATH")
    if PATH is None:
        print("PATH not set, unable to check for installed programs", file=sys.stderr)
    else:
        for d in PATH.split(':'):
            if os.path.exists(d):
                if bin in os.listdir(d):
                    return True
    return False


if __name__ == '__main__':
    main()
