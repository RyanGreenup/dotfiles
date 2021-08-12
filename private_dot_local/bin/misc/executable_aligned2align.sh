#!/usr/bin/env bash
set -euo pipefail

xclip -selection clipboard -o | sd '\$\$[\s\S]+\\begin\{aligned\}' '\\begin{align}' | sd '\\end\{aligned\}[\s\S]+\$\$' '\\end{align}'


###############################################################################
# Use align* because it isn't so bad to number just one, although, this isn't #
# compatible with katex, that's pandoc's problem to fix though                #
#                                                                             #
# \begin{align*}                                                              #
#   a &= 1                            \\                                      #
#   b &= 2 \refstepcounter{equation}                                          #
#               \tag{\theequation}    \\                                      #
#   c &= 3                            \\                                      #
#   d &= 4 \tagaligneq                \\                                      #
#   e &= 5                                                                    #
# \end{align*}                                                                #
###############################################################################
