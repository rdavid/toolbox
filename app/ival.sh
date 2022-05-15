#!/bin/sh -eu
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
# Copyright 2020-2022 David Rabkin
# Validates image files.

# shellcheck source=/usr/local/bin/shellbase
. shellbase
validate_cmd convert
[ "$#" -eq 1 ] || die "Usage: $BASE_IAM DIRECTORY"
[ -r "$1" ] || die "Unable to read $1."
find "$1" -type f \
	\( -name \*.jpg -o -name \*.nef -o -name \*.raf -o -name \*.heic \) |
	while read -r img; do
		convert "$img" null >/dev/null 2>&1 || loge "File is corrupted: $img."
	done
exit 0
