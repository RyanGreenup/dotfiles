
#!/usr/bin/python3
import os
import sys

TERM="kitty"

def main():
    """
# Open Wikipeida
this script will:

  * Open Emacs to edit Writing Beyond the Academy

    """
    if len(sys.argv) > 1 and sys.argv[1] == "--description":
        print(main.__doc__)
    else:
        os.system("emacs /home/ryan/Notes/org-roam/pages/20210817111535-university_writing_beyond_the_academy.org & disown")
        os.system("firefox https://theconversation.com/machine-learning-is-changing-our-culture-try-this-text-altering-tool-to-see-how-159430 & disown")
        os.system("firefox  http://192.168.50.190/mediawiki/index.php/Writing_Beyond_the_Academy & disown")
        os.system("kitty --working-directory='/home/ryan/Studies/WritingBeyondTheAcademy/Material' & disown")






if __name__ == "__main__":
    main()

