
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
        os.system("xournalpp ~/Notes/Xournalpp/template.xopp & disown")
        os.system("emacs /home/ryan/Studies/StatsForDataSci/statsfords/worksheets/04 & disown")
        os.system("echo /home/ryan/Studies/StatsForDataSci/statsfords/worksheets/04 | xclip -sel clipp & disown")
        os.system("jitsi-meet-desktop & disown")
        os.system("chromium https://localhost:8962/lab/tree/SageMath/MatrixMultiplication.ipynb & disown")
        os.system("chromium http://localhost:8888/lab/workspaces/auto-b/tree/05/Untitled.ipynb & disown")
        os.system("zulip & disown")


if __name__ == "__main__":
    main()

