#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2019 by David Rabkin
# Sets owner to a user from the first argument, set right permitions for files
# and directories started from the seconds argument.

# shellcheck source=../../shellbase/inc/base
. "$(dirname "$(realpath "$0")")/../shellbase/inc/base"
be_root
[ "$#" -eq 2 ] || die "Two arguments are expected, $BASE_IAM USER DIR."
id -u "$1" >/dev/null 2>&1 || die "User $1 doesn't exist."
[ -d "$2" ] || die "Directory $2 doesn't exist."
[ -w "$2" ] || die "Directory $2 is not writable."
log "You're changing owner of directory $2 to user $1."
yes_to_continue
chown -R "$1" "$2"
find "$2" -type d -exec chmod 755 {} \;
find "$2" -type f -exec chmod 644 {} \;
log "Owner of $2 is changed to $1."
exit 0
