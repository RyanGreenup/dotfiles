#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-


# ..............................................................................
# This doesn't follow the ./template.py as it was written earlier .............
#      It also does not use the config.py for configuration ...................
# ..............................................................................


# TODO benchmark inferencing on CPU rather than GPU
# Obviously, the encoding is faster on GPU, but the retrieval may be
# faster on CPU as the data doesn't need to be transferred back and forth

# TODO is the inference on CPU or GPU?

import sys
import os
import torch
import time
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_text_splitters import CharacterTextSplitter
from langchain_community.vectorstores import FAISS
from langchain_community.document_loaders import DirectoryLoader

HOME = os.getenv("HOME")
assert HOME is not None, "HOME is not set"

NOTES_DIR = f"{HOME}/Notes/slipbox"
if len(sys.argv) > 1:
    NOTES_DIR = sys.argv[1]

# Create a directory Loader [fn_docs_doc_loader]
loader = DirectoryLoader(
    NOTES_DIR,
    glob="**/*.md",
    show_progress=True,
    use_multithreading=True,
    silent_errors=True,
)

# Create an Embeddings model
model_name = "google-bert/bert-base-uncased"
model_name = "Salesforce/SFR-Embedding-Mistral"
model_name = "BAAI/bge-small-en-v1.5"
model_name = "BAAI/bge-large-en-v1.5"
device = "cuda" if torch.cuda.is_available() else "cpu"
device = "cpu"
# TODO how to embed ones and then not load the embeddings model again?
#      probably is to use the `embed_documents` method
# TODO consider
# https://huggingface.co/avsolatorio/NoInstruct-small-Embedding-v0
# https://huggingface.co/liddlefish/privacy_embedding_rag
# https://huggingface.co/avsolatorio/GIST-small-Embedding-v0
# TODO embed on gpu but inference on CPU -- faster?
model_kwargs = {"device": device}
encode_kwargs = {"normalize_embeddings": False}
print("loading Embeddings model...")
start = time.time()
embeddings = HuggingFaceEmbeddings(
    model_name=model_name, model_kwargs=model_kwargs, encode_kwargs=encode_kwargs
)
print(f"loaded Embeddings model in {time.time() - start:.2f} seconds")

# Embed the documents
# (We can manually embed the documents, but let the retriever do it
# embeddings = hf.embed_documents([text for text, _ in tqdm(text_chunks[:10])])

# Create the vector store and add the documents

xdg_cache_direnv = os.getenv("XDG_CACHE_HOME")

dir_m = model_name.replace("/", "--")
dir_n = NOTES_DIR.replace(HOME, "").replace("/", "", 1).replace("/", "--")
dirname = f"go_notetaking/semantic_search/{dir_m}/{dir_n}"
if xdg_cache_direnv is not None:
    cache_dir = f"{xdg_cache_direnv}/{dirname}"
else:
    cache_dir = f"{HOME}/.cache/{dirname}"

db_path = f"{cache_dir}/faiss_db"
if os.path.exists(db_path):
    print("")
    print(f"[py]: Detected embeddings at {db_path}... loading...")
    print("[py]: To regenerate the embeddings:")
    print("[py]:    ```")
    print(f"[py]:    rm -rf {db_path}")
    print("[py]:    ```")
    print("[py]: and re-run this script.")

    # Some versions don't support the allow_dangerous_deserialization flag
    # dump this db and if this db exists, then don't bother loading the embeddings
    # https://www.reddit.com/r/LangChain/comments/1bpqoiz/faissload_local_is_so_slow/

    # TODO read this https://www.reddit.com/r/LangChain/comments/17iaajt/what_is_the_simplest_vector_store_to_use_which/
    # https://python.langchain.com/v0.2/docs/integrations/vectorstores/
    # https://python.langchain.com/v0.2/docs/integrations/vectorstores/chroma/
    print("[py]: Loading the embeddings...")
    start = time.time()
    try:
        db = FAISS.load_local(db_path, embeddings,
                              allow_dangerous_deserialization=True)
    except Exception:
        db = FAISS.load_local(db_path, embeddings)
    # 90 s on gpu
    print(f"[py]: Loaded the embeddings in {time.time() - start:.2f} seconds")


else:
    print(f"[py]: Writing embeddings to {db_path}... saving ...")
    # Load the documents
    documents = loader.load()

    # Chunk the documents
    n = 500
    text_splitter = CharacterTextSplitter(chunk_size=n, chunk_overlap=0)
    texts = text_splitter.split_documents(documents)

    # Create the vector store
    db = FAISS.from_documents(texts, embeddings)
    db.save_local(f"{cache_dir}/faiss_db")


# Create the retriever
k = 10
retriever = db.as_retriever(search_kwargs={"k": k})


while True:
    for i in range(4):
        print()
    # Get the query
    query = input("Enter a search term: ")

    # Get the relevant documents
    docs = retriever.invoke(query)

    # reverse the docs for terminal use
    docs = docs[::-1]

    # Print the results
    for d in docs:
        print(d.metadata["source"])

        # Could I use bat or highlight here somehow?
        for i in range(4):
            content = d.page_content[i * 80 : ((i + 1) * 80 - 8)]
            content = content.replace("\n", " ")
            print("\t", content)
        else:
            print()


# [fn_docs_doc_loader]: https://python.langchain.com/docs/modules/data_connection/document_loaders/file_directory
