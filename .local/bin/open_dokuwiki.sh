#!/bin/sh
fd '\.txt$' . | sk -m --preview 'bat {}' | sed -e 's#./##' -e 's#.txt##' -e 's#/#/:#g' -e 's#^#http://localhost:8923/doku.php?id=#' | xargs qutebrowser
