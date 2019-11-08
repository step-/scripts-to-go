# This file is sourced not run

# META-begin
# This file is part of the Script Installer
# Copyright (C) step, 2019
# License: MIT
# Script Installer version=1.0.0
# META-end

# Notice @TRAP@ marks: call reset_term or empty_keyboard_buffer in exit traps
# to ensure the terminal resets to sane settings.
# ---------------------------------------------------------------------------

# Print 68-character-wide reverse text {{{1}}}
# [see-set_PROMPT] $1-text [$2-delta-length]
# delta-length > 0 needed if text includes 2-byte characters and zero-width ANSI codes
# In 80-column terminal width 68 is best and 71 is max before reverse wraps around.
REV_WIDTH=68
E="$(printf "\033%80s" "")"
S80="${E#?}" # 80 spaces
E=${E%$S80}  # escape
Ars="$E[7m" Ae="$E[0m" # ANSI reverse / end all
print_reverse() # {{{1
{
  set_PROMPT $1
  case $1 in -* ) shift ;; esac
  printf "${Ars}%-.$(($REV_WIDTH + $PROMPT_DELTA_LEN + ${2:-0}))s${Ae}\n" "${PROMPT}$1""$S80"
}

# Prompt with some two-byte unicode points that seem commonly available {{{1}}}
# [$1-"-p"|"-p1"|...
# => $PROMPT $PROMPT
set_PROMPT() { # {{{1
  case $1 in
    -p1|-p|"" ) PROMPT=" ◀▶ " PROMPT_DELTA_LEN=4 ;;
    -p2       ) PROMPT="<⚫>" PROMPT_DELTA_LEN=1 ;;
    -p3       ) PROMPT="=⬤= " PROMPT_DELTA_LEN=2 ;;
    -p4       ) PROMPT="[⬛]" PROMPT_DELTA_LEN=1 ;;
  esac
}

# => $AWK {{{1}}}
set_AWK() { # {{{1
  unset AWK
  if   awk         '' 2>/dev/null; then AWK=awk
  elif gawk        '' 2>/dev/null; then AWK=gawk
  elif mawk        '' 2>/dev/null; then AWK=mawk
  elif busybox awk '' 2>/dev/null; then AWK="busybox awk"
  fi
}

# You must call set_OLD_TTY_SETTINGS once at program initialization! {{{1}}}
# => $SAVED_TTY_SETTINGS
set_SAVED_TTY_SETTINGS() { # {{{1
  SAVED_TTY_SETTINGS=$(stty -g)
}

# Set tty to SAVED_TTY_SETTINGS.
# Call this at the very end of your traps and program.
# $SAVED_TTY_SETTINGS <=
reset_term() { # {{{1 @TRAP@
  stty "$SAVED_TTY_SETTINGS"
}

# Empty keyboard buffer and set terminal to SAVED_TTY_SETTINGS.
# Call this in your traps.
empty_keyboard_buffer() { # {{{1 @TRAP@
  if ! [ -t 0 ]; then return; fi
  stty -icanon min 0 time 0
  local dontcare
  while read dontcare; do :; done
  stty "$SAVED_TTY_SETTINGS"
}

# Get a keypress and set terminal to SAVED_TTY_SETTINGS {{{1}}}
# Don't forget to set traps that call reset_term or empty_keyboard_buffer @TRAP@
# $SAVED_TTY_SETTINGS <=
set_KEYPRESS() { # {{{1 @TRAP@
  stty -icanon min 1 time 0
  KEYPRESS=$(head -c1)
  stty "$SAVED_TTY_SETTINGS"
}

