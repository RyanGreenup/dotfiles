#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

"""
Utilities for scripts that can be reusused

Mostly schedule visualization scripts.
"""

import re
import sys


def check_valid_task(task: str) -> bool:
    """
    Checks if a task string is valid.
    """
    pattern = re.compile(r".*\d{1,2}:\d{2} - \d{1,2}:\d{2} .+")
    return bool(re.match(pattern, task))


def test_check_valid_task():
    assert check_valid_task("10:30 - 11:00 Finalise Quartz and MD Book Workflow")
    assert not check_valid_task("10:30 - 11:00")
    assert not check_valid_task("Finalise Quartz and MD Book Workflow")


test_check_valid_task()


def extract_times(task: str) -> tuple[str, str, str]|None:
    """
    Extracts the start and end times from a task string.
    """
    pattern = re.compile(r".*(\d{2}:\d{2}) - (\d{1,2}:\d{2}) (.+)")
    match = re.findall(pattern, task)
    try:
        start_time, end_time, description = match[0]
    except IndexError:
        print(f"Task {task} is not valid", file=sys.stderr)
        return None
    return start_time, end_time, description


def test_extract_times():
    task = "- [ ] 12:00 - 12:30 Write Note Dispatcher Screen (Py/Fish)"
    assert extract_times(task) == (
        "12:00",
        "12:30",
        "Write Note Dispatcher Screen (Py/Fish)",
    )


test_extract_times()
