#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

"""
Your module-level docstring explaining this script's primary function or role.
Add any relevant usage instructions and notes about expected inputs/outputs.
"""

import os
import tempfile

semantic_models = {
    "BAII": "BAAI/bge-large-en-v1.5",
    "bert": "google-bert/bert-base-uncased",
    "sf-mistral": "Salesforce/SFR-Embedding-Mistral",
}


class Config:
    def __init__(
        self,
        notes_dir: str,
        editor: str,
        search_dir: str,
        search_file: str,
        semantic_model: str,
        sem_search_dir: str,
    ):
        self.notes_dir = notes_dir
        self.editor = editor
        # The directory to hold the search cache
        self.search_cache_dir = search_dir
        self.search_cache_file = search_file  # The jsonlines file for tantivy
        self.semantic_model = semantic_model
        self.sem_search_dir = sem_search_dir

    def __str__(self) -> str:
        return f"Notes Dir: {self.notes_dir}"

    @staticmethod
    def default():
        HOME = os.getenv("HOME")
        assert HOME, "HOME var unavailable"
        notes_dir = f"{HOME}/Notes/slipbox"
        editor = "nvim"
        search_dir = f"{HOME}/.cache/python__tantivy__notes__search"
        search_file = tempfile.mktemp(suffix=".jsonl")
        semantic_model = semantic_models["BAII"]
        sem_search_dir = f"{HOME}/.cache/python__semantic__notes__search"

        return Config(
            notes_dir, editor, search_dir, search_file, semantic_model, sem_search_dir
        )

        if __name__ == "__main__":
            pass
