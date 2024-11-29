#!/usr/bin/env python3
from ollama import Client
import sys
import os
import notify2

# pip install dbus-python notify2
notify2.init("Ollama Streaming")

if len(sys.argv) <= 1:
    if sys.stdin:
        # Collect stdin
        message = ""
        for line in sys.stdin:
            message += line
    else:
        raise ValueError(" No STDIN Please provide a message to send to the model.")
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
    messages=[{"role": "user", "content": "you will be given some text and you are tasked with continuing it on, here is the text: " + message}],
    stream=True,
)

# Print the message so it isn't lost after calling vim replace with :'<,'>!
# vmap <F1> <cmd>'<,'>! /home/ryan/.local/scripts/python/ollama_stream-message.py<CR>
print(message)
current_line = ""
notification = notify2.Notification("Ollama", "Started Stream")
notification_id = notification.show()  # Show the notification and get its ID
the_message = ""
for chunk in stream:
    current_chunk = chunk["message"]["content"]  # type:ignore
    the_message += current_chunk
    current_line += current_chunk
    if "\n" in current_line:
        # os.system('notify-send "Ollama" "{}"'.format(current_line))
        current_line = ""
        notification.close()  # This will close the notification
        notification = notify2.Notification("Ollama", the_message)
        notification_id = notification.show()  # Show the notification and get its ID
    print(current_chunk, end="", flush=True)
