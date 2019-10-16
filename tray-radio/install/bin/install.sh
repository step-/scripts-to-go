#!/bin/sh

# META-begin
# The Script Installer
# Copyright (C) step, 2019
# License: MIT
# Installer version=1.0.0
# META-end

# Required: getent
# Optional: awk

usage() { # {{{1
#123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
#         1         2         3         4         5         6         7         8
  echo "USAGE:
  install.sh [OPTIONS] [/Destination [/Home[:Owner.Group]]]"
  printf "    default %-.20s: %s\n" \
    "/Destination""$S80" "$DEST_DIR" \
    "/Home""$S80" "$(getent passwd "$USER" | cut -d: -f6)" \
    "Owner.Group""$S80" "$USER.$USER" \
    ;
  cat << EOF
OPTIONS:
  -h, --help    show help then exit immediately
  --skip-dest   skip installing to /Destination
  --skip-home   skip installing to /Home
  --skip-no     skip installing to /Destination when it fails the
                test ('NO'); likewise skip installing to /Home
  --unattended  install without questions with default options
  --verbose     report each file copy
  --            stop processing OPTIONS
FILES:
  Log file enabled: ${LOGFILE#$SOURCE_DIR/}
  Source list file: ${FILELIST#$SOURCE_DIR/}
DESCRIPTION:
  This program installs the items listed in the source list file.
  It makes backups of existing files under the /Home path before
  overwriting them. It overwrites without backup existing files
  under the /Destination path.  The installing user will own new
  files under /Destination, whereas Owner.Group will own new
  files under /Home.
UNINSTALLING:
  The uninstaller needs the installation log file. Therefore,
  after installing save the log file or (recommended) the whole
  folder "./install".  For more information run:
    install/bin/uninstall.sh --help
EOF
}

# Parse options. {{{1
unset opt_help opt_skip_dest opt_skip_home opt_skip_no UNATTENDED_RUN opt_verbose
for a; do
  case $a in
    -h|--help) opt_help=1 ;;
    --skip-dest) opt_skip_dest=1 ;;
    --skip-home) opt_skip_home=1 ;;
    --skip-no) opt_skip_no=1 ;;
    --unattended) export UNATTENDED_RUN=1 ;;
    --verbose) opt_verbose=1 ;;
    --) shift; break ;;
    -*) echo "Unknown option $a" >&2; exit 1 ;;
    *) break ;;
  esac
  shift
done

# Arguments and init {{{1
USER=$(id -un)
SOURCE_DIR=$(pwd)
DEST_DIR=${1:-/}
HOME_DIR=$2
FILELIST="$SOURCE_DIR"/install/filelist
LOGFILE="$SOURCE_DIR"/install/install.log
LOGCNT=0

# Sets global TAB
. "${0%install.sh}common.sh" && die_if_not_terminal || exit 1
# Sets globals REV_WIDTH E S80 Ars Ae
. "${0%install.sh}libterm.sh" && set_SAVED_TTY_SETTINGS || exit 1

if ! [ -s "$FILELIST" -a -r "$FILELIST" ]; then
  echo "${0##*/}: Installation source error for '$SOURCE_DIR'.
  '$FILELIST' not found.
  Start this installer from the unpacked folder with this command:
  sh ./install/bin/install.sh"
  exit 1
fi >&2

warn_unless_logfile_writable \
  "the UN-installer will not work because a log file cannot be written."

set_AWK # awk is optional
set_TEXT_STYLE_CAPABLE; echo

if [ "$opt_help" ]; then usage; exit; fi

# In log_* LHS suffix "_" will make view.awk hide the line {{{1}}}
log_start() { # {{{1
    # don't change "%F %T"
    # keep STATUS last
  log start \
    "DATETIME=$(date +"%F %T")" \
    "DISPLAY=$DISPLAY" \
    "FATDOG_VERSION=$FATDOG_VERSION" \
    "STATUS=" \
    ;
}

log_args() { # {{{1
  log args \
    "USER=$USER" \
    "SOURCE_DIR=$SOURCE_DIR" \
    "DEST_DIR=$DEST_DIR" \
    "HOME_DIR_=$HOME_DIR" \
    "CMDLINE_=$*" \
    ;
}

# $@-log-items {{{1}}}
log() { # {{{1
  local IFS; unset IFS
  LOGCNT=$(($LOGCNT + 1))
  { printf $LOGCNT; printf "\t%s" "$@"; echo; } >> "$LOGFILE"
}

# => $DEST_DIR, $HOME_DIR, etc. {{{1}}}
do_test() { #{{{1
  do_test_dest
  do_test_home
}

