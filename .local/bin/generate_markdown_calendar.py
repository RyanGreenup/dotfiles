import argparse
import calendar
import datetime
import typer


app = typer.Typer()


@app.command("month")
def generate_calendar(year: int, month: int, relpath: str = ".", verbose: bool = True):
    markdown_table = ("| ISO | MON | TUE | WED | THU | FRI | SAT | SUN |\n"
                      "| --- | --- | --- | --- | --- | --- | --- | --- |\n")
    calendar_month = calendar.monthcalendar(year, month)
    week_number = datetime.date(year, month, 1).isocalendar()[1]
    if month == 1:
        if len(calendar_month[0]) == 1 and calendar_month[0][0] > 1:
            week_number = week_number - 1
    for week in calendar_month:
        markdown_table += "| Wk" + str("%02d" % week_number) + " "
        for day in week:
            if day == 0:
                markdown_table += "|     "
                continue
            day_str = str("%02d" % day)
            full_day = datetime.date(year, month, day)
            if full_day.month < month:
                month_str = str("%02d" % (month-1))
            elif full_day.month > month:
                month_str = str("%02d" % (month+1))
            else:
                month_str = str("%02d" % month)
            year_str = str(full_day.year)
            r = f"{relpath}/" if relpath != "." else ""
            markdown_table += "| [" + day_str + \
                f"]({r}" + year_str + "-" + month_str + "-" + day_str + ".md) "
        markdown_table += "|\n"
        week_number += 1
    if verbose:
        print(markdown_table)
    return markdown_table


@app.command("year")
def generate_annual_calendar(year: int):
    for month in range(1, 13):
        print(generate_calendar(year, month))


if __name__ == '__main__':
    app()
# typer.run(generate_calendar)

# # Parse command line arguments:
# parser = argparse.ArgumentParser()
# parser.add_argument("year", type=int, help="Year for calendar.")
# parser.add_argument("month", type=int, help="Month for calendar.")
# args = parser.parse_args()
#
# # Test:
# print(generate_calendar(args.year, args.month))
