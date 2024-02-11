# OpenAI model to translate text to code
    # Example:
    #     ```
    #     ai2! give me the small json in one line
    #     # {"name":"John","age":30,"city":"New York"}
    #     ```


import subprocess
from prompt_toolkit.keys import Keys
from prompt_toolkit.filters import Condition, EmacsInsertMode, ViInsertMode
import sys
from shutil import which as _which
import time as _time


if _which('zoxide'):
    execx($(zoxide init xonsh), 'exec', __xonsh__.ctx, filename='zoxide')

# The SQLite history backend saves command immediately
# unlike JSON backend that save the commands at the end of the session.
# $XONSH_HISTORY_BACKEND = 'sqlite'
# aliases['history-search'] = """sqlite3 $XONSH_HISTORY_FILE @("SELECT inp FROM xonsh_history WHERE inp LIKE '%" + $arg0 + "%' AND inp NOT LIKE 'history-%' ORDER BY tsb DESC LIMIT 10");"""

try:
    with open("/home/ryan/.local/openai.key") as f:
        key = f.read().strip()
        $OPENAI_API_KEY = key
except FileNotFoundError:
    print("OPENAI_API_KEY not found", file=sys.stderr)



 # OpenAI model to translate text to code
    # Example:
    #     ```
    #     ai2! give me the small json in one line
    #     # {"name":"John","age":30,"city":"New York"}
    #     ```

if _which('openai'):

    # example_code = '''import os\nimport re
    # for file in os.listdir("./"):
    #     if not re.match(r"^\..*", file):
    #         print(file)
    # '''
    # aliases['ai] = openai api chat.completions.create -m gpt-4-0125-preview -t 0 -M 500 --stream -g system "You are a helpful AI" -g user "How to loop over files in a directory?" -g assistant ${example_code} -g user -p @(' '.join($args))
    # aliases['ai'] = "openai api completions.create -m gpt-4-0125-preview -t 0 -M 500 --stream -p @(' '.join($args))"
#    aliases['ai'] = "openai api chat.completions.create -m gpt-3.5-turbo -t 0 -M 500 --stream -g @(' '.join($args))"
    model = "gpt-3.5-turbo"
    model = "gpt-4-turbo-preview"
    import time
    aliases['ai'] = "openai api chat.completions.create -m gpt-4-turbo-preview  -t 0 -M 500 --stream -g user @(' '.join($args)) | tee -a @('/tmp/ai-alias' + str(time.time()) + '.md' )"



# Function to execute the command and capture the output
def fzf(t: str = 'f', r: float = 80):
    # Run the 'ls' command and capture its output
    result = subprocess.run(['fd', '-t', t], stdout=subprocess.PIPE)
    cmd = ['fzf', '--height', str(r)+"%"]
    if t == 'f':
        cmd += ['--preview', 'cat {}']
    elif t == 'd':
        cmd += ['--preview', 'exa --tree {}']
    result = subprocess.run(cmd, input=result.stdout,text=False, stdout=subprocess.PIPE)

    # Decode the binary output to get a string
    output_as_str = result.stdout.decode('utf-8')

    # Return the output string
    return output_as_str.strip()

@events.on_ptk_create
def custom_keybindings(bindings, **kw):

    @bindings.add(Keys.ControlW)
    def say_hi(event):
        event.current_buffer.insert_text('hi')

    @bindings.add(Keys.ControlT)
    def run_ls(event):
        # text=$(find . | fzf)
        text=fzf('f')
        event.current_buffer.insert_text(text)
        event.cli.renderer.erase()

    @bindings.add(Keys.ControlW)
    def say_hi(event):
        event.current_buffer.insert_text('hi')


    @bindings.add(Keys.ControlK)
    def run_zi(event):
        # __zoxide_zi(['.'])
        zi
        event.cli.renderer.erase()

    @bindings.add(Keys.ControlJ)
    def run_ls(event):
        # text=$(find . | fzf)
        xonsh.dirstack.cd([fzf('d', 50)])
        event.cli.renderer.erase()
        event.cli.renderer.erase()
