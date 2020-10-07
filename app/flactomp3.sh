#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2019-present David Rabkin

# shellcheck source=./base
. "$(dirname "$(realpath "$0")")/base"
if [ 0 -eq $# ] || ! [ -r "$1" ]; then
  die "Usage: $IAM FILENAME.flac"
fi
SRC="$1"
DST="$(printf '%s' "$SRC" | sed 's/\.flac/.mp3/')"
printf 'Convert %s->%s.\n' "$SRC" "$DST"
yes_to_continue
metaflac --export-tags-to=/dev/stdout "$SRC" |
  sed -e 's/=/="/' -e 's/$/"/' \
    -e 's/Album=/ALBUM=/' \
    -e 's/Genre=/GENRE=/' \
    -e 's/Artist=/ARTIST=/' > /tmp/tags-$$
cat /tmp/tags-$$

# shellcheck source=/dev/null
. /tmp/tags-$$
rm /tmp/tags-$$
flac -dc "$SRC" |
    lame -h -b 320 \
      --tt "${TITLE}" \
      --tn "${TRACKNUMBER}" \
      --ty "${DATE}" \
      --ta "${ARTIST}" \
      --tl "${ALBUM}" \
      --tg "${GENRE}" \
      --add-id3v2 /dev/stdin "$DST"
