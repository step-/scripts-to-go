#!/bin/sh

# META-begin
# This file is part of the Script Installer
# Copyright (C) step, 2019
# License: MIT
# Installer version=1.0.0
# META-end

# Required: awk

usage() { # {{{1
  echo "USAGE:
  uninstall.sh [OPTIONS]"
  cat << EOF
OPTIONS:
  -h, --help    show help then exit immediately
  --unattended  uninstall without questions with default options
  --verbose     report each file removal
  --            stop processing OPTIONS
FILES:
  Log file : ${LOGFILE#$(pwd)/}
DESCRIPTION:
  This program reads uninstall information from the log file.
  The main screen shows a time sorted list of all the sessions
  that passed the install test, and were confirmed to start.
  You should uninstall sessions from the most recent one and move
  backwards through the list.

  BACKUP HANDLING
  The installer created a backup before installing over an existing
  file under the /Home path. If the uninstaller finds the backup of
  a file that is being uninstalled, it moves the backup to replace
  the file otherwise it removes the file altogether.
  The installer did not backup files under the /Destination.
EOF
}

# Parse options. {{{1
unset opt_help UNATTENDED_RUN opt_verbose
for a; do
  case $a in
    -h|--help) opt_help=1 ;;
    --unattended) export UNATTENDED_RUN=1 ;;
    --verbose) opt_verbose=1 ;;
    --) shift; break ;;
    -*) echo "Unknown option $a" >&2; exit 1 ;;
    *) break ;;
  esac
  shift
done

# Init {{{1
LOGFILE=$(pwd)/install/install.log

# Sets global TAB
. "${0%uninstall.sh}common.sh" && die_if_not_terminal || exit 1
# Sets globals REV_WIDTH E S80 Ars Ae
. "${0%uninstall.sh}libterm.sh" && set_SAVED_TTY_SETTINGS || exit 1

if ! [ -s "$LOGFILE" -a -r "$LOGFILE" ]; then
  echo "${0##*/}: Uninstall log file not found. Uninstalling cannot proceed.
  '$LOGFILE' not found.
  Start this program from the install folder with this command:
  sh ./install/bin/uninstall.sh"
  exit 1
fi >&2

set_AWK; die_if_not_AWK

set_TEXT_STYLE_CAPABLE; echo

if [ "$opt_help" ]; then usage; exit; fi

prompt_uninstall () { # {{{1
  print_reverse " ""Press U to uninstall, Q to quit, H for help..."
}

prompt_continue() { # {{{1
  print_reverse " ""Press ENTER to continue, Ctrl+C to quit..."
}


# => $SELECTED_SESSION {{{1}}}
# Set SELECTED_SESSION = "<index> <unique datetime>"
# <index> == NO_MORE   => no more sessions left to uninstall
# <index> =~ D<number> => disabled session selected
set_SELECTED_SESSION() { # {{{1

  ### extract status and datetime, one per line, from the log file

  local query=5,4 resf="$TMPD/status-datetime" disabled
  # Next line: install()'s and set_SELECTED_SESSION()'s STATUS value must be the same
  $AWK -f "$VIEW" -v STATUS="*" -v FEATURE=$query "$LOGFILE" > "$resf"

  ### show the user the result list from the STATUS/FEATURE query

  set_PROMPT
  local datetime col_datetime status col_status default=NO_MORE n_max=0 p x
  {
  print_reverse -p "Install sessions:"
  while read status; do
    read datetime
    col_datetime=$(date --date "$datetime" +"%x %X")
    unset col_status
    n_max=$(($n_max +1))
    case $status in
      "(0)"* ) : "(0)completed" show-enabled
        default=$n_max ;;
      "(1)"* ) : "(1)did not start" hide
        continue ;;
      "(2)"* ) : "(2)did not finish" show-enable
        default=$n_max col_status="- install error" ;;
      "(3)"* ) : "(3)uninstalled" show-disabled
        disabled="$disabled $n_max" col_status="X uninstalled"
        set_TEXT_STRIKETHROUGH "$col_datetime"
        col_datetime=$TEXT_STRIKETHROUGH
        ;;
    esac
    printf "% 3d %15s %s\n" "$n_max" "$col_datetime" "$col_status"
  done < "$resf"

  printf "%s %s\n%s\n" $default $n_max "${disabled# }" > "$TMPD"/selected
  if [ NO_MORE = $default ]; then
    kill -USR1 $$ # suicide visible after pager 'more' ends
    default=0     # cosmetic for %d below
  fi
  printf "${PROMPT}""Which session do you want to uninstall? (enter a number) [%d]""\n" $default
  } | {
    MORE= more # want exactly more not just any $PAGER
    prompt_continue
  }

  # retrieve return values from the above sub-shell

  { read default n_max; read disabled; } < "$TMPD"/selected # default index [%d]
  unset SELECTED_SESSION

  # no more sessions left to uninstall?
  if [ NO_MORE = "$default" ]; then return; fi

  ### get user input (x)

  x=DEFAULT
  if ! [ "$UNATTENDED_RUN" ]; then
    # read user input: [<number>] ENTER
    read x
  fi

    # disabled session selected?
    for p in $disabled; do
      if [ "$x" = "$p" ]; then x="D$x"; fi
    done

    case $x in
      D[0-9]* ) : disabled session ;;
      [1-9]|[1-9][0-9]|[1-9][0-9][0-9] )
        if [ "$x" -gt "$default" ]; then x=$default; fi ;;
      '' | DEFAULT )
        x=$default ;;
    esac
  SELECTED_SESSION="$x $($AWK "NR==$(($x*2))" "$resf")"
}

