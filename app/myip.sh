#!/bin/sh -eu
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
# Copyright 2022 David Rabkin
#
# The script uses local variables which are not POSIX but supported by most
# shells, see more:
#  https://stackoverflow.com/questions/18597697/posix-compliant-way-to-scope-variables-to-a-function-in-a-shell-script
# Disables shellcheck warning about using local variables.
# shellcheck disable=SC3043
#
# Reports external IP in a loop.
BASE_APP_VERSION=0.9.20220830

# shellcheck source=/usr/local/bin/shellbase
. shellbase

# Prints external IP.
myip() {
	local ip out state
	ip="$(dig +short myip.opendns.com @resolver4.opendns.com 2>&1)" ||
		{ loge dig failed: "$ip"; return 0; }
	out="$(whois "$ip" 2>&1)" || { loge whois "$ip" failed: "$out"; return 0; }
	state="$(
		printf %s "$out" |
			awk -F':[ \t]+' 'tolower($1) ~ /^country$/ { print toupper($2) }'
	)"
	log "$(printf %15s "$ip") |   $state  |"
}

# Prints top title.
title() {
	log "       IP       | State | since $(base_duration "$BASE_BEGIN")"
}

wait() {
	sleep 5
}

# Starting point.
validate_cmd awk dig whois

# The index starts with 0, it guarantees the title printing from the begging.
i=0
while :; do
	[ $((i%12)) -eq 0 ] && title
	myip
	wait
	i=$((i+1))
done
exit 0
