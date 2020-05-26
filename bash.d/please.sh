#!/usr/bin/env bash

source "$(dirname "$0")/functions/_depcheck.sh"
source "$(dirname "$0")/functions/_rfind.sh"

! _depcheck "ssh sshpass" && exit 1

### Parse args

while getopts ':h' OPT; do
    case $OPT in
        h )
            echo "Usage:"
            echo "    please [env] please_params"
            echo ""
            echo "Parameters:"
            echo "    env   This is used to specify a configuration with a specific"
            echo "              name, such as live, dev, staging, etc."
            exit 0 ;;
        \? )
            echo "please: Invalid option: -$OPTARG" >&2
            exit 1 ;;
    esac
done
shift $((OPTIND -1))

config_name=".enc-$1"
enc_path=$(_rfind "$config_name")
enc_path_parent=$(cd "$(dirname "$enc_path")" || exit; pwd -P)

if [ -f "$enc_path" ]; then
    shift 1
else
    config_name=".enc"
    enc_path=$(_rfind "$config_name")
fi

if [ -f "$enc_path" ]; then
    # Found credentials file so let user know and import those vars
    echo "Using configuration found at: $enc_path_parent/$(basename "$enc_path")"
    source "$enc_path"
elif [ -z "$webroot" ]; then
    # Did not find credentials file and the vars aren't set
    echo "please: Configuration file '$config_name' not found in any parent directory" >&2
    echo "please: Required environment variables not set. Aborting." >&2
    exit 1
fi

if [[ "$sitetype" != statamic* ]]; then
    echo "Cannot run please on a non-Statamic site." >&2
fi

echo "Connecting to $sshuser@$remotehost ... "
sshpass -e ssh "$sshuser@$remotehost" "cd $webroot;php please ${*:1}"
