
#!/usr/bin/python3
import os
import sys

def main():
    """
# Open Wikipeida
this script will:

  * Open a **random** *Wikipedia* article in the browser
  * Open *Neovim* at a __*L*a*T*e*X*__ or Markdown file

    """
    if len(sys.argv) > 1 and sys.argv[1] == "--description":
        print(main.__doc__)
    else:
        os.system("firefox https://en.wikipedia.org/wiki/Special:Random")
        os.system("nvim $mktemp")





if __name__ == "__main__":
    main()

