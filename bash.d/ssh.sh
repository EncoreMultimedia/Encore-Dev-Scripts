#!/bin/bash
# shellcheck disable=SC2154

# shellcheck disable=SC2034
my_needed_commands="ssh sshpass"

source "$(dirname "$0")/_depcheck.inc"
source "$(dirname "$0")/_rfind.inc"

config_name=".enc"
[ -n "$1" ] && config_name+="-$1"
enc_path=$(_rfind "$config_name")
enc_path_parent=$(cd "$(dirname "$enc_path")" || exit; pwd -P)

if [ -f "$enc_path" ]; then
    # Found credentials file so let user know and import those vars
    echo "Using configuration found at: $enc_path_parent/$(basename "$enc_path")"
    source "$enc_path"
elif [ -z "$webroot" ]; then
    # Did not find credentials file and the vars aren't set
    echo "get-db: Configuration file '$config_name' not found in any parent directory" >&2
    echo "get-db: Required environment variables not set. Aborting." >&2
    exit 1
fi

echo "Connecting to $sshuser@$remotehost ... "
sshpass -e ssh "$sshuser@$remotehost"