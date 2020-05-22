#!/bin/bash
# shellcheck disable=SC2154

source "$(dirname "$0")/functions/_depcheck.sh"
source "$(dirname "$0")/functions/_rfind.sh"

! _depcheck "ssh sshpass scp" && exit 1

install=""

### Parse args

while getopts ':ih' OPT; do
    case $OPT in
        i )
            install="/public_html" ;;
        h )
            echo "Usage:"
            echo "    get-db [options] [env]"
            echo ""
            echo "Options:"
            echo "    -i    Import db into Lando (must be running) after downloading"
            echo ""
            echo "Parameters:"
            echo "    env   This is used to specify a configuration with a specific"
            echo "              name, such as live, dev, staging, etc."
            exit 0 ;;
        \? )
            echo "get-db: Invalid option: -$OPTARG" >&2
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
    echo "get-db: Configuration file '$config_name' not found in any parent directory" >&2
    echo "get-db: Required environment variables not set. Aborting." >&2
    exit 1
fi

if [[ $sitetype == drupal* ]]; then
    [ -z "$remotedrush" ] && remotedrush=drush
    dumpcommand="$remotedrush sql-dump"
else
    echo "Only Drupal sites are currently supported. Aborting."
    exit 1
fi

if [ -n "$1" ]; then
    envname=$1
else
    envname=live
fi

echo "Getting database from $sshuser@$remotehost:$webroot ... "
sshpass -e ssh "$sshuser@$remotehost" "cd $webroot;$dumpcommand | gzip > ../db-$envname.sql.gz"
sshpass -e scp "$sshuser@$remotehost:db-$envname.sql.gz" "$enc_path_parent$install"
sshpass -e ssh "$sshuser@$remotehost" "rm db-$envname.sql.gz"
[ -n "$install" ] && cd "$enc_path_parent$install" && lando db-import "db-$envname.sql.gz" && mv "db-$envname.sql.gz" ..
echo "Saved to: $enc_path_parent/db-$envname.sql.gz"
