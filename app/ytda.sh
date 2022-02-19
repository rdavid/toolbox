#!/bin/sh -eu
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
# Copyright 2019-2022 David Rabkin
# The script downloads all new video from pre-configured acoounts in
# ytda.lst. It updates IDs of downloaded files at done.txt (ytda.dne in Github).
# The script could be ran by a cron job. Uses: HandBrakeCLI, mp4track, rsync,
# renamr, transcode, yt-dlp.

# shellcheck source=../../shellbase/inc/base
. "$(dirname "$(realpath "$0")")/../shellbase/inc/base"

RES="$BASE_LCK/res"
AUD="$BASE_LCK/aud"
VID="$BASE_LCK/vid"
DST=/mnt/nas-ibx/ytb
ARC=/mnt/nas-ibx/ytb/app/done.txt
CKS=/mnt/nas-ibx/ytb/app/cookies.txt
SRC="$(dirname "$(realpath "$0")")/../cfg/ytda.lst"

# The script is ran by cron, the environment is stricked.
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH="$PATH:/usr/local/bin"

# Makes sure that needed software packages are installed at the host.
validate_cmd HandBrakeCLI mp4track rsync renamr transcode yt-dlp
[ -r "$SRC" ] || bye "Unable to read $SRC."
for f in $DST $ARC; do [ -w $f ] || bye "Unable to write $f."; done
for d in $RES $AUD $VID; do mkdir -p "$d" || bye "Unable to create $d."; done
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

# Stops if there are no downloaded files.
is_empty "$VID" && { log 'There is no new downloaded video.'; exit 0; }

# Renames all downloaded files to the same manner: ASCII, lower case, no
# spaces.
renamr -d "$VID" -a 2>&1 | tee -a "$BASE_LOG"

# Sorts files to audio and video folders by authors.
while read -r author; do
	file_exists "$VID/$author"* && mv "$VID/$author"* "$AUD"
done <<EOF
mihail-veller
tamara-eidelman
vlast-vs-vlaszhenko
yulia-latynina
zhzl-s-dmitriem-bykovym
EOF
is_empty "$VID" || \
	transcode -d "$VID" -o "$RES" -a 2>&1 | tee -a "$BASE_LOG"
is_empty "$AUD" || \
	transcode -d "$AUD" -o "$RES" -a -m 2>&1 | tee -a "$BASE_LOG"
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
	is_empty "$VID" || mv "$VID"/* "$arc"
	is_empty "$AUD" || mv "$AUD"/* "$arc"
	is_empty "$RES" || mv "$RES"/* "$arc"
	logw "There are $nsrc files in $RES, but $ndst in $DST, archived at $arc."
else
	log "There are $nsrc files copied to $DST."
fi
exit 0
