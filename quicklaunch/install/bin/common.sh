# This file is sourced not run

# META-begin
# This file is part of the Script Installer
# Copyright (C) step, 2019
# License: MIT
# Script Installer version=1.0.0
# META-end

TAB=$(printf "\t")

die_if_not_AWK() { # {{{1
  if ! [ "$AWK" ]; then
    echo >&2 "${0##*/}: Awk command not found.  This program cannot proceed."
    exit 1
  fi
}

die_if_not_terminal() { # {{{1
  if ! [ -t 0 ]; then
    echo >&2 "This program must run in a terminal."
    exit 1
  fi
}

# Loop until the desired key is pressed {{{1}}}
# $1-desired-UPPERCASE-keypress [$2-prompt-function]
# $UNATTENDED_RUN <= | => $KEYPRESS
get_this_keypress_or_exit() { # {{{1
  local desired="$1" prompt_func="${2:-:}"
  if [ "$UNATTENDED_RUN" ]; then
    KEYPRESS=$desired
    return
  fi
  while sleep 0.1; do
    empty_keyboard_buffer
    set_KEYPRESS
    case $KEYPRESS in
      ''  ) KEYPRESS=ENTER ;;
      q|Q ) exit ;;
      h|H ) echo
        if type usage >/dev/null 2>&1; then
          usage
        fi
        $prompt_func ;;
    esac
    KEYPRESS=$(echo "$KEYPRESS" | tr "[[:lower:]]" "[[:upper:]]")
    [ "$desired" = "$KEYPRESS" ] && return || printf "\007"
  done
}

prompt_continue() { # {{{1
  print_reverse " ""Press ENTER to continue, Q to quit, H for help..."
}

set_traps_and_TMPD() { # {{{1
  TMPD=$(mktemp -d -p "${TMPDIR:-/tmp}" "${0##*/}_XXXXXX")
  chmod 700 "$TMPD" || exit 1
  trap "empty_keyboard_buffer; rm -rf \"$TMPD\"/* \"$TMPD\"; short_help; echo" 0
  trap 'echo; print_reverse -p "Terminated early (signal received)"; exit' HUP QUIT TERM ABRT
  trap 'echo; print_reverse -p " ""End session (Ctrl+C pressed)"; exit' INT
}
short_help() { # {{{1
  set_PROMPT
  printf "%s\n%s\n" "$PROMPT""For help run:" "$0 --help"
}

short_help_centered() { # {{{1
  set_PROMPT
  set_TEXT_CENTER "For help run:" $(( $REV_WIDTH - $PROMPT_DELTA_LEN ))
  echo "$PROMPT$TEXT_CENTER"
  set_TEXT_ELLIPSIZE "$0 --help" "$REV_WIDTH" 20 20
  set_TEXT_CENTER "$TEXT_ELLIPSIZE"
  printf "%s" "$TEXT_CENTER"
}

# $1-message {{{1}}}
# $LOGFILE <=
warn_unless_logfile_writable() { # {{{1
  local msg="$1" warn="${LOGFILE%/*}"
  if [ -w "$warn" ]; then
    warn="$LOGFILE"
    if [ ! -e "$warn" ] || [ -w "$warn" ]; then
      unset warn
    fi
  fi
  if [ "$warn" ]; then
    set_PROMPT
    printf "${PROMPT}Warning: '%s' is not writable:\n%s""\n" "$warn" "$msg"
    print_reverse "You should stop now to make it writable"
    prompt_continue
    get_this_keypress_or_exit ENTER prompt_continue
  fi
}

