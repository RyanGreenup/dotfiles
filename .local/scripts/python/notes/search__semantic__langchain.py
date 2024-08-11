import ollama
import chromadb
from langchain_community.document_loaders import DirectoryLoader
from langchain_text_splitters import CharacterTextSplitter
import os
from tqdm import tqdm
from langchain_community.vectorstores import FAISS
from langchain_community.embeddings import OllamaEmbeddings


db_path = "/tmp/data.faiss"
HOME = os.getenv("HOME")
assert HOME, "HOME environment variable not set"
# TODO change this directory
NOTES_DIR = f"{HOME}/Notes/slipbox/"


def get_text_chunks():
    """
    A function to get text files from a directory, split per size
    and return text and filename
    """
    # Create a directory Loader [fn_docs_doc_loader]
    loader = DirectoryLoader(
        NOTES_DIR,
        glob="**/*.md",
        show_progress=True,
        use_multithreading=True,
        silent_errors=True,
    )

    # Load the documents
    documents = loader.load()

    # Chunk the documents
    n = 500
    text_splitter = CharacterTextSplitter(chunk_size=n, chunk_overlap=0)
    texts = text_splitter.split_documents(documents)

    return texts


# 1. Generate Embeddings .......................................................
embeddings = ollama_emb = OllamaEmbeddings(
    model="mxbai-embed-large",
)

if os.path.exists(db_path):
    try:
        db = FAISS.load_local(db_path, embeddings, allow_dangerous_deserialization=True)
    except Exception:
        db = FAISS.load_local(db_path, embeddings)
else:
    # Create the vector store
    db = FAISS.from_documents(get_text_chunks(), embeddings)
    db.save_local(db_path)

# 2. Retreive ..................................................................

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
