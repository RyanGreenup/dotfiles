config.load_autoconfig()
# config.load_autoconfig(False) # Pass False to load the default stuff
c.url.searchengines = {
        'dg': 'https://duckduckgo.com/?q={}',
        'aw': 'https://wiki.archlinux.org/?search={}',
        'dw': 'http://localhost:8923/doku.php?q={}&do=search',
        'gl': 'http://localhost:4567/gollum/search?q={}',
        'mw': 'http://localhost:8924/mediawiki/index.php?search={}&title=Special%3ASearch&go=Go',
        'wp': 'https://en.wikipedia.org/w/index.php?search={}',
        'g': 'https://www.google.com/search?q={}',
        'sx': 'https://searx.tiekoetter.com/search?q={}',

        'DEFAULT': 'https://lite.duckduckgo.com/lite/zzz/search?q={}'
        }
c.tabs.position = 'left'
## When to show the tab bar.
## Type: String
## Valid values:
##   - always: Always show the tab bar.
##   - never: Always hide the tab bar.
##   - multiple: Hide the tab bar if only one tab is open.
##   - switching: Show the tab bar when switching tabs.
c.tabs.show = 'multiple'
# colors.webpage.prefers_color_scheme_dark
# c.editor.command = ["gvim", "-f", "{file}", "-c", "normal {line}G{column0}l"]
c.editor.command = ["alacritty", "-e", "nvim", "-f", "{file}", "-c", "normal {line}G{column0}l"]
# c.editor.command = ["emacsclient", "-f", "{file}"]
# c.editor.command = ["neoray", "{file}", "--column", "{column0}", "--line", "{line}"]
# c.editor.command = ["neoray", "{file}", "--column", "{column0}", "--line", "{line}"]




## Styling
import styles.dracula.draw

# Load existing settings made via :set
config.load_autoconfig()

styles.dracula.draw.blood(c, {
    'spacing': {
        'vertical': 6,
        'horizontal': 8
    }
})

c.content.cookies.accept = 'no-3rdparty'
# Tor Proxy
# TODO https://searx.tiekoetter.com/search?q=qutebrowser+toggle+proxy&language=en-US&time_range=&safesearch=0&theme=simple
## c.content.proxy = 'socks://localhost:9050/'
## i2p Proxy
# c.content.proxy = 'http://localhost:4444/'
# c.content.proxy = 'socks://localhost:4447/'
#
#

c.hints.selectors["code"] = [
    # Selects all code tags whose direct parent is not a pre tag
    ":not(pre) > code",
    "pre"
]

## Optional Dark mode
config.bind('td', 'config-cycle colors.webpage.darkmode.enabled ;; restart')
config.bind('tr', 'config-source')
config.bind('tj', 'config-cycle content.javascript.enabled')
config.bind('cc',  'hint code userscript code_select.py')
config.bind('ed',  'spawn --userscript edit_dw.sh')
config.bind('eg',  'spawn --userscript edit_gm.sh')
config.bind('el',  'edit-url')

