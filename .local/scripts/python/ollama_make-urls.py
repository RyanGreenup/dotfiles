#!/usr/bin/env python3
# Path: ~/.local/scripts/python/ollama_make-urls.p
import pyperclip
import ollama
 # -*- coding: utf-8 -*-

url = "http://flarum.eir/d/130-melbourne-eats"


############################################################
# Parse with Ollama ########################################
############################################################


def build_prompt(url: str) -> str:
    return f"""
    ## Instruction
    Create a well formatted markdown link. Include only the markdown link in the response.
    To do achieve this:
    1. Look at the URL and extract the domain and the url
    2. Combine the URL and the title to make the link description
    3. Combine the description with the url to make the link.
    ## Example
    input: https://old.reddit.com/r/Berghain_Community/comments/1427nv6/ghbgbl_harm_reduction_guide/
    output: [Reddit: GHB/GBL Harm Reduction Guide](https://old.reddit.com/r/Berghain_Community/comments/1427nv6/ghbgbl_harm_reduction_guide/)
    input: https://huggingface.co/cognitivecomputations/dolphin-2.6-mistral-7b-dpo
    output: [Huggingface: Cognitive Computations / Dolphin 2.6 Mistral 7b DPO)
    input: http://wikijs.eir/e/en/2024-05-01
    output: [2024-05-01](http://eir.vidar/e/en/2024-05-01)
    input: http://wikijs.vidar/e/en/2024-06-01
    output: [2024-06-01](http://eir.vidar/e/en/2024-06-01)
    input: http://wikijs.eir/e/en/2024-06-01
    output: [2024-06-01](http://wikijs.eir/e/en/2024-06-01)
    input: http://wikipedia.com/en/2024-06-01
    output: [Wikipedia: 2024-06-01](http://wikipedia.com/en/2024-06-01)
    ## Input
    {url}
    """


url = pyperclip.paste()


global_s = ""
for url in pyperclip.paste().split("\n"):
    stream = ollama.chat(
        model="phi3",
        messages=[
            {"role": "user", "content": build_prompt(url)},
        ],
        stream=True,
    )

    # TODO use a stack to find when we have []().
    s = ""
    for chunk in stream:
        content = chunk["message"]["content"]
        s += content
        print(content, end="", flush=True)
    global_s += "- " + s + "\n"

pyperclip.copy(global_s)
