#!/bin/dash

# File comment file writer
# Author: step
# Copyright (c)2016-2019,2022 step
# License: GNU GPLv3
Version=1.1.1

usage() # {{{1
{
  local P="${0##*/}"
  printf "$(gettext 'Create/edit/delete comment files for FILEs.
TL;DR
  %s --no-symlink FILE
  env COMMENT_OPTIONS="--no-symlink" %s FILE
Usage:
  %s [Options] FILE [FILE...]
Options:
  -h, --help      Show this message and exit.
  --text-ext=EXT  Comment file name extension. Default "txt".[1]
  --no-dialog     Do not show a file open dialog.[2]
  --no-symlink    Do not create symlink .FILE.comment => FILE.EXT.[2][3]
  --no-xattr      Do not append extended attributes.[2]
  --rm            Delete comment file for FILE, i.e. rm FILE.txt.
  --rm-dry-run    Just print the list of files that would be removed.
  --rm-no-prompt  Do not prompt to confirm --rm action.
  --              Stop processing options.
Environment Variables:    (=default)
  COMMENT_EDITOR=defaulttexteditor
  COMMENT_OPTIONS=""      Command-line Options override this variable.
Notes:
[1] EXT "ROX" creates _regular_ file ".FILE.comment" and implies --no-symlink.
[2] You can disable a previous --no-<something> option with --<something>, i.e.,
    "--symlink" disables a "--no-symlink" in $COMMENT_OPTIONS.
[3] ROX-Filer reads a tooltip for "FILE" from ".FILE.comment" (Fatdog64 rox
    version jun7-2016.12) and also from "FILE.txt" (jun7-2017.11).
    Link ".FILE.comment" is co-located with "FILE"; "FILE.EXT" may not be.
Examples:
  %s --no-symlink FILE
    Fatdog64-720: writes FILE.txt, which rox displays as tooltip for FILE.
    Fatdog64-710: omit --no-symlink for tooltip [2].
  %s --text-ext=note FILE
    Fatdog64-710 & 720: writes FILE.note and symlink .FILE.comment, which
    rox displays as a tooltip for FILE.
  %s --text-ext=note --no-symlink FILE
    Fatdog64-710 & 720: writes FILE.note only, no rox tooltip.
  env COMMENT_OPTIONS="--no-xattr --text-ext=note" %s FILE
    Alternative way to specify options; most useful in your shell profile.
\n')" "$P" "$P" "$P" "$P" "$P" "$P" "$P"
}

