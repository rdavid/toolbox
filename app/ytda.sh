#!/bin/sh -eu
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
# Copyright 2019-2022 David Rabkin
# The script downloads all new video from pre-configured acoounts in
# ytda.lst. It updates IDs of downloaded files at done.txt (ytda.dne in Github).
# The script could be ran by a cron job. Uses: curl, HandBrakeCLI, mp4track,
# renamr, rsync, transcode, yt-dlp.
BASE_APP_VERSION=0.9.20220429

# shellcheck source=../../shellbase/inc/base
. "$(dirname "$(realpath "$0")")/../shellbase/inc/base"

RES="$BASE_LCK/res"
AUD="$BASE_LCK/aud"
VID="$BASE_LCK/vid"
DST=/mnt/nas-ibx/ytb
ARC=/mnt/nas-ibx/ytb/app/done.txt
CKS=/mnt/nas-ibx/ytb/app/cookies.txt
SRC="$(dirname "$(realpath "$0")")/../cfg/ytda.lst"
AUT="$(dirname "$(realpath "$0")")/../cfg/ytda.aut"

# The script is ran by cron, the environment is stricked.
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH="$PATH:/usr/local/bin"

# Makes sure that needed software packages are installed at the host.
validate_cmd HandBrakeCLI mp4track rsync renamr tput transcode yt-dlp
url_exists http://youtube.com || bye Check internet connection.
is_writable $DST $ARC
is_readable "$AUT" "$SRC"
for d in $RES $AUD $VID; do mkdir -p "$d" || bye "Unable to create $d."; done
if is_readable $CKS; then
	log "Uses cookie $CKS."
	CKS_PARAM="--cookies $CKS"
else
	CKS_PARAM=''
fi

# SC2086: Double quote to prevent globbing and word splitting.
# shellcheck disable=SC2086
yt-dlp \
	$CKS_PARAM \
	--add-metadata \
	--batch-file=$SRC \
	--download-archive $ARC \
	--format bestvideo+bestaudio \
	--merge-output-format mp4 \
	--output "$VID/%(uploader)s-%(upload_date)s-%(title)s.%(ext)s" \
	--playlist-reverse \
	2>&1 | while IFS= read -r l; do log "$l"; done

# Stops if there are no downloaded files.
is_empty "$VID" && { log There is no new downloaded video.; exit 0; }

# Calculates output table width for renamr and transcode utilities.
WID=$(( $(tput cols) - $(printf '19700101-01:01:01 I ' | wc -m) ))
[ "$WID" -le 1 ] && bye "Terminal's width $(tput cold) is too small."

# Renames all downloaded files to the same manner: ASCII, lower case, no
# spaces.
renamr \
	--act \
	--dir "$VID" \
	--wid "$WID" \
	2>&1 | while IFS= read -r l; do log "$l"; done

# Sorts files to audio and video folders by authors.
while read -r a; do
	file_exists "$VID/$a"* && mv "$VID/$a"* "$AUD"
done < "$AUT"
is_empty "$VID" || \
	transcode \
		--act \
		--dir "$VID" \
		--out "$RES" \
		--wid "$WID" \
		2>&1 | while IFS= read -r l; do log "$l"; done
is_empty "$AUD" || \
	transcode \
		--act \
		--dir "$AUD" \
		--mp3 \
		--out "$RES" \
		--wid "$WID" \
		2>&1 | while IFS= read -r l; do log "$l"; done
rsync \
	--compress \
	--human-readable \
	--progress \
	--verbose \
	"$RES"/* $DST \
	2>&1 | while IFS= read -r l; do log "$l"; done

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
