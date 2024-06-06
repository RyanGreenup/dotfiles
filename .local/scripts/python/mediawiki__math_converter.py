#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

"""
a Python script that reads stdin and performs find and replace operations described by the following examples:


- Input
    ```
    <math display="block">
    . \\ anything

    \foo{}
    {\bar} in here
    </math>
    ```
- Output
    ```
    $$
    . \\ anything

    \foo{}
    {\bar} in here
    $$
    ```
- Input
    ```
    <math>
    . \\ anything

    \foo{}
    {\bar} in here
    </math>
    ```
- Output
    ```
    $$
    . \\ anything

    \foo{}
    {\bar} in here
    $$
    ```
- Input
    ```
    <math display="inline">
    . \\ anything

    \foo{}
    {\bar} in here
    </math>
    ```
- Output
    ```
    $. \\ anything \foo{} {\bar} in here$
    ```
"""
import re
import sys

last_was_display = False

for line in sys.stdin:
    if '<math display="block">' in line or '<math>' in line:
        # replace <math display="block"> and <math> with $$
        line = re.sub(r'<math( display="block")?>', '$$', line)
        last_was_display = True
        # replace closing tags accordingly
        line = re.sub(r'</math>', '$$', line)
    elif '<math display="inline">' in line:
        last_was_display = False
        # replace <math display="inline"> with $
        line = re.sub(r'<math display="inline">', '$', line)
        # replace closing tags accordingly
        line = re.sub(r'</math>', '$', line)
    elif '</math>' in line:
        if last_was_display:
            line = re.sub(r'</math>', '$$', line)
        else:
            line = re.sub(r'</math>', '$', line)

    sys.stdout.write(line)
