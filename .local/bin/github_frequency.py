#!/usr/bin/env python
import sys
import requests
import matplotlib.pyplot as plt
from datetime import datetime
from collections import defaultdict



# get the basename of the url
url = sys.argv[1]
repo = "/".join(url.split('/')[-2:])

# Get the commit history from the Github API
url = f'https://api.github.com/repos/{repo}/commits'
response = requests.get(url)

# Create a dictionary to store the number of commits per day
commits_per_day = defaultdict(int)
for commit in response.json():
    date_str = commit['commit']['committer']['date'][:10]
    date = datetime.strptime(date_str, '%Y-%m-%d')
    commits_per_day[date] += 1

# Extract the dates and commit counts
dates = list(commits_per_day.keys())
counts = list(commits_per_day.values())

# Plot the data
plt.plot(dates, counts)
plt.xlabel('Date')
plt.ylabel('Number of Commits')
plt.show()
