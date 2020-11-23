#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2019-current David Rabkin
# The script downloads all new video from pre-configured acoounts in
# channels.txt. It updates IDs of downloaded files at done.txt. The script
# could be ran by a cron job. Uses youtube-dl, rsync, renamr.

# shellcheck source=./base
. "$(dirname "$(realpath "$0")")/base"
OUT="/$BASE_LCK/out"
DST='/mnt/nas-ibx/ytb'
ARC='/mnt/nas-ibx/ytb/app/done.txt'
SRC='/mnt/nas-ibx/ytb/app/channels.txt'
CKS='/mnt/nas-ibx/ytb/app/cookies.txt'

# The script is ran by cron, the environment is stricked.
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

validate 'rsync'
validate 'renamr'
validate 'youtube-dl'
[ -r $SRC ] || die "Unable to read $SRC."
[ -w $DST ] || die "Unable to write $DST."
[ -w $ARC ] || die "Unable to write $ARC."
mkdir -p "$OUT" || die "Unable to create $OUT."
if [ -r $CKS ]; then
  log "Uses cookie $CKS."
  CKS_PARAM="--cookies $CKS"
else
  CKS_PARAM=''
fi

# SC2086: Double quote to prevent globbing and word splitting.
# shellcheck disable=SC2086
youtube-dl \
  $CKS_PARAM \
  --playlist-reverse \
  --download-archive $ARC \
  -i -o \
  "$OUT/%(uploader)s-%(upload_date)s-%(title)s.%(ext)s" \
  -f bestvideo[ext=mp4]+bestaudio[ext=m4a] \
  --merge-output-format mp4 \
  --add-metadata \
  --batch-file=$SRC \
  2>&1 | tee -a "$BASE_LOG"

# Do nothing if the output directory is empty.
# shellcheck disable=SC2010
if ls -1A "$OUT" | grep -q .; then
  renamr -d "$OUT" -a 2>&1 | tee -a "$BASE_LOG"
  rsync -zvhr --progress "$OUT"/* $DST 2>&1 | tee -a "$BASE_LOG"

  # Makes sure every file was copied succesfully to destination. Pass each file
  # locally and verifies there is a file with a same name at destination.
  nsrc=0
  ndst=0
  pipe="$BASE_LCK/pipe"
  mkfifo "$pipe"
  find "$OUT" -type f -exec basename {} \; > "$pipe" &
  while read -r name; do
    nsrc=$((nsrc + 1))
    [ -f "$DST/$name" ] && ndst=$((ndst + 1))
  done < "$pipe"
  rm "$pipe"

  # Keeps files locally in case of an rsync failure.
  if [ $nsrc -ne $ndst ]; then
    arc="$BASE_TMP/$BASE_IAM-arc"
    mkdir -p "$arc"
    mv "$OUT"/* "$arc"
    loge "There are $nsrc files in $OUT, but $ndst in $DST, archived at $arc."
  else
    rm -f "$OUT"/*
    log "There are $nsrc files copied to $DST."
  fi
fi
rmdir "$OUT"
exit 0
