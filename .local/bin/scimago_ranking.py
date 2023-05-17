import os
import sys

url = "https://www.scimagojr.com/journalsearch.php?q="
query = ""

if len(sys.argv) > 1:
    query = sys.argv[1]
else:
    query = input("Journal Name:")

query = query.replace(" ", "+")
url = url + query
print(url)
os.system(f"xdg-open {url}")
