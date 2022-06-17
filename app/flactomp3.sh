#!/bin/sh -eu
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
# Copyright 2019-2022 David Rabkin

# shellcheck source=/usr/local/bin/shellbase
. shellbase
[ "$#" -eq 1 ] || die Usage: flactomp3.sh FILENAME.flac.
SRC="$1"
is_readable "$SRC" || die "$SRC" is not readable.
DST="$(printf %s "$SRC" | sed 's/\.flac/.mp3/')"
yes_to_continue Convert "$SRC" to "$DST"?
TAG="/$BASE_LCK/tags"
metaflac --export-tags-to=/dev/stdout "$SRC" |
	sed \
		-e 's/=/="/' \
		-e 's/$/"/' \
		-e 's/Album=/ALBUM=/' \
		-e 's/Genre=/GENRE=/' \
		-e 's/Artist=/ARTIST=/' > "$TAG"
cat "$TAG"

# shellcheck source=/dev/null
. "$TAG"
rm "$TAG"
flac -dc "$SRC" |
	lame \
		-b 320 \
		-h \
		--ta "${ARTIST}" \
		--tg "${GENRE}" \
		--tl "${ALBUM}" \
		--tn "${TRACKNUMBER}" \
		--tt "${TITLE}" \
		--ty "${DATE}" \
		--add-id3v2 /dev/stdin "$DST"
exit 0
