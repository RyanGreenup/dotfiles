#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

import sys

"""
Your module-level docstring explaining this script's primary function or role.
Add any relevant usage instructions and notes about expected inputs/outputs.
"""

for line in sys.stdin:
    # sys.stdout.write(line.replace('\\\\', '\\cr'))
    # \newline is now supported in katex, \cr is for tables
    sys.stdout.write(line.replace("\\\\", "\\newline"))
