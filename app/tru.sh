#!/bin/sh -eu
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
# Copyright 2020-2022 David Rabkin
# tru stands for Transmission Remote Updater. The script removes a torrent with
# content and than adds it again. It is usefull to automatically increase a
# ratio.
BASE_APP_VERSION=0.9.20220803

# shellcheck source=/usr/local/bin/shellbase
. shellbase
AUT=''
CMD=transmission-remote

# Looks for torrent ID by torrent file name.
tid() {
	# SC2086: Double quote to prevent globbing and word splitting.
	# shellcheck disable=SC2086
	$CMD "$SER" $AUT --list | grep "$FIL" | awk '{print $1}'
}

validate_cmd nc tr awk $CMD
[ "$#" -eq 3 ] || die Usage: tru.sh host:port user:pass torrent-file.

# Prepares host and port to be nc command parameters. Validates the first
# parameter host:port.
prm="$(printf '%s' "$1" | tr ':' ' ')"
# shellcheck disable=SC2086
nc -z $prm >/dev/null 2>&1 || die "$1 is not valid parameter for HOST:PORT."
SER="$1"

# Single ':' means there is no authentication data.
if [ "$2" != ':' ]; then
	AUT="--auth $2"
fi

# Validates third parameter full torrent file name.
[ -r "$3" ] || die "$3 is not valid parameter for a TORRENT-FILE."
TOR="$3"
FIL=$(basename -- "$TOR")
FIL="${FIL%.*}"

# Looks for torrent ID by torrent name extracted from torrent file name.
tid=$(tid)
if [ -n "$tid" ]; then
	# SC2086: Double quote to prevent globbing and word splitting.
	# shellcheck disable=SC2086
	{
		$CMD "$SER" $AUT --remove-and-delete --torrent "$tid" \
			2>&1 1>&3 3>&- | to_loge
	} \
		3>&1 1>&2 | to_log
	log "$FIL $tid is removed from $SER."
fi

# Adds torrent file name to torrent server.
# SC2086: Double quote to prevent globbing and word splitting.
# shellcheck disable=SC2086
{
	$CMD "$SER" $AUT --add "$TOR" \
		2>&1 1>&3 3>&- | to_loge
} \
	3>&1 1>&2 | to_log

# Verifies that a torrent was added.
tid=$(tid)
if [ -z "$tid" ]; then
	die "Unable to find $FIL at $SER."
fi
log "$FIL $tid is added to $SER."
exit 0
