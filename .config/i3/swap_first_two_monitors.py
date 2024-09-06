#!/usr/bin/env python3

import json
from subprocess import run, PIPE

# Get the current i3 configuration
out = run(["i3-msg", "-t", "get_outputs"], stdout=PIPE, text=True)
# Parse the Dict
config = json.loads(out.stdout)

print(json.dumps(config[1], indent=4))


# Swap the montiros
# 0th entry is xroot
for i in range(1, 3):
    name = config[i]["name"]
    wspace = config[i]["current_workspace"]

    print("Moving", name, "to", wspace)

    run(["i3-msg", "--", "workspace", "--no-auto-back-and-forth", wspace])
    run(["i3-msg", "--", "move workspace to output right"])

# For Debugging sake, the following works too

# name_1 = config[1]["current_workspace"]
# name_2 = config[2]["current_workspace"]
# monitor_1 = config[1]["name"]
# monitor_2 = config[2]["name"]


# run(["i3-msg", "--", "workspace", "--no-auto-back-and-forth", name_1])
# run(["i3-msg", "--", f"move workspace to output {monitor_2}"])
#
# run(["i3-msg", "--", "workspace", "--no-auto-back-and-forth", name_2])
# run(["i3-msg", "--", f"move workspace to output {monitor_1}"])
