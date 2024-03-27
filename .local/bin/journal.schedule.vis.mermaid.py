#!/usr/bin/env python


import pyperclip
import sys
from utils import check_valid_task, extract_times


def tasks_to_mermaid(tasks_str):
    # Split the input string into lines, each representing a task
    tasks = tasks_str.strip().split("\n")

    # Initialize the Mermaid Gantt chart string
    mermaid_str = """```mermaid
gantt
    dateFormat HH:mm
    axisFormat %H:%M
    title Daily Schedule
    %% Tasks
    section Tasks
"""

    # Loop through each task to format it into Mermaid syntax
    for task in tasks:
        if not check_valid_task(task):
            print(f"not valid task {task}", file=sys.stderr)
            continue
        # Extract time range and task description
        start_time, end_time, description = extract_times(task)

        # Calculate duration
        # Assuming each task's start and end times are properly formatted and the end time is after the start time
        task_str = f"    {description} :active, {start_time}, {end_time}\n"

        # Append the task string to the Mermaid chart string
        mermaid_str += task_str

    # Close the Mermaid string
    mermaid_str += "```"

    return mermaid_str


# Example usage
tasks_input = """
10:30 - 11:00 Finalise Quartz and MD Book Workflow
11:00 - 12:00 Finish Ch. 1 of Statistical Learning in Finance
12:00 - 12:30 Write Note Dispatcher Screen (Py/Fish)
12:38 - 13:00 Merge all Notes off Dokuwiki and Mediawiki
13:08 - 15:00 Job Application for AE Capital
15:00 - 16:00 Gym
16:08 - 17:08 Cardio
17:39 - 18:39 Prepare for SDM
19:00 - 20:00 UHE -- Write up notes on Search Sort and Complexity Analysis
"""


def test_tasks_to_mermaid():
    tasks_input = """
17:39 - 18:39 Prepare for SDM
19:00 - 20:00 UHE -- Write up notes on Search Sort and Complexity Analysis
"""
    assert (
        tasks_to_mermaid(tasks_input)
        == """```mermaid\ngantt\n    dateFormat HH:mm\n    axisFormat %H:%M\n    title Daily Schedule\n    %% Tasks\n    section Ta
    sks\n    Prepare for SDM :active, 17:39, 18:39\n    UHE -- Write up notes on Search Sort and Complexity Analysis :active, 19:00
    , 20:00\n```"""
    )


if __name__ == "__main__":
    # Convert to Mermaid chart
    input = pyperclip.paste()
    mermaid_chart = tasks_to_mermaid(input)
    pyperclip.copy(mermaid_chart)
    print(mermaid_chart)
