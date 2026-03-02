#!/bin/sh
# Launch emacs for org-agenda via distrobox
/usr/bin/distrobox-enter -n text_editors -- /bin/sh -l -c emacs &
