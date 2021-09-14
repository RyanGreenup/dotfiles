
#!/usr/bin/python3
import os
import sys
import subprocess

TERM="kitty"

commands = [
    [TERM, "-e", "ranger", "/home/ryan/Studies/AdvancedMachineLearning/LearningMaterial"],
    ["code", "/home/ryan/Studies/AdvancedMachineLearning/Scripts"],
    ["firefox", "http://192.168.50.190/mediawiki/index.php/Advanced_Machine_Learning"],
    ["emacs", "~/Notes/Org/agenda/todo.org"],
    ["discord"]
]

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
        for command in commands:
            try:
                result = subprocess.Popen(command, stdout=subprocess.PIPE)
                result_string = result.stdout.decode('utf-8')
                print(result_string)
            except:
                print("Error running", command)
                pass
#        os.system("firefox https://en.wikipedia.org/wiki/Special:Random")
#        os.system("nvim $mktemp")







if __name__ == "__main__":
    main()

