#!/usr/bin/env python

import sys
import bibtexparser
import pyperclip
import toml


for arg in sys.argv:
    if arg in ["h", "-h", "--help", "-h", "?", "-?"]:
        print("This transforms bibtex into TOML")
        print("\n")
        print("If the script receives STDIN, it will output STDOUT")
        print("In the absence of STDIN the clipboard will be transformed")


# Read from clipboard or standard input
if sys.stdin.isatty():
    ## If there is not stdinput
    stdinQ = False
    # Take the clipboard
    bib_str = pyperclip.paste()
else:
    ## If there is stdinput
    stdinQ   = True
    bib_list = sys.stdin.readlines()
    bib_str  = ""
    for i in bib_list:
        bib_str += i


# Interpret the bibtex
bib_db = bibtexparser.bparser.parse(bib_str)
bib_dict = bib_db.get_entry_dict()

# Make it TOML
toml_str = toml.dumps(bib_dict)

# Output the TOML
if sys.stdin.isatty():
    ## If there is not stdinput
    # Take the clipboard
    pyperclip.copy(toml_str)
else:
    ## If there is stdinput
    print(toml_str)



##  ___                   _
## |_ _|_ __  _ __  _   _| |_
##  | || '_ \| '_ \| | | | __|
##  | || | | | |_) | |_| | |_
## |___|_| |_| .__/ \__,_|\__|
##           |_|
# ............................................................
# ............................................................

## NOTE
# To work with files:

# with open('bibtex.bib') as bibtex_file:
#     bib_database = bibtexparser.load(bibtex_file)
# print(bib_database.entries)

## NOTE
# To work with the clipboard
# Get the string from the clipboard (unused)
# bib_str = pyperclip.paste()


## NOTE Get the string from stdin
# bib_st = sys.stdin.readlines()


#  ____       _
# |  _ \  ___| |__  _   _  __ _
# | | | |/ _ \ '_ \| | | |/ _` |
# | |_| |  __/ |_) | |_| | (_| |
# |____/ \___|_.__/ \__,_|\__, |
#                         |___/
# ............................................................
# ............................................................

# NOTE print the dictionary
# bib_str = pyperclip.paste()
# bib_db = bibtexparser.bparser.parse(bib_str)
#  print(bib_db.entries)

## NOTE # To debug use this:

## bib_str = """
## @article{Cesar2013,
##  abstract = {This is an abstract. This line should be long enough to test
## multilines...},
##  author = {Jean César},
##  comments = {A comment},
##  journal = {Nice Journal},
##  keyword = {keyword1, keyword2},
##  month = {jan},
##  pages = {12--23},
##  title = {An amazing title},
##  volume = {12},
##  year = {2013}
## }
## """
##
