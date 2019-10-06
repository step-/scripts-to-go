#!/usr/bin/awk -f
# This script is part of roxmm - https://github.com/step-/scripts-to-go
# Original concept from viczim's openboxplus pet.
# Re-written from sh script into busybox-compatible awk script for Fatdog64.
# License: GPLv3 (c)2016 step
# Usage: $0 [-v WRAP=1|2|3 [-v SUBMENU_TITLE="title"]] "<ROX-Bookmarks.xml>"
# Output: gtkmenuplus configuration data of ROX-Filer's bookmarks.
#   Pipe output into "gtkmenuplus -".
# Depends: gtkmenuplus >= 1.0.0

BEGIN {
  FS = "[<>]|[ \t]+"
  if(WRAP) {
    if(WRAP>2) print "configure = noicons endsubmenu"
    if(!SUBMENU_TITLE) SUBMENU_TITLE = "Rox _Bookmarks"
    print "submenu = "SUBMENU_TITLE"\nicon = gtk-jump-to"
  }
}
$3 == "bookmark" {
  label = substr($4, 1, length($4) - 1)
  label = substr(label, index(label, "=") + 2)
  printf "  item = %s\n  cmd = rox \"%s\"\n",\
    label, $5
}
END {
  if(WRAP>1) print "endsubmenu"
}
