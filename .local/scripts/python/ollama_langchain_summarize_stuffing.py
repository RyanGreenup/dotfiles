#!/usr/bin/env python3
# Path: /home/ryan/.local/scripts/python/ollama_langchain_summarize.py
# -*- coding: utf-8 -*-

# %pip install --upgrade --quiet  langchain-openai tiktoken chromadb langchain langchainhub

from langchain_community.llms import Ollama
from langchain_core.prompts import PromptTemplate
from langchain_openai import ChatOpenAI
from langchain_community.document_loaders import WebBaseLoader
from langchain_community.document_loaders import UnstructuredHTMLLoader
from langchain.chains.summarize import load_summarize_chain
from langchain.chains.combine_documents.stuff import StuffDocumentsChain
from langchain.chains.llm import LLMChain
import os


prompt_template = """
## Instruction
Summarize the document below into a highly structured markdown document that includes all the key points and details.

To acheive this follow these steps:

1. Read the document carefully.
2. Identify the Subject Areas
3. Identify the Key Points of each subject area
4. Write a summary of each subject area

## Example Output
### <Subject Area 1>
#### Key Points
- <Point 1>
- <Point 2>
#### Summary
<flowing text>

## Input Text
{text}
"""

prompt = PromptTemplate.from_template(prompt_template)

# Get the docs
loader = UnstructuredHTMLLoader(
    "/home/ryan/Downloads/How to handle mdma more appropriately_ _ aves (5_1_2024 2_57_39 PM).html"
)
docs = loader.load()

# Set the LLM
llm = Ollama(model="command-r")
llm_chain = LLMChain(llm=llm, prompt=prompt)
stuff_chain = StuffDocumentsChain(
    llm_chain=llm_chain, document_variable_name="text")


# Run the Chain
print(stuff_chain.run(docs))
