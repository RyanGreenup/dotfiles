#!/usr/bin/env python3
from ollama import Client
import sys


if len(sys.argv) <= 1:
    raise ValueError("Please provide a message to send to the model.")
else:
    message = sys.argv[1]

model = "codestral:latest"
if len(sys.argv) > 2:
    model = sys.argv[2]

host = "vale"
if len(sys.argv) > 3:
    host = sys.argv[3]


# print(message, model, host)

client = Client(host=f"http://{host}:11434")


stream = client.chat(
    model=model,
    messages=[{"role": "user", "content": message}],
    stream=True,
)

for chunk in stream:
    print(chunk["message"]["content"], end="", flush=True)
