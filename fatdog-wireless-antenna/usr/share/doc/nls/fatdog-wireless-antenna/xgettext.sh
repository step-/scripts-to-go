#!/bin/sh

# xgettext.sh - expanded xgettext(1) extraction tool.

usage() # {{{1
{
  cat << 'EOF'
Motivation:
A single call to 'gettext -es' with multiple arguments is more efficient than
multiple calls to gettext with a single argument. Unfortunately, the standard
xgettext tool can't detect msgids from command $(gettext -es "msgid1"...). This
tool can handle such case, and can also be used as a full replacement for
xgettext(1).

Usage: xgettext.sh [OPTIONS] ['--' xgettext_OPTIONS ...] FILE"

OPTIONS:
  --help    Print this message and exit. See also xgettext --help.
  --no-c1   Don't output [c1] lines.
  --no-c2   Don't output [c2] lines.
  --test    Generate test translation.

[c0] Arguments of $(gettext -es ...) are extracted.
If the script includes a function named i18_table:
[c1] Shell comments within the function body are extracted with prefix '#.'.
[c2] For lines starting with "read i18n_<string>" the i18n_... part is
     extracted and placed before its corresponding "msgid" with prefix '#.'.

Location information is generated for lines [c0] and [c2] unless xgettext(1)
option --no-location is specified.
EOF
}

# Parse options. {{{1
# Option format: -x[=parm] | --opt-x[=parm]
# Short options can't be combined together. Space can't substitute '=' before option value.
unset opt_no_c1 opt_no_c2 opt_no_location
while ! [ "${1#-}" = "$1" ]; do
  case "$1" in
    --RESERVED) # add more here |...|...
      usage
      echo "${0##*/}: : $(gettext 'option needs a value')" >&2
      exit 1 ;;
    --RESERVED=*) =${1#*=} opt_id=${1#*=} ;;
    -h|--help|-h=*|--help=*) usage "$1"; exit ;;
    --no-c1 ) opt_no_c1=1 ;;
    --no-c2 ) opt_no_c2=1 ;;
    --test ) opt_test=1 ;;
    --) shift; break ;;
    -*)
      usage
      echo "${0##*/}: : $(gettext 'unknown option')" >&2
      exit 1 ;;
  esac
  shift
done
case "$*" in *--no-location* ) opt_no_location=1 ;; esac

for a; do script="$a"; done
if ! [ -e "$script" ]; then
  usage >&2
  exit 1
fi

# Standard xgettext run. {{{1
xgettext -o - -LShell "$@" |
if [ "$opt_test" ]; then
  sed -e 's/\(; charset=\)CHARSET/\1utf-8/' -e 's/^"Language: /&en/'
else
  cat
fi

# Output for case $(gettext -es ...) {{{1
gawk -v NO_C1=$opt_no_c1 -v NO_C2=$opt_no_c2 \
  -v NO_LOC=$opt_no_location -v TEST=$opt_test '
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
    emit_c0((NO_LOC ? "" : "#: "FILENAME":"NR), A[1])
    if(A[2] != "") {
      nL = split("\""A[2]" \"", L, /"[ \t]+"/)
      for(i = 2; i < nL; i++) {
        emit_c0("", L[i])
      }
    }
  }
}
/^[ \t]*i18n_table[ \t]*[(]/ {
  in_i18n_table = 1
}
/[{]/, /[}]/ {
  if(in_i18n_table) {
    if(match($0, /[{]/)) {
      ;
    } else if(match($0, /[}]/)) {
      in_i18n_table = 0
    } else {
      if(!NO_C1 && match($0, /^[ \t]*#/)) { # [c1]
        sub(/[ \t]*#/, "#.", $0)
        print
      } else if(!NO_C2 && match($0, /read[ \t]+i18n_[^ \t]+/)) { # [c2]
        m = substr($0, RSTART, RLENGTH)
        C2[++count_c2] = (NO_LOC ? "" : "#: "FILENAME":"NR "\n") "#. " substr(m, index(m, "i"))
      }
    }
    next
  }
}
# emit_c0 prints a c0 line as well as any c1 and c2 lines that got accumulated
# before the c0 line.
function emit_c0(location, line,   i) {
  print ""
  if(C2[++emit_c2]) { print C2[emit_c2] }
  if(location) { print location }
  print "msgid \""line"\""
  if(TEST) { print "msgstr \"[T]"line"\"" }
  else     { print "msgstr \"\"" }
}
' "$script"
