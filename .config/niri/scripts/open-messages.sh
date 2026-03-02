#!/bin/sh
# Launch messaging apps via distrobox
# Signal gets the _sp_messages mark via for_window rule.
# Element opens as a second window on the same scratchpad pull.
# /usr/bin/distrobox-enter -n containerized_apps-signal-desktop -- /bin/sh -l -c /opt/Signal/signal-desktop --no-sandbox &
# /usr/bin/distrobox-enter -n containerized_apps-signal-desktop -- /bin/sh -l -c /opt/Element/element-desktop &
signal-desktop --ozone-platform=wayland & disown
