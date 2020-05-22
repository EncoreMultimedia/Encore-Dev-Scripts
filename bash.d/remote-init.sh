#!/usr/bin/env bash

source "$(dirname "$0")/functions/_depcheck.sh"
source "$(dirname "$0")/functions/_rfind.sh"

! _depcheck "ssh sshpass" && exit 1

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
    echo "remote-init: Configuration file '$config_name' not found in any parent directory" >&2
    echo "remote-init: Required environment variables not set. Aborting." >&2
    exit 1
fi

command="cd $webroot;rm -rf *;git clone 'https://$ghuser:$ghpass@github.com/$ghrepo.git' .;"

echo "Cloning repo into $sshuser@$remotehost:$webroot ... "
sshpass -e ssh "$sshuser@$remotehost" "$command"
echo "done!"
