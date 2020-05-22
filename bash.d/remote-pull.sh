#!/usr/bin/env bash

source "$(dirname "$0")/functions/_depcheck.sh"
source "$(dirname "$0")/functions/_rfind.sh"

! _depcheck "ssh sshpass" && exit 1

### Parse args

while getopts ':cruh' OPT; do
    case $OPT in
        c )
            dcc="YES" ;;
        r )
            dcr="YES" ;;
        u )
            updb="YES" ;;
        h )
            echo "Usage:"
            echo "    remote-pull [options] [env]"
            echo ""
            echo "Options:"
            echo "    -c    (Drupal 7) Clears cache with 'drush cc all' after pull"
            echo "    -r    (Drupal 8) Clears cache with 'drush cr' after pull"
            echo "    -u    Runs 'drush updb -y' after pull"
            echo "    -h    this information"
            echo ""
            echo "Parameters:"
            echo "    env   This is used to specify a configuration with a specific"
            echo "              name, such as live, dev, staging, etc."
            exit 0 ;;
        \? )
            echo "remote-pull: Invalid option: -$OPTARG" >&2
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
    echo "remote-pull: Configuration file '$config_name' not found in any parent directory" >&2
    echo "remote-pull: Required environment variables not set. Aborting." >&2
    exit 1
fi

command="cd $webroot;git reset --hard HEAD;"
command+="git pull 'https://$ghuser:$ghpass@github.com/$ghrepo.git';"

if [[ $sitetype == drupal* ]]; then
    [ -z "$remotedrush" ] && remotedrush=drush
    [ -n "$dcc" ] && command+="$remotedrush cc all;"
    [ -n "$dcr" ] && command+="$remotedrush cr;"
    [ -n "$updb" ] && command+="$remotedrush updb -y;"
fi

echo "Pulling latest code to $sshuser@$remotehost:$webroot ... "
sshpass -e ssh "$sshuser@$remotehost" "$command"
echo "done!"
