#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2020 by David Rabkin
#
# The script uses local variables which are not POSIX but supported by most
# shells, see more:
#  https://stackoverflow.com/questions/18597697/posix-compliant-way-to-scope-variables-to-a-function-in-a-shell-script
# Disables shellcheck warning about using non POSIX features.
# shellcheck disable=SC2039
#
# Reports download and upload internet speeds in a loop.

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

test_speed() {
  local out
  if out=$(speedtest-cli --simple 2>&1); then
    log "$(printf '%s' "$out" | \
      grep -E 'Download|Upload' | \
      gawk '{print $2}' | \
      xargs)"
  else
    loge "$(printf '%s' "$out" | xargs)"
    if [ -n "${SERV+x}" ]; then
      if is_repairable "$out"; then
        restart_server
      else
        log 'Server restart will not solve the issue.'
      fi
    fi
    # The function is ran in a loop, rest in case of an error.
    sleep 1
  fi
}

# Start point.
validate 'gawk'
validate 'speedtest-cli'
if [ "$#" -eq 2 ]; then
  validate 'nc'
  validate 'curl'
  has_colon "$1" || die "$1 is not valid parameter for HOST:PORT."
  has_colon "$2" || die "$2 is not valid parameter for USER:PASS."
  is_alive "$1" || die "$1 is unavailable."
  SERV="$1"
  AUTH="$2"
fi
log ' Down   Up'
while :; do
  test_speed
done
exit 0
