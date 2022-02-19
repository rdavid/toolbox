#!/usr/bin/env zsh
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
#
# tss.sh - Terminal Screen Saver.
#
# Copyright 2017-2022 David Rabkin

# All cowsay types in array.
declare -a TYPE=( $(cowsay -l | tail -n +2) )

# Seeds random generator.
RANDOM=$$$(date +%s)

while :; do
	rand=$(($RANDOM % ${#TYPE[@]}))
	type=${TYPE[rand]}
	fortune | cowsay -f "$type" | lolcat
	sleep 10
done
