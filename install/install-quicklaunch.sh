#!/bin/sh

if [ -z "$HOME" ]; then
  echo >&2 "\$HOME isn't set. Please log in as a real user and try again."
  exit 1
fi

case $1 in
  -h|--help)
    echo >&2 "Usage: [DEST_DIR='/path/to/destination/dir'] ${0##*/}
Default destination: '/' (needs root access rights)."
    exit
    ;;
esac

source_dir=$(realpath -m "${0%/*}/../quicklaunch")
dest_dir=${DEST_DIR:-/}
COLUMNS=`stty -a | awk -v RS=\; '/columns/{print $(NF)}'`

{
echo "Ready to copy contents of '$source_dir' into '$dest_dir'."
if [ -d "$source_dir/HOME" ]; then
  echo "Contents of source path '$source_dir/HOME' will be copied into destination path '$HOME'."
fi
} | fmt -$((${COLUMNS:-80} -1))

trap 'echo; echo "Bailing out."; exit 128' HUP INT QUIT TERM ABRT
echo -n "Press ENTER to begin copying or Ctrl+C to stop."
if read -r; then
  set +f
  for p in "$source_dir"/*; do
    case ${p##*/} in
      HOME)
        (
        set +f
        set -- "$p"/.[a-zA-Z0-9_]*
        case $1 in
          *\*)
            : no such source objects
            ;;
          *)
            cp -a "$p"/.[a-zA-Z0-9_]* "$HOME"
            ;;
        esac
        set -- "$p"/*
        case $1 in
          *\*)
            : no such source objects
            ;;
          *)
            cp -a "$p"/* "$HOME"
            ;;
        esac
        )
        ;;
      *)
        cp -a "$p" "$dest_dir"
        ;;
    esac
  done
fi

echo "Finished."