# Is destination accessible and writable? #{{{1}}}
# $FILELIST <= | => $DEST_DIR etc.
do_test_dest() { # {{{1
if [ "$opt_skip_dest" ]; then return; fi
if ! cd "$DEST_DIR" 2>/dev/null; then
  CAN_WRITE_DEST=NO FAIL_DEST="** no access **"
else # implies -d -x -r
  DEST_DIR=$(pwd)
  cd - >/dev/null # canonicalize path
fi
if ! [ -w "$DEST_DIR" ]; then
  CAN_WRITE_DEST=NO FAIL_DEST="$FAIL_DEST${FAIL_DEST:+ }** no write ** '$DEST_DIR'"
else
  CAN_WRITE_DEST=yes FAIL_DEST=

  # test all existing target sub-directories
  local p
  while read p; do
    case $p in HOME/* ) continue ;; esac
    p="$DEST_DIR/${p%/*}"

    if [ -d "$p" ] && ! [ -x "$p" -a -w "$p" ]; then
      CAN_WRITE_DEST=NO FAIL_DEST="$FAIL_DEST${FAIL_DEST:+ }'$p'"
    fi
  done < "$FILELIST"
fi
}

# Is home needed, accessible and writable? {{{1}}}
# $FILELIST <= | => $HOME_DIR, $HOME_NEEDED, etc.
do_test_home() { # {{{1
  if ! grep -qm1 ^HOME/ "$FILELIST"; then
    unset HOME_NEEDED HOME_DIR OWNER_HOME_DIR GROUP_HOME_DIR
    return
  fi
  HOME_NEEDED=yes

  if [ "$opt_skip_home" ]; then return; fi

  case "$HOME_DIR" in
    '' )
      HOME_DIR=$(getent passwd "$USER" | cut -d: -f6)
      OWNER_HOME_DIR=$USER
      GROUP_HOME_DIR=$(id -gn $USER)
      ;;
    *:* )
      GROUP_HOME_DIR=${HOME_DIR##*.}
      OWNER_HOME_DIR=${HOME_DIR#*:}; OWNER_HOME_DIR=${OWNER_HOME_DIR%.$GROUP_HOME_DIR}
      HOME_DIR=${HOME_DIR%:*}
      ;;
    *)
      OWNER_HOME_DIR=$USER
      GROUP_HOME_DIR=$(id -gn $USER)
      ;;
  esac

  CAN_WRITE_HOME=yes
  if cd "$HOME_DIR" 2>/dev/null; then
    HOME_DIR=$(pwd) # canonicalize path
    cd - >/dev/null
  else # implies -d -x -r
    CAN_WRITE_HOME=NO FAIL_HOME="** no access **"
  fi
  if ! [ -w "$HOME_DIR" ]; then
    CAN_WRITE_HOME=NO FAIL_HOME="$FAIL_HOME${FAIL_HOME:+ }** no write ** '$HOME_DIR'"
  fi

  # Can change ownership?
  local testfile="$HOME_DIR/.${0##*/}.$$.tmp"
  if touch "$testfile" 2>/dev/null &&
    chown "$OWNER_HOME_DIR:$GROUP_HOME_DIR" "$testfile" 2>/dev/null
  then
    CAN_CHANGE_HOME=yes
  else
    CAN_CHANGE_HOME=NO
  fi
  rm -f "$testfile"
  # TODO recursive directory test as for $DEST_DIR with change owner
}

log_test() { # {{{1
  log test \
    "HOME_DIR=$HOME_DIR" \
    "HOME_NEEDED=$HOME_NEEDED" \
    "CAN_WRITE_HOME=$CAN_WRITE_HOME" \
    "CAN_CHANGE_HOME=$CAN_CHANGE_HOME" \
    "OWNER_HOME_DIR=$OWNER_HOME_DIR" \
    "GROUP_HOME_DIR=$GROUP_HOME_DIR" \
    "DEST_DIR=$DEST_DIR" \
    "CAN_WRITE_DEST=$CAN_WRITE_DEST" \
    "FAIL_DEST=$FAIL_DEST" \
    ;
}

test_any_NO() { # {{{1
  [ "$CAN_WRITE_DEST" = NO -o "$CAN_WRITE_HOME" = NO -o "$CAN_CHANGE_HOME" = NO ]
}

set_FATDOG_VERSION() { # {{{1
  if [ -e /etc/fatdog-version ]; then
    read FATDOG_VERSION < /etc/fatdog-version
  fi
}

