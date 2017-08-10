#!/bin/sh

# xgettext.sh - specialized gettext extraction tool for this project.

# Motivation: The standard xgettext tool can't extract msgids from a $(gettext
# -es "str"...) command. This tool can but it's limited to extracting from such
# constructs only. This isn't a full xgettext replacement.

# Usage: xgettext.sh [--header] script.sh > messages.po

# Output project header template
if [ "$1" = --header ]; then
  shift
  xgettext -o - --force-po -LShell /dev/null
fi

gawk '
BEGIN {
  re_subshell_start = "^[ \\t]*\\$\\(gettext -es"
  re_subshell_end = "\\)([ \\t]*(#.*))?$" # includes shell comment
  re_one_or_more_double_quoted_strings="\"([^\"]+)\"(([ \\t]*\"[^\"]+\")+)?"
}
$0 ~ re_subshell_start,$0 ~ re_subshell_end {
  sub(re_subshell_start, "")
  sub(re_subshell_end, "")
  if(match($0, re_one_or_more_double_quoted_strings, A)) {
    # A[1] is the first unquoted string
    # A[2] is a space-delimited list of additional quoted strings and starts with space
    emit(A[1], NR)
    if(A[2] != "") {
      nL = split("\""A[2]" \"", L, /"[ \t]+"/)
      for(i = 2; i < nL; i++ ) {
        emit(L[i], NR)
      }
    }
  }
}
function emit(s, n) {
  print ""
  print "#: "FILENAME":"n
  print "msgid \""s"\""
  print "msgstr \"\""
}
' $1
