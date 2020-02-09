#!/usr/bin/env bash

_rfind () {
    needle=$1
    cwd=$PWD
    path=.

    while [ "$cwd" != "$(dirname "$cwd")" ]; do
        if [ -e "$cwd/$needle" ]; then
            echo $path/$needle
            return 0
        else
            path=../$path
            cwd="$(dirname "$cwd")"
        fi
    done

    echo ""
    return 1
}

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
            echo "    remote-pull [options]"
            echo ""
            echo "Options:"
            echo "    -c    (Drupal 7) Clears cache with 'drush cc all' after pull"
            echo "    -r    (Drupal 8) Clears cache with 'drush cr' after pull"
            echo "    -u    Runs 'drush updb -y' after pull"
            echo "    -h    this information"
            exit 0 ;;
        \? )
            echo "remote-pull: Invalid option: -$OPTARG" >&2
            exit 1 ;;
    esac
done
shift $((OPTIND -1))

config_name=".enc"
[ -n "$1" ] && config_name+="-$1"
enc_path=$(_rfind $config_name)

if [ -f "$enc_path" ]; then
    # Found credentials file so let user know and import those vars
    echo "Using configuration found at: $(cd "$(dirname "$enc_path")"; pwd -P)/$(basename "$enc_path")"
    source $enc_path
elif [ -z "$webroot" ]; then
    # Did not find credentials file and the vars aren't set
    echo "remote-pull: Configuration file '$config_name' not found in any parent directory" >&2
    echo "remote-pull: Required environment variables not set. Aborting." >&2
    exit 1
fi

command="cd $webroot;git reset --hard HEAD;"
command+="git pull 'https://$ghuser:$ghpass@github.com/$repo.git';"

[ -z "$remotedrush" ] && remotedrush=drush
[ -n "$dcc" ] && command+="$remotedrush cc all;"
[ -n "$dcr" ] && command+="$remotedrush cr;"
[ -n "$updb" ] && command+="$remotedrush updb -y;"

sshpass -e ssh $sshuser@$remotehost $command
