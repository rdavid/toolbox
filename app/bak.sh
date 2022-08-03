#!/bin/sh -eu
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
# Copyright 2016-2022 David Rabkin
# Makes incremental backups from the first parameter to the second.
BASE_APP_VERSION=0.9.20220803

# shellcheck source=/usr/local/bin/shellbase
. shellbase
validate_cmd rdiff-backup
[ "$#" -eq 2 ] || die Usage: bak.sh source destination.
SRC="$1"
DST="$2"
is_readable "$SRC" || die "$SRC" is not readable.
is_writable "$DST" || die "$DST" is not writable.
{
	rdiff-backup \
		--force \
		--preserve-numerical-ids \
		--print-statistics \
		--terminal-verbosity 4 \
		"$SRC" "$DST" \
		2>&1 1>&3 3>&- | to_loge
} \
	3>&1 1>&2 | to_log
exit 0
