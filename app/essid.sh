#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2020-2022 David Rabkin
# It watches Wi-Fi ESSID change and report.

# shellcheck source=../../shellbase/inc/base
. "$(dirname "$(realpath "$0")")/../shellbase/inc/base"
OLD="/$BASE_TMP/$BASE_IAM-old"
CUR="/$BASE_TMP/$BASE_IAM-cur"

list() {
	iwlist wlan0 s | grep ESSID | tr -s ' ' | cut -d':' -f2 > "$CUR"
}

copy() {
	cp -f "$CUR" "$OLD"
}

wait() {
	sleep 5
}

comp() {
	out='ESSID list is'
	changed=$(diff -y --suppress-common-lines "$CUR" "$OLD" | wc -l)
	if [ "$changed" -ne '0' ]; then
		out="$out changed on $changed. Alert!"
	else
		out="$out not changed."
	fi
	log "$out"
}

be_root
validate_cmd iwlist
list
while true; do
	wait
	copy
	list
	comp
done
exit 0