set_OPTIONS() # In: "$@" Out: $OPTIONS, $SHIFT, $opt_* {{{1
{
  unset OPTIONS
  SHIFT=$#
  unset opt_no_dialog opt_no_symlink opt_no_xattr opt_text_ext opt_rm
  while [ "${1#-}" != "$1" ]; do
    OPTIONS="$OPTIONS $1"
    case $1 in
      --) shift; break ;;
      --help|-h) usage >&2; exit ;;
      --help=all-gui) usage --help-all | yad \
        --width=700 --height=600 --center --text-info --title "$APPTITLE - $(gettext "Help")" &
          exit ;;
      --no-dialog) opt_no_dialog=1; shift ;;
         --dialog) unset opt_no_dialog; shift ;;
      --no-symlink) opt_no_symlink=1; shift ;;
         --symlink) unset opt_no_symlink; shift ;;
      --no-xattr) opt_no_xattr=1; shift ;;
         --xattr) unset opt_no_xattr; shift ;;
      --rm) opt_rm=prompt; shift ;;
      --rm-dry-run) opt_rm=dry-run; shift ;;
      --rm-no-prompt) opt_rm=no-prompt; shift ;;
      # --rm-prompt-term) opt_rm=prompt-term; shift ;;
      --text-ext=*) opt_text_ext="${1#*=}"; shift ;;
      -*) { usage; gettext 'Bad option:'; echo " $1"; } >&2; exit 1;;
      *) break ;;
    esac
  done
  SHIFT=$(($SHIFT -$#))
}

dialog_file_open() # $1-comment-filepathname {{{1 In: $opt_no_symlink $FILE
{
  local p="$1" caption
  [ -z "$opt_no_symlink" ] &&
    caption="$(printf "$(gettext \
    "<i>Will also create link <tt>%s => .../%s</tt>.\nRead Help to disable.</i>")" \
      ".${FILE##*/}.comment" "${p##*/}")\n"
  yad --file --save --filename="$p" --text="$caption" \
    --escape-ok \
    --button=gtk-ok:0 --button=gtk-cancel:1 --button="gtk-help:$0 --help=all-gui"
  local exit_val=$? # 0|1|252
  [ 0 != $exit_val ] && echo "$p"
  echo $exit_val
  return $exit_val
}

# i18n {{{1
export TEXTDOMAIN=fatdog
export OUTPUT_CHARSET=UTF-8

# Constants. {{{1
APPTITLE=$(gettext "Write Comment")
WINDOW_ICON=~/.local/share/icons/posted.png
YAD_OPTIONS="--title '$APPTITLE' --window-icon='$WINDOW_ICON' --center --borders=4 --buttons-layout=center"
export YAD_OPTIONS

# Environment variables. {{{1
COMMENT_EDITOR=${COMMENT_EDITOR:-defaulttexteditor}

# Parse options. {{{1
[ "$COMMENT_OPTIONS" ] && set_OPTIONS $COMMENT_OPTIONS
shift0=${SHIFT:-0}
set_OPTIONS $OPTIONS "$@"
shift $(($SHIFT -$shift0))
if [ 0 = $# ]; then usage >&2; exit 1; fi

# Default values. {{{1
opt_text_ext="${opt_text_ext:-txt}" # FILE.txt
opt_text_ext="${opt_text_ext#.}"

# Set traps and create temporary folder. {{{1
TMPD=$(mktemp -d -p "${TMPDIR:-/tmp}" "${0##*/}_XXXXXX")
chmod 700 "$TMPD" || exit 1
trap "rm -rf \"$TMPD\"/* \"$TMPD\"" HUP INT QUIT TERM ABRT 0
DATF="${TMPD}/.dat"; >"${DATF}" # list original and comment files
CFTF="${TMPD}/.cft"; >"${CFTF}" # list comment files

if [ -z "$opt_rm" ]; then # {{{1}}} Write comment file(s).
  # Press [Cancel] to exit the script.
  # Press [Esc] to accept the current default file name and go to the next FILE.
  for FILE; do
    # Prompt to select comment file path/name. {{{1
    # Make full pathname, which saves some mouse clicks in yad.
    case $FILE in /*) f=$FILE ;; *) f="`pwd`/$FILE" ;; esac
    cf="$f.$opt_text_ext" exit_val=0
    if [ ROX = $opt_text_ext ]; then
      cf="${f%/*}/.${f##*/}.comment" opt_no_dialog=1
    fi
    # Allow renaming text comment file.
    if [ -z "$opt_no_dialog" ]; then
      { read cf; read exit_val; } << EOF
$(dialog_file_open "$cf")
EOF
    fi
    : "cf($cf)"
    : "exit_val($exit_val)"
    case $exit_val in
      1 ) # 1=Cancel
        exit
        ;;
      0) # 0=OK && 252=ESC->0 (--escape-ok)
        # Queue FILE and comment file full pathnames.
        printf "%s\n%s\n" "$f" "$cf" >> "$DATF"
        ;;
    esac
  done # {{{1}}}
  xargs -0 -L 1 < "$DATF"
  while read f; do
    read cf &&
    # Create/edit comment file. {{{1
    # Link ROX-Filer comment file to txt file. {{{2
    if [ -z "$opt_no_symlink" ] && [ ROX != $opt_text_ext ]; then
      # Relative link iff comment file co-resides with FILE.
      [ "${cf%/*}" = "${f%/*}" ] && tf=${cf##*/} || tf=$cf
      ln -sfT "$tf" "${f%/*}/.${f##*/}.comment"
    fi

    # APPEND optional content items. {{{2
    # Dump extended attributes.
    if [ -z "$opt_no_xattr" -a -e "$f" -a ! -e "$cf" ]
    then
      echo '```xattr' >> "$cf"

      # -e text avoids mixing text-encoded with hex- / base64-encoded fields for 2-byte chars cf. man getfattr -m
      getfattr -d -e text "$f" >> "$cf"
      # more complicated alternative using attr
      #attr -ql "$f" | xargs --no-run-if-empty -I{} attr -g {} "$f" >> "$cf"

      echo '```' >> "$cf"
    fi

    # Queue2 comment file fullpath. {{{2
    printf "%s\000" "$cf" >> "$CFTF"
  done  < "$DATF" # {{{1}}}
  # Edit comment text in default/preferred program. {{{1
  # All files in a single editor call. For multiple calls with a single
  # file add -L 1 to xargs.
  # Don't quote $COMMENT_EDITOR so the user can specify options.
  xargs --no-run-if-empty -0 $COMMENT_EDITOR < "$CFTF"

else # {{{1}}} Remove comment file(s).
  # Press [OK] to remove comment and link (if any) files.
  # [Cancel] and [Esc] don't remove.
  for FILE; do
    # Determine rm target(s) cf and lf. {{{1
    case $FILE in /*) f=$FILE ;; *) f="`pwd`/$FILE" ;; esac
    cf= lf="${f%/*}/.${f##*/}.comment" # regular file or link
    if [ -L "$lf" ]; then
      cf="$(readlink -f "$lf")"
    elif [ -f "$lf" ]; then
      cf="$lf" lf=
    elif [ -e "$f.$opt_text_ext" ]; then
      cf="$f.$opt_text_ext" lf=
    fi
    # Queue link file and comment file full pathnames. {{{1
    # -L -o -f ensures detection of dangling links.
    [ -L "$lf" -o -f "$lf" ] && printf "%s\000" "$lf" >> "$DATF"
    [ -e "$cf" ] && printf "%s\000" "$cf" >> "$DATF"
  done # {{{1}}}
  # Remove files. {{{1
  case $opt_rm in
    dry-run ) tr '\0' '\n' < "$DATF"
      ;;
    # prompt-term ) # Simple with term ui - NOT-USED
    #   defaultterm -e xargs --no-run-if-empty -0 --arg-file "$DATF" rm -i
    #   ;;
    prompt ) # Fancier with yad gui
      awk 'BEGIN{RS="\x00"} {print "true\n"$0}' "$DATF" |
      yad --list \
        --column="$(gettext rm)":CHK --column="$(gettext File)" --tooltip-column=2 \
        --print-all --ellipsize=START |
      awk 'BEGIN{ORS="\x00"} /^TRUE/{print substr($0, 6, length($0)-6)}' |
      xargs --no-run-if-empty -0 rm
      ;;
    no-prompt )
      xargs --no-run-if-empty -0 --arg-file "$DATF" rm
      ;;
  esac

fi # {{{1}}}
