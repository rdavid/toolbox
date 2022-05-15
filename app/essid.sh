#!/bin/sh -eu
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
# Copyright 2020-2022 David Rabkin
# It watches Wi-Fi ESSID change and report.

# shellcheck source=/usr/local/bin/shellbase
. shellbase
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
while :; do
	wait
	copy
	list
	comp
done
exit 0
