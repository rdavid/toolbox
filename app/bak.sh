#!/bin/sh -eu
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
# Copyright 2016-2022 David Rabkin
# Makes incremental backups from the first parameter to the second.
BASE_APP_VERSION=0.9.20220401

# shellcheck source=../../shellbase/inc/base
. "$(dirname "$(realpath "$0")")/../shellbase/inc/base"
validate_cmd rdiff-backup
[ "$#" -eq 2 ] || bye "Usage: $BASE_IAM [source] [destination]"
[ -r "$1" ] || bye "Unable to read from source $1."
[ -w "$2" ] || bye "Unable to write to destination $2."
rdiff-backup \
	--print-statistics \
	--terminal-verbosity 4 \
	--preserve-numerical-ids \
	--force \
	"$1" "$2" \
	2>&1 | while IFS= read -r l; do log "$l"; done
exit 0
