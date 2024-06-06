#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

import json
import requests
import re
import ollama
import os
from ollama import Client

model = "command-r"

HOME = os.getenv("HOME")
assert HOME, "HOME variable undefined"
with open(f"{HOME}/.local/keys/flarum.key", "r") as f:
    token = f.read().strip()
url = "http://flarum.eir/d/130-melbourne-eats"

############################################################
# Get Flarum Content #######################################
############################################################


def consume_flarum_api(token, discussion_id: str, verbose=False) -> dict:
    """
    This function sends a GET request to given Flarum REST API endpoint using the provided token.

    Args:
        token (str): Token for Flarum REST API
        endpoint (str): Flarum endpoint to access

    Returns:
        Response content (json) or an error message.
    """
    endpoint = "/api/discussions/" + discussion_id
    base_url = "http://flarum.eir"  # replace 'community.example.com' with actual domain
    headers = {"Authorization": f"Token {token}",
               "Content-Type": "application/json"}
    try:
        response = requests.get(f"{base_url}{endpoint}", headers=headers)
        response.raise_for_status()  # raises HTTPError if status code is not 200
    except requests.exceptions.RequestException as err:
        raise err
    else:
        out = response.json()
        if verbose:
            print(json.dumps(out, indent=4, sort_keys=True))
        return response.json()


def get_all_links(discussion_id: str) -> list[str]:
    """
    Loop Through a dictionary and get back all values that have "http" in them
    """
    d = consume_flarum_api(token, discussion_id)
    links = []
    for k, v in d.items():
        IdentityFunction
        IdentityFunction
        if isinstance(v, dict):
            links.extend(get_all_links(discussion_id))
        elif isinstance(v, list):
            for i in v:
                links.extend(get_all_links(i))
        elif "http" in str(v):
            links.append(v)

    # use Regex to get the url
    links = [
        re.search(r"(?P<url>https?://[^\s]+)", link).group("url") for link in links
    ]
    return links


def get_markdown_from_flarum(discussion_id: str) -> str:
    out = consume_flarum_api(token, discussion_id)
    s = ""
    for i in out["included"]:
        if i["type"] == "posts":
            try:
                s += i["attributes"]["content"]
            except KeyError:
                pass
    return s


############################################################
# Parse with Ollama ########################################
############################################################

old_prompt = """
Here is an example of a markdown document with links:

www.google.com is a search engine but I often prefer browsing via wikipedia.com as it has many articles.

To extract the links from this document as a markdown list, rewrite it as follows (without any other text):


- [Google](www.google.com)
    - A search engine
- [Wikipedia](wikipedia.com)
    - A website with many articles
    - Preferred for browsing over Google


You will be given a similar markdown document and you are tasked with extracting the links as a markdown list. Each item will be a formatted markdown link with a subitem as a description inferred from surrounding context and and the url.

When writing the descriptions, follow these guidelines:

1. Ensure that sub items are an indented list under the main item. The indent should be four spaces. Use a `-` to represent the list item following markdown guidelines.
2. The number of the subject determines the number of the verb
Use the proper case of pronoun
3. A participal phrase at the beginning of a sentence or phrase must refer to the grammatical subject
4. Use the Active Voice
5. Put statements in the active voice
6. Put statements in positive form
7. Use definite, specific, concrete language
8. Omit needless words
9. Keep related words together
10. Keep to one tense
11. Place the emphatic words of a sentence at the end
12. Include each link only once.
14. The output should be a single list of these links


Above all else, always strive to preserve the meaning in the original text. Make sure to include all links in the markdown list.


"""


def build_input_prompt(source_markdown: str) -> str:
    return f"""
## Instruction
Return a list of markdown urls from the given markdown document. to do so,
follow these steps:

1. Read carefully through the entire document
2. Identify all the urls in the document
    - For example anything with `http://`, `https://` or `www.` in it is very
      likely to be a url
3. Looking at the url and the surrounding text, determine an appropriate title
4. Looking at the the surrounding text, determine an appropriate description
5. Using the url, title and description, create a markdown url.
6. Check that the url is listed in the input, only return it if the url / URL is in the input source

Ensure that:
    - urls are built exclusively from the markdown document and not from any other source.
    - There are new lines between each url, its description and the next

## Example Output

- [<title>](<url>)
    - <description>
- [<title>](<url>)
    - <description>

## Input Text
{source_markdown}

"""



for i in range(5, 200):
    try:
        source_markdown = get_markdown_from_flarum(discussion_id=str(i))
    except Exception:
        continue

    client = Client(host="http://localhost:11434")
    stream = client.chat(
        model=model,
        messages=[
            {"role": "user", "content": build_input_prompt(source_markdown)}],
        stream=True,
    )

    # stream = ollama.chat(
    #    model=model,
    #    messages=[
    #        {"role": "user", "content": build_input_prompt(source_markdown)}],
    #    stream=True,
    # )

    for chunk in stream:
        content = chunk["message"]["content"]
        print(content, end="", flush=True)
    print("")
