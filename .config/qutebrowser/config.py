config.load_autoconfig()
# config.load_autoconfig(False) # Pass False to load the default stuff
c.url.searchengines = {
        'dg': 'https://duckduckgo.com/?q={}',
        'aw': 'https://wiki.archlinux.org/?search={}',
        'dw': 'http://localhost:8923/doku.php?q={}&do=search',
        'mw': 'http://localhost:8924/mediawiki/index.php?search={}&title=Special%3ASearch&go=Go',
        'DEFAULT': 'https://searx.tiekoetter.com/search?q={}'
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



## Optional Dark mode
config.bind('td', 'config-cycle colors.webpage.darkmode.enabled ;; restart')
config.bind('tj', 'config-cycle content.javascript.enabled')
