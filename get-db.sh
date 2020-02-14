#!/bin/bash

source "$(dirname $0)/_rfind.inc"

### Check dependencies

my_needed_commands="ssh sshpass"

missing_counter=0
for needed_command in $my_needed_commands; do
    if ! [ -x "$(command -v $needed_command)" ]; then
        echo "Dependency '$needed_command' not found." >&2
        ((missing_counter++))
    fi
done

if ((missing_counter > 0)); then
    printf "%d required commands are missing. Aborting.\n" "$missing_counter" >&2
    exit 1
fi

config_name=".enc"
[ -n "$1" ] && config_name+="-$1"
enc_path=$(_rfind "$config_name")

if [ -f "$enc_path" ]; then
    # Found credentials file so let user know and import those vars
    echo "Using configuration found at: $(cd "$(dirname "$enc_path")"; pwd -P)/$(basename "$enc_path")"
    source "$enc_path"
elif [ -z "$webroot" ]; then
    # Did not find credentials file and the vars aren't set
    echo "get-db: Configuration file '$config_name' not found in any parent directory" >&2
    echo "get-db: Required environment variables not set. Aborting." >&2
    exit 1
fi

[ -z "$remotedrush" ] && remotedrush=drush
if [ -n "$1" ]; then
    envname=$1
else
    envname=live
fi

echo "Getting database from $sshuser@$remotehost:$webroot ... "
sshpass -e ssh "$sshuser@$remotehost" "cd $webroot;$remotedrush sql-dump | gzip > ../db-$envname.sql.gz"
sshpass -e scp "$sshuser@$remotehost:db-$envname.sql.gz" "$(cd "$(dirname "$enc_path")"; pwd -P)"
sshpass -e ssh "$sshuser@$remotehost" "rm db-$envname.sql.gz"
echo "Saved to: $(cd "$(dirname "$enc_path")"; pwd -P)/db-$envname.sql.gz"