set_SKIP_DEST() { # {{{1
  [ "$opt_skip_dest" -o NO = "$CAN_WRITE_DEST" -a "$opt_skip_no" ] &&
    SKIP_DEST=1 || unset SKIP_DEST
}

set_SKIP_HOME() { # {{{1
  [ "$opt_skip_home" -o \( NO = "$CAN_WRITE_HOME" -o NO = "$CAN_CHANGE_HOME" \) -a "$opt_skip_no" ] &&
    SKIP_HOME=1 || unset SKIP_HOME
}

print_test_result() { # {{{1
  local result

  test_any_NO && result=FAILED || result=PASSED
  print_reverse -p \
    "Pre-installation test:     $result"
  echo "\
Source:         $SOURCE_DIR
Destination:    ${SKIP_DEST:+will be skipped: }$DEST_DIR
  pass test:    ${CAN_WRITE_DEST:-NA}${CAN_WRITE_DEST:+: write}${FAIL_DEST:+"
    "$FAIL_DEST}
  owner.group:  $USER.$USER will own new files"
  if [ yes = "$HOME_NEEDED" ]; then echo "\
Home:           ${SKIP_HOME:+will be skipped: }$HOME_DIR
  pass test:    ${CAN_WRITE_HOME:-NA}${CAN_WRITE_HOME:+: write}, ${CAN_CHANGE_HOME:-NA}${CAN_CHANGE_HOME:+: change owner}${FAIL_HOME:+"
    "$FAIL_HOME}
  owner.group:  $OWNER_HOME_DIR.$GROUP_HOME_DIR will own new files"
  else echo "\
Home:           not needed"
  fi
  echo "____
The installer will stop on the eventual first error occurrence.
Existing files under the Destination path will be overwritten."
  if [ yes = "$HOME_NEEDED" ]; then echo "\
Existing files under Home will be backed up then overwritten."
  fi
}

prompt_install () { # {{{1
  print_reverse " ""Press I to install, Q to quit, H for help..."
  if test_any_NO && ! [ "$opt_skip_no" ]; then short_help; fi
}

# Find the longest, common, existing, proper sub-path of $1 inside directory $2 {{{1}}}
# Inside: as in directories not as in strings.
# Proper: if $1 exists return its parent's path not $1.
# Return "" if $1 isn't inside $2 || $1 is $2.
# Return "" if $1 is "/".
# Return "" (and status 1) if $2 isn't a dir || $1 or $2 are relative paths.
# Limitation: for canonical paths only -- no "/./", "/../", and "//" within.
# Main use: for an installer to provide hints to an uninstaller.
# $1-inner-pathname $2-outer-path => $EXISTING_SUBPATH # {{{1
set_EXISTING_SUBPATH() {
  unset EXISTING_SUBPATH
  # reject relative paths
  case $1 in /* ) :;; * ) return 1 ;; esac
  case $2 in /* ) :;; * ) return 1 ;; esac

  local inner="$1" outer="$2" head1 tail exist

  # prepend "/." - this simplifies dealing with "/"
  case $inner in /./* ) :;; /. ) inner=/./ ;; * ) inner="/.$inner" ;; esac
  case $outer in /./* ) :;; /. ) outer=/./ ;; * ) outer="/.$outer" ;; esac

  # chop dandling /
  case $inner in /./*?/ ) inner=${inner%/} ;; esac
  case $outer in /./*?/ ) outer=${outer%/} ;; esac

  ### early return on special cases

  tail=${inner#$outer}

  case $inner in
    "$tail"  ) : "$inner isn't inside $outer"; return ;;
    "$outer" ) : '$1 is $2'; return ;;
    /./      ) : '$1 is "/"'; return ;;
  esac
  # did ascertain that $inner is inside $outer

  if ! [ -d "$outer" ]; then return 1; fi

  if [ -e "$inner" ]; then
    exist="${inner%/*}"

  else # walk tail path

    exist="${outer%/}/"
    tail=${tail#/}
    while [ "$tail" ]; do
      head1=${tail%%/*}
      ! [ -d "$exist$head1" ] && break
      tail=${tail#$head1}; tail=${tail#/}
      exist="$exist$head1/"
    done
  fi

  ### clean return path
  exist=${exist#/.}
  case $exist in /*/ ) exist="${exist%/}";; esac
  EXISTING_SUBPATH="$exist"
}

# $1-dir-path {{{1}}}
make_dest_dir() { # {{{1
  local dir="$1" tgt="${DEST_DIR%/}/$dir"
  if [ . != "$dir" ]; then
    if ! [ -d "$tgt" ]; then
      set_EXISTING_SUBPATH "$tgt" "$DEST_DIR"

      # @1@ When the whole $tgt path is non-existent pass $DEST_DIR,
      # so the uninstaller won't remove $DEST_DIR (normally "/").
      log mkdir "$tgt" "${EXISTING_SUBPATH:-$DEST_DIR}"

      mkdir -p "$tgt"
      log mkdir-ok
    fi
  fi
}

# $1-file-path {{{1}}}
# $MODE <=
copy_file_to_dest_dir() { # {{{1
  local overwrite p="$1" src="$SOURCE_DIR/$p" dst="${DEST_DIR%/}/$p"
  if [ -e "$dst" ]; then overwrite="overwrite"; fi
  log cp-f "$src" "$dst" "$overwrite"
  cp ${opt_verbose:+-v} -dp "$src" "$dst"
  log cp-f-ok
  if [ "$MODE" ]; then
    log chmod-f "$dst" "$MODE"
    chmod ${opt_verbose:+-v} $MODE "$dst"
    log chmod-f-ok
  fi
}

# =>/<= $DEST_DIR, etc. {{{1}}}
install_to_dest_dir() { # {{{1
  local p dir

# Install (overwrite existing).
  if [ yes = "$CAN_WRITE_DEST" ]; then

    call_if_defined package_pre_install_dest

    echo "Installing to '$DEST_DIR'..."
    while read p; do

      # the chmod MODE that functions {copy_file_to,make}_dest will set
      set_MODE "$p"
      p=${p#$MODE$TAB}

      # skip installing these...
      case $p in
        install/* )             continue ;; # this installer
        .DirIcon  | README.md ) continue ;; # packaging material
        HOME/* )                continue ;; # HOME gets installed elsewhere
      esac

      # copy source file to destination making leading path and setting mode
      dir=$(dirname "$p")
      make_dest_dir "$dir"
      copy_file_to_dest_dir "$p"

    done < "$FILELIST"
    call_if_defined package_post_install_dest
  fi
}

# => $MODE {{{1}}}
# $1-install.log-line
# line ::= [mode "\t"]pathname
set_MODE() { # {{{1
  unset MODE
  local IFS="$TAB"
  set -- $1
  case $# in
    2 ) MODE=$1 ;;
  esac
}

# $1-dir-path {{{1}}}
make_home_dir() { # {{{1
  local dir="$1" tgt="${HOME_DIR%/}/$dir"
  if [ . != "$dir" ]; then
    if ! [ -d "$tgt" ]; then
      set_EXISTING_SUBPATH "$tgt" "$HOME_DIR"

      ### like mkdir -p while changing owner of each newly-created component
      local IFS=/ p exist="${EXISTING_SUBPATH:-$HOME_DIR}" # @1@
      p="${tgt#$exist}"; p=${p#/}
      set -- $p
      while [ $# -gt 0 ]; do
        if ! [ -e "$exist/$1" ]; then
          log mkdir "$exist/$1" "$exist"
          mkdir "$exist/$1"
          log mkdir-ok
          log chown-d "$OWNER_HOME_DIR:$GROUP_HOME_DIR" "$exist/$1"
          chown "$OWNER_HOME_DIR:$GROUP_HOME_DIR" "$exist/$1"
          log chown-d-ok
        fi
        exist=$exist/$1 ; shift
      done
    fi
  fi
}

# $1-file-path {{{1}}}
# $MODE <=
copy_file_to_home_dir() { # {{{1
  local backup p="$1" src="$SOURCE_DIR/HOME/$p" dst="${HOME_DIR%/}/$p"

  if [ -e "$dst" ]; then # backup existing destination file
    backup="$dst~$Suffix~" # $Suffix in caller's scope
    log bkp-f "$dst" "$backup"
    cp ${opt_verbose:+-v} -dp "$dst" "$backup"
    log bkp-f-ok
  fi

  log cp-f "$src" "$dst" "${backup:+backup}" "$backup"
  cp ${opt_verbose:+-v} -dp "$src" "$dst"
  log cp-f-ok
  if [ "$MODE" ]; then
    log chmod-f "$dst" "$MODE"
    chmod ${opt_verbose:+-v} $MODE "$dst"
    log chmod-f-ok
  fi
  log chown-f "$OWNER_HOME_DIR:$GROUP_HOME_DIR" "$dst"
  chown ${opt_verbose:+-v} "$OWNER_HOME_DIR:$GROUP_HOME_DIR" "$dst"
  log chown-f-ok
}

# =>/<= $HOME_DIR, etc. {{{1}}}
install_to_home_dir() { #{{{1
  local p dir

# Install HOME with backup.
if [ yes-yes-yes = "$HOME_NEEDED-$CAN_WRITE_HOME-$CAN_CHANGE_HOME" ]; then

  call_if_defined package_pre_install_home

  echo "Installing to '$HOME_DIR'..."
  Suffix=$(date +%Y%m%d%H%M%S)
  while read p; do

    # the chmod MODE that functions {copy_file_to,make}_dest will set
    set_MODE "$p"
    p=${p#$MODE$TAB}

    # Install HOME only
    case $p in
      HOME/* )
        p=${p#HOME/} ;;
      * )
        continue ;;
    esac

    # the chmod MODE that functions {copy_file_to,make}_home_dir will set
    set_MODE "$p"
    p=${p#$MODE$TAB}

    # make copy target's leading path
    dir=$(dirname "$p")
    make_home_dir "$dir"

    # copy source file to destination
    # - backup copy target if existent
    # - change file mode
    # - set owner/group
    copy_file_to_home_dir "$p"

  done < "$FILELIST"

  call_if_defined package_post_install_home
fi
}

# call package-provided function(s) {{{1}}}
# => $PACKAGE_FUNCTIONS_LOADED
# $1-funcname [$2@-args]
# see the list of possible funcnames in package-functions-sample.sh
call_if_defined() { # {{{1
  local -
  local funcname="$1" load="$SOURCE_DIR/install/bin/package-functions.sh" ret
  shift

  if [ -r "$load" ] && ! [ "$PACKAGE_FUNCTIONS_LOADED" ]; then
    log source "$load"
    . "$load"
    log source-ok
    PACKAGE_FUNCTIONS_LOADED=1
  fi
  set +e +f
  if type $funcname >/dev/null 2>&1; then
    log call $funcname
    $funcname "$@"
    ret=$?
    log call-ok ret=$ret
  fi
  return $ret
}

# make lx-qt panel rebuild its menu on Fatdog64 {{{1}}}
# $FILELIST $FATDOG_VERSION <=
rebuild_lxqt_panel_menu() { # {{{1
  if ! [ "$DISPLAY" ]; then
    : "no X desktop"
    return
  fi
  if ! grep -qm1 "\.desktop$" "$FILELIST"; then
    : "no new applications installed"
    return
  fi
  if [ ${FATDOG_VERSION:-0} -lt 800 ] ; then
    : "no lxqt panel or not Fatdog64"
    return
  elif [ $FATDOG_VERSION -le 802 ]; then
    if [ -e $HOME/.local/share/applications/defaults.list ]; then
      touch $HOME/.local/share/applications/defaults.list
    fi
  else
    if [ -e /tmp/rebuild-lxqt-panel-menu ]; then
      touch /tmp/rebuild-lxqt-panel-menu
    fi
  fi
}

# Main {{{1}}}

set_traps_and_TMPD
trap 'echo; print_reverse -p "Nothing installed (test failed)"; exit' USR1

set_FATDOG_VERSION
log_start
log_args

call_if_defined package_pre_install_test
do_test
log_test
set_SKIP_DEST
set_SKIP_HOME
call_if_defined package_post_install_test

{
call_if_defined package_install_test_result_prologue
print_test_result
call_if_defined package_install_test_result_epilogue

if test_any_NO && ! [ "$opt_skip_no" ]; then
  # Test failed: abort installation
  kill -USR1 $$ # suicide visible after more ends
fi
} | {
  MORE= more # want exactly more not just any $PAGER
  prompt_install
}
get_this_keypress_or_exit I prompt_install
echo

# Test passed: confirm installation?
unset prompt
case $SKIP_DEST/$SKIP_HOME in
    / ) prompt="Confirm '$DEST_DIR'${HOME_DIR:+ and "'"$HOME_DIR"'"} ?";;
  1/  ) prompt="Confirm ${HOME_DIR:-nothing to do} ?";;
  /1  ) prompt="Confirm '$DEST_DIR' ?";;
  1/1 ) prompt="Confirm nothing to do ?";;
esac
print_reverse -p "$prompt"
prompt_install
get_this_keypress_or_exit I prompt_install
echo
echo "Start"
#######
set -ef
#######
log install "$(date "+%F %T")" # don't change "%F %T"

install_to_dest_dir

install_to_home_dir

rebuild_lxqt_panel_menu

log end
echo "Installed"
call_if_defined package_installer_exit

