#!/bin/sh -eu
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
# Copyright 2020-2022 David Rabkin
#
# The script uses local variables which are not POSIX but supported by most
# shells, see more:
#  https://stackoverflow.com/questions/18597697/posix-compliant-way-to-scope-variables-to-a-function-in-a-shell-script
# Disables shellcheck warning about using local variables.
# shellcheck disable=SC3043
#
# Reports download and upload internet speeds in a loop.
BASE_APP_VERSION=0.9.20220429

# shellcheck source=../../shellbase/inc/base
. "$(dirname "$(realpath "$0")")/../shellbase/inc/base"

# Verifies if a parameter has colon.
has_colon() {
	case "$1" in
		*:*)
			true
			;;
		*)
			false
			;;
	esac
}

# Verifies if host is up. The parameter is HOST:PORT
is_alive() {
	# shellcheck disable=SC2046
	nc -z $(printf '%s' "$1" | tr ':' ' ') >/dev/null 2>&1
}

restart_server() {
	if ! is_alive "$SERV"; then
		loge "Server $SERV is dead."
		return
	fi
	local out
	if out=$(curl -u "$AUTH" "http://$SERV/reseau-pa4-logs.cgi" 2>&1); then
		log "Curl output: $(printf '%s' "$out" | xargs)."
		sleep 10
		while ! is_alive "$SERV"; do
			log "Wait for $SERV to be online."
			sleep 1
		done
		sleep 20
		log "$SERV is restarted."
	else
		loge "Curl failed: $(printf '%s' "$out" | xargs)"
	fi
}

# Parses error message to decide restart will help or not.
is_repairable() {
	case "$1" in
		*No\ matched\ servers*)
			false
			;;
		*Cannot\ retrieve*)
			true
			;;
		*)
			true
			;;
	esac
}

# Prints current download and upload speeds.
test_speed() {
	local out
	url_exists google.com || { loge Check internet connection.; return 1; }
	if out=$(speedtest-cli 2>&1); then
		local host
		local speed
		out=$(printf %s "$out" | grep -E 'Download: |Upload: |Hosted by ')
		speed=$(printf %s "$out" | \
			tail --lines=2 | \
			gawk '{print $2}' | \
			xargs)
		host=$(printf %s "$out" | \
			head --lines=1 | \
			cut -c11-)
		base_tim "$speed $host"
		return 0
	fi
	loge "$(printf '%s' "$out" | xargs)"
	if [ -n "${SERV+x}" ]; then
		if is_repairable "$out"; then
			restart_server
		else
			log Server restart will not solve the issue.
		fi
	fi

	# The function is ran in a loop, rest in case of an error.
	sleep 1
}

# Prints top title.
title() {
	base_tim " Down |  Up |  Host by | since $(base_duration "$BASE_BEGIN")"
}

# Starting point.
validate_cmd gawk speedtest-cli
if [ "$#" -eq 2 ]; then
	validate_cmd nc curl
	has_colon "$1" || bye "$1 is not valid parameter for HOST:PORT."
	has_colon "$2" || bye "$2 is not valid parameter for USER:PASS."
	is_alive "$1" || bye "$1 is unavailable."
	SERV="$1"
	AUTH="$2"
fi

# The index starts with 0, it guarantees the title printing from the begging.
i=0
while :; do
	[ $((i%30)) -eq 0 ] && title
	test_speed
	i=$((i+1))
done
exit 0
