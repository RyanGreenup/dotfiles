
#!/usr/bin/python3
import os
import sys

def main():
    """
# GUI Fitness Applications
this script will open:

  * A Terminal
  * Emacs
  * VSCode

  For working on an application to monitor fitness measurements.

    """
    if len(sys.argv) > 1 and sys.argv[1] == "--description":
        print(main.__doc__)
    else:
        dir='/home/ryan/Studies/Projects/fitnessGUI'
        os.system("kitty --working-directory='/home/ryan/Studies/Projects/fitnessGUI' & disown")
        os.system("cd home/ryan/Studies/Projects/fitnessGUI && emacs . & disown")
        os.system("code -a 'home/ryan/Studies/Projects/fitnessGUI'")
        os.system("joplin-desktop")






if __name__ == "__main__":
    main()

