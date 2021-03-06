#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2019 by David Rabkin

# shellcheck source=../../shellbase/inc/base
. "$(dirname "$(realpath "$0")")/../shellbase/inc/base"
[ "$#" -eq 1 ] || die "Usage: $BASE_IAM FILENAME.flac"
[ -r "$1" ] || die "Unable to read from source $1."
SRC="$1"
TAG="/$BASE_LCK/tags"
DST="$(printf '%s' "$SRC" | sed 's/\.flac/.mp3/')"
printf 'Convert %s->%s.\n' "$SRC" "$DST"
yes_to_continue
metaflac --export-tags-to=/dev/stdout "$SRC" |
  sed -e 's/=/="/' -e 's/$/"/' \
    -e 's/Album=/ALBUM=/' \
    -e 's/Genre=/GENRE=/' \
    -e 's/Artist=/ARTIST=/' > "$TAG"
cat "$TAG"

# shellcheck source=/dev/null
. "$TAG"
rm "$TAG"
flac -dc "$SRC" |
  lame -h -b 320 \
    --tt "${TITLE}" \
    --tn "${TRACKNUMBER}" \
    --ty "${DATE}" \
    --ta "${ARTIST}" \
    --tl "${ALBUM}" \
    --tg "${GENRE}" \
    --add-id3v2 /dev/stdin "$DST"
exit 0
