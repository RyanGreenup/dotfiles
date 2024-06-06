#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-


from datetime import datetime
import numpy as np
import matplotlib.dates as mdates
import matplotlib.pyplot as plt
import pandas as pd
from utils import check_valid_task, extract_times
import pyperclip
import os


def main():
    today = datetime.today().strftime("%Y-%m-%d")
    # Wed 3 sep 2025
    today_title = datetime.today().strftime("%a %d %b %Y")
    HOME = os.getenv("HOME")
    assert HOME is not None, "HOME is not set"
    filepath = f"{HOME}/Notes/slipbox/journals/assets/{today}.schedule.png"
    fig = plot_schedule(pyperclip.paste(),
                        title_date=today_title, return_fig=True)
    fig.savefig(filepath, dpi=300, bbox_inches="tight")
    print(f"Saved to {filepath}")
    print("")
    print(f"![](assets/{today}.schedule.png)")


# Import necessary standard Python libraries


def tasks_to_df(schedule_list: str):
    # Split the tasks into lines
    activities = [t for t in schedule_list.split("\n") if t]
    # Check they'r valid
    activities = [t for t in activities if check_valid_task(t)]
    # Get the start end and description
    activities = [extract_times(i) for i in schedule_list.split("\n") if extract_times(i)]
    # Store activities in a df
    activity_df = pd.DataFrame(
        activities, columns=["Start", "End", "Activity"])
    print(activity_df)
    # Convert time strings to datetime objects
    activity_df[["Start", "End"]] = activity_df[["Start", "End"]].apply(
        lambda x: [mdates.date2num(datetime.strptime(i, "%H:%M")) for i in x]
    )

    return activity_df


def plot_schedule(schedule_list, return_fig=False, title_date: str = None):
    activity_df = tasks_to_df(schedule_list)

    # Plotting
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.set_xlim(
        mdates.date2num(datetime.strptime("00:00", "%H:%M")),
        mdates.date2num(datetime.strptime("23:59", "%H:%M")),
    )
    ax.xaxis_date()
    ax.get_yaxis().set_visible(False)
    ax.invert_yaxis()

    for idx, row in activity_df.iterrows():
        ax.barh(
            idx,
            row["End"] - row["Start"],
            left=row["Start"],
            height=0.5,
            align="center",
            color="skyblue",
            edgecolor="black",
            linewidth=1,
        )
        ax.text(row["Start"] + 0.01, idx, row["Activity"],
                fontsize=10)  # add labels

    if title_date:
        ax.set_title(title_date)
    else:
        ax.set_title("Day Schedule")
    ax.set_xlabel("Time")
    ax.set_yticks(np.arange(len(activity_df)))
    ax.set_yticklabels(activity_df["Activity"])
    ax.xaxis.set_major_locator(
        mdates.HourLocator(byhour=range(0, 24, 1))
    )  # set major ticks at each hour
    ax.xaxis.set_minor_locator(
        mdates.HourLocator(byhour=range(0, 24, 2))
    )  # set minor ticks at half hours
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M"))
    # add solid lines for each hour
    ax.grid(True, which="major", color="black", linestyle="-")
    # add dotted lines for half hours
    ax.grid(True, which="minor", color="black", linestyle=":")
    plt.xticks(rotation=45)

    if return_fig:
        return fig
    plt.show()


def testing():
    today = datetime.today().strftime("%Y-%m-%d")
    # Wed 3 sep 2025
    today_title = datetime.today().strftime("%a %d %b %Y")
    HOME = os.getenv("HOME")
    assert HOME is not None, "HOME is not set"
    filepath = f"{HOME}/Notes/slipbox/journals/assets/{today}.schedule.png"
    # For testing
    schedule_str = """
    - [ ] 10:30 - 11:00 Finalise Quartz and MD Book Workflow
    - [ ] 11:00 - 12:00 Finish Ch. 1 of Statistical Learning in Finance
    - [ ] 12:00 - 12:30 Write Note Dispatcher Screen (Py/Fish)
    - [ ] 12:38 - 13:00 Merge all Notes off Dokuwiki and Mediawiki
    - [ ] 13:08 - 15:00 Job Application for AE Capital
    - [ ] 15:00 - 16:00 Gym
    - [ ] 16:08 - 17:08 Cardio
    - [ ] 17:39 - 18:39 Prepare for SDM
    - [ ] 19:00 - 20:00 UHE -- Write up notes on Search Sort and Complexity Analysis
    """

    plot_schedule(schedule_str, title_date=today_title)


# testing()
if __name__ == "__main__":
    main()
