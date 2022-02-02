#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2019 - 2022 by David Rabkin
# The script downloads all new video from pre-configured acoounts in
# channels.txt. It updates IDs of downloaded files at done.txt. The script
# could be ran by a cron job. Uses renamr, rsync, transcode, yt-dlp.

# shellcheck source=../../shellbase/inc/base
. "$(dirname "$(realpath "$0")")/../shellbase/inc/base"

is_directory_empty() {
 # shellcheck disable=SC2010
 ! ls -1qA "$1" | grep -q .
}

RES="$BASE_LCK/res"
AUD="$BASE_LCK/aud"
VID="$BASE_LCK/vid"
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
mkdir -p "$RES" || die "Unable to create $M4V."
mkdir -p "$AUD" || die "Unable to create $M4V."
mkdir -p "$VID" || die "Unable to create $OUT."
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
  "$VID/%(uploader)s-%(upload_date)s-%(title)s.%(ext)s" \
  -f bestvideo[ext=mp4]+bestaudio[ext=m4a] \
  --merge-output-format mp4 \
  --add-metadata \
  --batch-file=$SRC \
  2>&1 | tee -a "$BASE_LOG"
if is_directory_empty "$VID"; then
  exit 0
fi
renamr -d "$VID" -a 2>&1 | tee -a "$BASE_LOG"

# Sorts files to audio and video folders by authors.
while read -r author; do
  if ls "$VID/$author"*; then
    mv "$VID/$author"* "$AUD"
  fi
done <<EOF
mihail-veller
tamara-eidelman
vlast-vs-vlaszhenko
yulia-latynina
zhzl-s-dmitriem-bykovym
EOF
if ! is_directory_empty "$VID"; then
  transcode -d "$VID" -o "$RES" -a 2>&1 | tee -a "$BASE_LOG"
fi
if ! is_directory_empty "$AUD"; then
  transcode -d "$AUD" -o "$RES" -a -m 2>&1 | tee -a "$BASE_LOG"
fi
rsync -zvhr --progress "$RES"/* $DST 2>&1 | tee -a "$BASE_LOG"

# Makes sure every file was copied succesfully to destination. Pass each file
# locally and verifies there is a file with a same name at destination.
nsrc=0
ndst=0
pipe="$BASE_LCK/pipe"
mkfifo "$pipe"
find "$RES" -type f -exec basename {} \; > "$pipe" &
while read -r name; do
  nsrc=$((nsrc + 1))
  [ -f "$DST/$name" ] && ndst=$((ndst + 1))
done < "$pipe"
rm "$pipe"

# Keeps files locally in case of a failure.
if [ $nsrc -eq 0 ] || [ $nsrc -ne $ndst ]; then
  arc="$BASE_TMP/$BASE_IAM-arc"
  mkdir -p "$arc"
  mv "$VID"/* "$arc"
  mv "$AUD"/* "$arc"
  mv "$RES"/* "$arc"
  loge "There are $nsrc files in $RES, but $ndst in $DST, archived at $arc."
else
  log "There are $nsrc files copied to $DST."
fi
exit 0
