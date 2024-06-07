#!/usr/bin/env python3
# Path: ~/.local/scripts/python/ollama_make-urls.p
import pyperclip
import ollama

def main():
    url = pyperclip.paste()
    formatted_link = get_formatted_link(url)
    pyperclip.copy(formatted_link)

def get_formatted_link(url: str) -> str:
    stream = ollama.chat(
        model="phi3",
        messages=make_messages(url),
        stream=True,
    )
    s = ""
    for i, chunk in enumerate(stream):
        if i == 0 and chunk["message"]["content"] != "[":
            return get_formatted_link()
        content = chunk["message"]["content"]
        s += content
        print(content, end="", flush=True)
        if is_valid_markdown_link(s):
            s += "\n"
            print("\n")
            return s
    return s



def make_messages(url: str):
    sys_prompt = """
    Create a well formatted markdown link. Include only the markdown link in the response.
    To do achieve this:
    1. Look at the URL and extract the domain and the url
    2. Combine the URL and the title to make the link description
    3. Combine the description with the url to make the link.
    """

    return [
        {"role": "system", "content": sys_prompt},
        { "role": "user", "content": "https://github.com/yizhongw/self-instruct"},
        { "role": "assistant", "content": "[Github: yizhongw / Self Instruct](https://github.com/yizhongw/self-instruct)"},
        { "role": "user", "content": "https://huggingface.co/cognitivecomputations/dolphin-2.6-mistral-7b-dpo"},
        { "role": "assistant", "content": "[Huggingface: Cognitive Computations / Dolphin 2.6 Mistral 7b DPO)"},
        {"role": "user", "content": "http://wikijs.eir/e/en/2024-05-01"},
        {"role": "assistant", "content": "[2024-05-01](http://wikijs.eir/e/en/2024-05-01)"},
        {"role": "user", "content": "http://wikijs.vidar/e/en/2024-06-01"},
        { "role": "assistant", "content": "[2024-06-01](http://wikijs.vidar/e/en/2024-06-01)"},
        {"role": "user", "content": "http://wikijs.eir/e/en/2024-06-01"},
        {"role": "assistant", "content": "[2024-06-01](http://wikijs.eir/e/en/2024-06-01)"},
        {"role": "user", "content": "http://wikipedia.com/en/2024-06-01"},
        { "role": "assistant", "content": "[Wikipedia: 2024-06-01](http://wikipedia.com/en/2024-06-01)"},
        {"role": "user", "content": "https://matplotlib.org/stable/users/explain/artists/color_cycle.html#color-cycle"},
        { "role": "assistant", "content": "[Matplotlib: Color Cycle Artists](https://matplotlib.org/stable/users/explain/artists/color_cycle.html#color-cycle)"},
        {"role": "user", "content": url}
    ]


def is_valid_markdown_link(s):
    stack = []
    flag = False
    brackets = {"[": "]", "(": ")"}

    for char in s:
        if char in brackets:
            if flag and char != "(":
                return False
            stack.append(char)
            flag = char == "["
        elif char in brackets.values():
            if not stack or brackets.get(stack[-1]) != char:
                return False
            stack.pop()
            flag = False
        else:
            flag = False
    return len(stack) == 0




if __name__ == '__main__':
    main()
