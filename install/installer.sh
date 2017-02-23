#!/bin/sh

unset opt_force opt_usage
for a; do
  case $a in
    -h|--help) opt_usage=1 ;;
    --force) opt_force=1 ;;
    --verbose) opt_verbose=-v ;;
    --) shift; break ;;
    -*) echo "Unknown option $a" >&2; exit 1 ;;
    *) break ;;
  esac
  shift
done

t=${0##*/}; t=${t#install-}; t=${t%.sh}
source_dir=$(realpath -m "${0%/*}/../$t")
if ! [ -d "$source_dir" ] || ! [ -r "$source_dir" ]; then
  echo "${0##*/}: Installation source error for '$source_dir'" >&2
  exit 1
fi
dest_dir=${1:-/}
owner=${3:-$USER}
home_dir=${2:-$(getent passwd "$owner" | cut -d: -f6)}
home_needed=yes
if ! [ -d "$home_dir" ]; then
  home_dir="- not found -"
  can_write_home=NO group=NA
else
  owner=$(set -- `ls -ld "$home_dir"`; echo "$3")
  group=$(getent group $(getent passwd "$owner" | cut -d: -f3) | cut -d: -f1)
fi

can_write_dest=yes
# dir name with spaces not allowed
for dir in "" $(ls -Ap "$source_dir"); do
  : "dir($dir)"
  case $dir in HOME/) continue ;; ''|*/) : ;; *) continue ;; esac
  t="$dest_dir/${dir#$source_dir/}"
  [ -d "$t" ] && { ! [ -w "$t" ] && can_write_dest=NO; }
done

if ! [ -d "$source_dir/HOME" ]; then
  home_needed=
  home_dir="- not needed -"
elif ! [ NO = "$can_write_home" ]; then # home_dir not found
  testfile="$home_dir/.${0##*/}.$$.tmp"
  if ! touch "$testfile" 2>/dev/null; then
    can_write_home=NO
  else
    can_write_home=yes
    chown "$owner:$group" "$testfile" 2>/dev/null &&
    chmod 777 "$testfile" 2>/dev/null &&
    can_change_home=yes ||
    can_change_home=NO
  fi
fi
rm -f "$testfile"

usage()
{
cat << EOF
Usage:
  ${0##*/} [--force] [--verbose] [/destination/dir [/home/dir [owner]]]
  --force skips destination/home for which 'pass test is NO'.
Pre-installation test results:
  source:         $source_dir
  destination:    $dest_dir
    pass test:    $can_write_dest
  home needed:    $home_needed: $home_dir
    pass test:    ${can_write_home:-NA}, ${can_change_home:-NA}
    owner:group:  $owner:$group
EOF
}

[ -n "$opt_usage" ] && { usage; exit; }
if [ "$can_write_dest" = NO -o "$can_write_home" = NO -o "$can_change_home" = NO ]; then
  usage
  if [ -z "$opt_force" ]; then
    echo "Run again with option --force or fix permissions for 'pass test NO'."
    exit
  fi
fi

trap 'echo; echo "Interrupt. Early exit."; exit 128' HUP INT QUIT TERM ABRT
usage
[ -n "$opt_force" ] && echo "Option --force is enabled. Skipping targets for which 'pass test is NO'."
echo -n "Press ENTER to start or Ctrl+C to exit..."
read

umask 0022
source_tmp="${TMPDIR:-/tmp}/$$.${source_dir##*/}"
if [ yes = "$can_write_dest" ]; then
  echo "Installing to '$dest_dir'..."
  rm -rf "$source_tmp" &&
  cp -r "$source_dir"/. "$source_tmp" &&
  rm -rf "$source_tmp/HOME" &&
  find "$source_tmp" -type f -a \( \
    -path '*/bin/*' -o -path '*/sbin/*' -o -path '*/AppRun' -o -path '*.sh' \
    \) -exec chmod 0755 '{}' \; &&
  cp $opt_verbose -a "$source_tmp"/. "$dest_dir"
  status=$?
  rm -rf "$source_tmp"
  [ 0 = $status ]
fi &&
if [ yes-yes-yes = "$home_needed-$can_write_home-$can_change_home" ]; then
  echo "Installing to '$home_dir'..."
  rm -rf "$source_tmp" &&
  cp -r "$source_dir"/HOME/. "$source_tmp" &&
  chown -R "$owner:$group" "$source_tmp" &&
  find "$source_tmp" -type f -a \( \
    -path '*/bin/*' -o -path '*.sh' -o -path '*.gtkmenuplus' \
    \) -exec chmod 0755 '{}' \; &&
  cp $opt_verbose -a "$source_tmp"/. "$home_dir"
  status=$?
  rm -rf "$source_tmp"
  [ 0 = $status ]
fi
status=$?
if [ 0 = $status ]; then
  echo "Finished."
else
  echo "Finished with errors."
  exit $status
fi