# Test tty's text style capabilities and set terminal to SAVED_TTY_SETTINGS {{{1}}}
# Don't forget to set traps that call term or empty_keyboard_buffer @TRAP@
# $SAVED_TTY_SETTINGS <=
is_term_underline_capable() { # {{{1 @TRAP@
  # adapted from https://unix.stackexchange.com/q/10698
  (
  text=' ͟'  # underlined space; shows up as " x" on a terminal that can't underline with this method. *MOD*
  csi='['; dsr_cpr="${csi}6n"; dsr_ok="${csi}5n"  # csi's first character is escape
  stty eol 0 eof n -echo                # Input will end with `0n`
  printf "$dsr_cpr$dsr_ok"              # Ask the terminal to report the cursor position
  initial_report=`tr -dc \;0123456789`  # Expect ␛[42;10R␛[0n for y=42,x=10
  printf "$text$dsr_cpr$dsr_ok"
  final_report=`tr -dc \;0123456789`
  stty "$SAVED_TTY_SETTINGS"
  # Compute and return initial_report - final_report
  IFS=';'
  set -- $initial_report
  ay=$1 ax=$2
  set -- $final_report
  by=$1 bx=$2
  unset IFS
  [ $(( ($by - $ay) * 10 + $bx - $ax )) = 10 ]
  )
}

# If not capable then TEXT_UNDERLINE and TEXT_STRIKETHROUGH won't work {{{1}}}
# => $TEXT_STYLE_CAPABLE {{{1}}}
set_TEXT_STYLE_CAPABLE() { # {{{1 @TRAP@
  [ "$SAVED_TTY_SETTINGS" ] || return 1
  is_term_underline_capable && TEXT_STYLE_CAPABLE=1 || unset TEXT_STYLE_CAPABLE
}

# $1-text [$2-width] {{{1}}}
# $REV_WIDTH <=
set_TEXT_CENTER() { # {{{1
  TEXT_CENTER="$(printf "%$(( ( ${2:-REV_WIDTH} - ${#1} ) / 2))s" "")$1"
}

# Ellipsize text in the middle {{{1}}}
# $1-text $2-max-width [$3-min-left] [$4-min-right] [$5-ellipsis ("...")]
# [$AWK] [$TEXT_STYLE_CAPABLE] <=
set_TEXT_ELLIPSIZE() { # {{{1
  if [ "$AWK" ]; then
    set -- "$($AWK -v T="$1" -v W="$2" -v L="$3" -v R="$4" -v E="${5:-...}" '#{{{awk
    END{
      W = W + 0; t = length(T)
      if (t <= W) { print T; exit }        # nothing to do
      L = max(L + 0, 1); R = max(R + 0, 1); e = length(E)
      if (L + R > W - e) { print T; exit } # L/R overlap

      sl = substr(T, 1, L)
      sr = substr(T, length(T) - R + 1, R)
      m  = t - L - R                       # length(sm)
      sm = substr(T, L + 1, m)             # T == sl sm sr
      pl = int(m / 2); pr = pl + 1         # sm == substr(sm, 1, pl) substr(sm, pr)
      goal = W - L - R - e

      # shorten sm from pl and pr outwards
      while (m > goal && m > 0) {
        ++pr; --m                          # take one char from right
        if (m == goal) { result(); exit }
        --pl; --m                          # take one char from left
      }
      result()
    }
    function result()  { print sl substr(sm, 1, pl) E substr(sm, pr) sr }
    function max(a, b) { return a > b ? a : b }
    #awk}}}' /dev/null)"
  fi
  TEXT_ELLIPSIZE=$1
}

# $1-text {{{1}}} single-byte unicode encoding {{{1}}}
# [$AWK] [$TEXT_STYLE_CAPABLE] <=
set_TEXT_STRIKETHROUGH() { # {{{1
  if [ "$AWK" -a "$TEXT_STYLE_CAPABLE" ]; then
    set -- "$($AWK -v T="$1" 'END{gsub(/./,"&\xcc\xb6",T);print T}' /dev/null)"
  fi
  TEXT_STRIKETHROUGH=$1
}

# $1-text {{{1}}} single-byte unicode encoding {{{1}}}
# [$AWK] [$TEXT_STYLE_CAPABLE] <=
set_TEXT_UNDERLINE() { # {{{1
  if [ "$AWK" -a "$TEXT_STYLE_CAPABLE" ]; then
    set -- "$($AWK -v T="$1" 'END{gsub(/./,"&\xcd\x9f",T);print T}' /dev/null)"
  fi
  TEXT_UNDERLINE=$1
}

