#!/bin/sh -eu
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
# Copyright 2019-2022 David Rabkin

# shellcheck source=/usr/local/bin/shellbase
. shellbase
[ "$#" -eq 1 ] || die "Usage: $BASE_IAM FILENAME.flac"
[ -r "$1" ] || die "Unable to read from source $1."
SRC="$1"
TAG="/$BASE_LCK/tags"
DST="$(printf '%s' "$SRC" | sed 's/\.flac/.mp3/')"
printf 'Convert %s->%s.\n' "$SRC" "$DST"
yes_to_continue
metaflac --export-tags-to=/dev/stdout "$SRC" |
	sed -e 's/=/="/' \
	    -e 's/$/"/' \
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
