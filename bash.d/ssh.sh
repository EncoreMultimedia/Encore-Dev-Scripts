#!/usr/bin/env bash

source "$(dirname "$0")/functions/_depcheck.sh"
source "$(dirname "$0")/functions/_rfind.sh"

! _depcheck "ssh sshpass" && exit 1

### Parse args

while getopts ':c:h' OPT; do
    case $OPT in
        c )
            runcmd=$OPTARG ;;
        h )
            echo "Usage:"
            echo "    ssh [options] [env]"
            echo ""
            echo "Options:"
            echo "    -c 'command'    Run a specific command over ssh"
            echo ""
            echo "Parameters:"
            echo "    env   This is used to specify a configuration with a specific"
            echo "              name, such as live, dev, staging, etc."
            exit 0 ;;
        \? )
            echo "ssh: Invalid option: -$OPTARG" >&2
            exit 1 ;;
    esac
done
shift $((OPTIND -1))

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
    echo "ssh: Configuration file '$config_name' not found in any parent directory" >&2
    echo "ssh: Required environment variables not set. Aborting." >&2
    exit 1
fi

echo "Connecting to $sshuser@$remotehost ... "
if [ -n "$runcmd" ]; then
    sshpass -e ssh "$sshuser@$remotehost" "cd $webroot;$runcmd"
else
    sshpass -e ssh "$sshuser@$remotehost"
fi
