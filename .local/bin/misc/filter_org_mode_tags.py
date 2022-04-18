#!/usr/bin/env python
import os
import re
import glob
import sys
import subprocess

# Set Working Directory
os.chdir((os.getenv('HOME')))
os.chdir('Notes/Org/')
ripgrep_command = ['rg', '--vimgrep', '-t', 'org', r"^\*+\s.*:.+:"]
grep_results = subprocess.run(ripgrep_command, stdout=subprocess.PIPE).stdout.decode('utf-8')
grep_results = str(grep_results).split('\n')



# Match org-mode files
def printOrgFiles(dir):
    os.chdir(dir)
    files = os.listdir()
    orgFiles = []
    for file in files:
        pattern = re.compile('.+\.org$')
        if re.match(pattern, file):
            orgFiles.append(file)
        
    print(orgFiles)


# Search for Tags in org-files

lines = {
    'filename': [],
    'lineNumber': [],
    'title': [],
    'tags': [] 
}

for line in grep_results:
    line_list = str(line).split(':')
    try:
        lines['filename'].append(line_list[0])
        lines['lineNumber'].append(line_list[1])
        lines['title'].append(line_list[3]) # 2 is column number, we just want first
        lines['tags'].append(list(line_list[4:-1])) # make sure that a single tag is still a list for consistency
    except:
        print('missing value, skip line')
print('---')
print(lines)

# Print the filename, tag and line number

for i in range(len(lines['lineNumber'])):
    try:
        filename = lines['filename'][i]
        lineNumber = lines['lineNumber'][i]
        tags = lines['tags'][i]
        print(filename + ',' + lineNumber + ',' + str(tags))
    except:
        pass
        # Do nothing in exception for clean STDOUT