# $SELECTED_SESSION <= {{{1}}}
uninstall() { #{{{1
  # query mkdir and copy operations (backups are mentioned in copy records)
  local query=-3,-1 resf="$TMPD/mkdir-cp" inf="$TMPD/${SELECTED_SESSION%% *}".in
  # Next line: install()'s and set_SELECTED_SESSION()'s STATUS value must be the same
  $AWK -f "$VIEW" -v STATUS="*" -v FEATURE=$query "$LOGFILE" > "$resf"
  $AWK -v RS= "/${SELECTED_SESSION#* }/" "$resf" > "$inf"
  local IFS="$TAB" a b c d e f datetime phase dest_dir home_dir
  while read a b c d e f; do
    if [ "<>" = "$a" ]; then
      datetime=$b
      phase=$c
      : "don't care $d(counter)"
      dest_dir=$e
      home_dir=$f
      continue
    fi
    case $phase in
      mkdir  ) # $a(tgt) $b(existing)
        undo_mkdir "$a" "$b" "$dest_dir" "$home_dir" ;;
      backup )
        echo >&2 "NOT IMPLEMENTED undo_backup"; false ;;
      copy   ) # $a(src) $b(dst) $c(action) $d(backup)
        undo_copy "$b" "$c" "$d" "$dest_dir" "$home_dir" ;;
    esac
  done < "$inf"
}

# Multiple rmdir to undo the mkdir install action {{{1}}}
# Never remove $2 $3 and $4
# $1-start-dirpath $2-stop-dirpath $3-dest-dir $4-home-dir
undo_mkdir() { # {{{1
  local cur="$1" stop="$2" dest_dir="$3" home_dir="$4" root

  # determine cur's root install dir

  # Note when you do need double quotes in a case pattern that includes a
  # variable. Word splitting doesn't happen in a case pattern, but an unquoted
  # variable is interpreted as a pattern whereas a quoted variable is
  # interpreted as a literal string. @n@

  case $cur in
    ${dest_dir%/}/?* ) root=$dest_dir ;;
    ${home_dir%/}/?* ) root=$home_dir ;;
    *             ) echo >&2 "UNEXPECTED '$cur' in undo_mkdir"; false ;;
  esac

  while [ "$cur" -a "$root" -a "$stop" ] &&
    [ "$root" != "$cur" -a / != "$cur" -a "$stop" != "$cur" ]; do
    if [ -d "$cur" ]; then rmdir ${opt_verbose:+-v} "$cur"; fi
    cur=${cur%/*}
  done
}

# Replace src file with its backup otherwise remove file {{{1}}}
# $1-filepath $2-"copy"/"overwrite" $3-backup
undo_copy() { # {{{1
  local file="$1" action="$2" backup="$3"
  case $action in
    backup )
      mv ${opt_verbose:+-v} "$backup" "$file" ;;
    '' | overwrite )
      rm ${opt_verbose:+-v} -f "$file" ;;
    * )
      echo >&2 "NOT IMPLEMENTED in undo_copy"; false ;;
  esac
}

# $1-session-DATETIME $2-status {{{1}}}
update_session_status() { # {{{1
  $AWK -v DATETIME="$1" -v STATUS="$2" '#{{{awk
  BEGIN { OFS = FS = "\t" }
  $2=="start" && index($0, DATETIME) {
    for (i = 1; i <= NF; i++) {
      if ("STATUS=" == $i) { $i = $i STATUS }
    }
  }
  { R[++nR] = $0 }
  END { for(i = 1; i <= nR; i++) print R[i] > FILENAME }
  #awk}}}' "$LOGFILE"
}

# Main {{{1}}}
set_traps_and_TMPD
trap 'echo; print_reverse -p "No installed sessions found."; exit' USR1
#######
set -ef
#######
VIEW="${0%uninstall.sh}view.awk"

warn_unless_logfile_writable \
  "the uninstaller can work but it cannot update the log file."

while :; do
  set_SELECTED_SESSION
  case $SELECTED_SESSION in
    '' ) exit ;;
    D[0-9]* ) continue ;; # disabled session selected
  esac
  print_reverse -p "Confirm uninstalling session $SELECTED_SESSION ?"
  prompt_uninstall
  get_this_keypress_or_exit U prompt_uninstall
  echo
  echo "Start"
  uninstall
  update_session_status "${SELECTED_SESSION#* }" "(3)uninstalled"
  echo "Uninstalled"
done

