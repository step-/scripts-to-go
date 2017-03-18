#!/bin/sh
# This file is sourced, not run.

if [ 0 = "$status" ]; then
cat << EOF

Optionally you could install the mpg123 command-line MP3 player.  For Fatdog64,
mpg123 can be installed using the gslapt package manager: click the system menu
Fatdog64 icon, click Setup > Gslapt Package Manager, click Update, search for
"mpg123" (without quotes), select version 1.23.8 or higher, right-click to
install, click Execute.  Direct download link:
http://distro.ibiblio.org/fatdog/contrib/packages/710/mpg123-1.23.8-x86_64-1.txz
EOF
fi
