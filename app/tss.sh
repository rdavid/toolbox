#!/usr/bin/env zsh
# vim: tabstop=2 shiftwidth=2 expandtab textwidth=80 linebreak wrap
#
# tss.sh - Terminal Screen Saver.
#
# Copyright 2017 David Rabkin

# All cowsay types in array.
declare -a TYPE=( $(cowsay -l | tail -n +2) )

# Seeds random generator.
RANDOM=$$$(date +%s)

while true
do
  rand=$(($RANDOM % ${#TYPE[@]}))
  type=${TYPE[rand]}
  fortune | cowsay -f "$type" | lolcat
  sleep 10
done
