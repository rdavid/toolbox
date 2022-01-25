#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2019 - 2021 by David Rabkin
# The script downloads all new video from pre-configured acoounts in
# channels.txt. It updates IDs of downloaded files at done.txt. The script
# could be ran by a cron job. Uses renamr, rsync, transcode, yt-dlp.

# shellcheck source=../../shellbase/inc/base
. "$(dirname "$(realpath "$0")")/../shellbase/inc/base"
OUT="$BASE_LCK/out"
M4V="$BASE_LCK/m4v"
DST='/mnt/nas-ibx/ytb'
ARC='/mnt/nas-ibx/ytb/app/done.txt'
SRC='/mnt/nas-ibx/ytb/app/channels.txt'
CKS='/mnt/nas-ibx/ytb/app/cookies.txt'

# The script is ran by cron, the environment is stricked.
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH="$PATH:/usr/local/bin"

validate 'HandBrakeCLI'
validate 'mp4track'
validate 'rsync'
validate 'renamr'
validate 'transcode'
validate 'yt-dlp'
[ -r $SRC ] || die "Unable to read $SRC."
[ -w $DST ] || die "Unable to write $DST."
[ -w $ARC ] || die "Unable to write $ARC."
mkdir -p "$OUT" || die "Unable to create $OUT."
mkdir -p "$M4V" || die "Unable to create $M4V."
if [ -r $CKS ]; then
  log "Uses cookie $CKS."
  CKS_PARAM="--cookies $CKS"
else
  CKS_PARAM=''
fi

# SC2086: Double quote to prevent globbing and word splitting.
# shellcheck disable=SC2086
yt-dlp \
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
  transcode -d "$OUT" -o "$M4V" -a 2>&1 | tee -a "$BASE_LOG"
  rsync -zvhr --progress "$M4V"/* $DST 2>&1 | tee -a "$BASE_LOG"

  # Makes sure every file was copied succesfully to destination. Pass each file
  # locally and verifies there is a file with a same name at destination.
  nsrc=0
  ndst=0
  pipe="$BASE_LCK/pipe"
  mkfifo "$pipe"
  find "$M4V" -type f -exec basename {} \; > "$pipe" &
  while read -r name; do
    nsrc=$((nsrc + 1))
    [ -f "$DST/$name" ] && ndst=$((ndst + 1))
  done < "$pipe"
  rm "$pipe"

  # Keeps files locally in case of a failure.
  if [ $nsrc -eq 0 ] || [ $nsrc -ne $ndst ]; then
    arc="$BASE_TMP/$BASE_IAM-arc"
    mkdir -p "$arc"
    mv "$OUT"/* "$arc"
    mv "$M4V"/* "$arc"
    loge "There are $nsrc files in $OUT, but $ndst in $DST, archived at $arc."
  else
    log "There are $nsrc files copied to $DST."
  fi
fi
exit 0
