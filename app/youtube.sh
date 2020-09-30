#!/bin/sh -e
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2019-current David Rabkin
# The script downloads all new video from pre-configured acoounts in
# channels.txt. It updates IDs of downloaded files at done.txt. The script
# could be ran by a cron job. Uses youtube-dl, rsync, renamr.

. base
SRC='/mnt/nas-ibx/ytb/app/channels.txt'
ARC='/mnt/nas-ibx/ytb/app/done.txt'
DST='/mnt/nas-ibx/ytb'
TMP='/tmp/out'

# The script is ran by cron, the environment is stricked.
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

validate 'rsync'
validate 'renamr'
validate 'youtube-dl'
mkdir -p $TMP || die "Unable to create $TMP."
youtube-dl \
  --playlist-reverse \
  --download-archive $ARC \
  -i -o \
  "$TMP/%(uploader)s-%(upload_date)s-%(title)s.%(ext)s" \
  -f bestvideo[ext=mp4]+bestaudio[ext=m4a] \
  --merge-output-format mp4 \
  --add-metadata \
  --batch-file=$SRC \
  2>&1 | tee -a "$LOG"
# Do nothing if the output directory is empty.
# shellcheck disable=SC2010
if ls -1A $TMP | grep -q .; then
  renamr -d $TMP -a 2>&1 | tee -a "$LOG"
  rsync -zvhr --progress $TMP/* $DST 2>&1 | tee -a "$LOG"
fi
rm -rf $TMP
exit 0
