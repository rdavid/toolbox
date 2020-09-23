#!/bin/sh -e
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2019-present David Rabkin

if [ 0 -eq $# ]; then
  printf 'flactomp3.sh <file name>\n'
  exit 0
fi
FLAC="$1"
if [ ! -f "$FLAC" ]; then
  printf 'File %s does not exist.\n' "$FLAC"
  exit 0
fi
MP3=$(echo "${FLAC}" | sed 's/\.flac/.mp3/')
printf 'Convert %s->%s, are you sure? [y/N] ' "$FLAC" "$MP3"
CFG=$(stty -g)
stty raw -echo; ans=$(head -c 1); stty "$CFG"
if ! echo "$ans" | grep -iq "^y"; then
  printf '\n'
  exit 0
fi
metaflac --export-tags-to=/dev/stdout "${FLAC_FILE}" |
  sed -e 's/=/="/' -e 's/$/"/' \
    -e 's/Album=/ALBUM=/' \
    -e 's/Genre=/GENRE=/' \
    -e 's/Artist=/ARTIST=/' > /tmp/tags-$$
cat /tmp/tags-$$

# shellcheck source=/dev/null
. /tmp/tags-$$
rm /tmp/tags-$$
flac -dc "${FLAC_FILE}" |
    lame -h -b 320 \
      --tt "${TITLE}" \
      --tn "${TRACKNUMBER}" \
      --ty "${DATE}" \
      --ta "${ARTIST}" \
      --tl "${ALBUM}" \
      --tg "${GENRE}" \
      --add-id3v2 /dev/stdin "${MP3_FILE}"
