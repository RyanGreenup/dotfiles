from datetime import datetime as dt
from datetime import timedelta as td
import pandas as pd
import typer

app = typer.Typer()

weekday_map = {
    0: "Monday",
    1: "Tuesday",
    2: "Wednesday",
    3: "Thursday",
    4: "Friday",
    5: "Saturday",
    6: "Sunday",
}


def make_month(month: int):
    year = dt.now().year
    start = dt(year, month, 1)
    days = [start + td(days=i) for i in range(32)]
    return [d for d in days if d.month == 7]


def print_cal_month(year: int = dt.now().year, month: int = dt.now().month):
    table = {
        "Wk": [],
        "Monday": [],
        "Tuesday": [],
        "Wednesday": [],
        "Thursday": [],
        "Friday": [],
        "Saturday": [],
        "Sunday": [],
    }

    # Build the Dictionary
    days = make_month(7)
    weeks = list(set(day.isocalendar()[1] for day in days))
    for day in days:
        table[weekday_map[day.weekday()]].append("[" + day.strftime("%d") + "]")
    table["Wk"] = [f"[W{w}]" for w in weeks]

    # Remove duplicates from week
    table["Wk"] = list(set(table["Wk"]))

    # Ensure all arrays are the same length
    for key in table.keys():
        while len(table[key]) < 6:
            table[key].append(None)

    # Print the parent link
    print("# " + str(dt(year, month, 1).strftime("%Y %B")))
    print(f"\n- [↑ {year}](j_{year}.md)\n")

    # Print the DataFrame
    print(pd.DataFrame(table).to_markdown(index=False))
    print(" ")
    print(" ")

    # Print the link Definitions
    for day in days:
        title = day.strftime("%d")
        target = f"j_{day.strftime('%Y-%m-%d')}.md"
        print(f"[{title}]: {target}")

    for week in weeks:
        title = f"[W{week}]"
        target = f"j_{year}-{week}.md"
        print(f"{title}: {target}")


@app.command()
def month(year: int = dt.now().year, month: int = dt.now().month):
    print_cal_month(year, month)


@app.command()
def year(year: int = dt.now().year):
    for i in range(1, 13):
        print_cal_month(year, i)


if __name__ == "__main__":
    app()
