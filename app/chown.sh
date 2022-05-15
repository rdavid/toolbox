#!/bin/sh -eu
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
# Copyright 2019-2022 David Rabkin
# Sets owner to a user from the first argument, set right permitions for files
# and directories started from the seconds argument.
BASE_APP_VERSION=0.9.20220401

# shellcheck source=/usr/local/bin/shellbase
. shellbase
be_root
[ "$#" -eq 2 ] || die "Two arguments are expected, $BASE_IAM USER DIR."
USR="$1"
DIR="$2"
id -u "$USR" >/dev/null 2>&1 || die "User $USR doesn't exist."
[ -d "$DIR" ] || die "Directory $DIR doesn't exist."
[ -w "$DIR" ] || die "Directory $DIR is not writable."
chown -R "$USR" "$DIR"
find "$DIR" -type d -exec chmod 755 {} \;
find "$DIR" -type f -exec chmod 644 {} \;
printf 'Owner of %s is changed to %s.\n' "$DIR" "$USR"
exit 0
