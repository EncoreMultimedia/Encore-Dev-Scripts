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

config_name=".enc"
[ -n "$1" ] && config_name+="-$1"

# As macOS bash doesn't support `read -i` which is needed below, we do this:
if [ -f $PWD/$config_name ]; then
    echo "File '$config_name' will be overwritten in this directory: $PWD"
else
    echo "File '$config_name' will be created in this directory: $PWD"
fi

# while : ; do
#     read -rep "Enter a location for the new file '$config_name': " -i "$PWD" config_path
#     if [ -d $config_path ]; then
#         if [ -f $config_path/$config_name ]; then
#             while : ; do
#                 read -rp "File already exists! (O)verwrite, (e)dit, or (c)hange path? " file_exists_choice
#                 case $file_exists_choice in
#                     [oO])
#                         break ;;
#                     [eE])
#                         source $config_path/$config_name
#                         break ;;
#                     [cC])
#                         continue 2 ;;
#                 esac
#                 echo "Invalid entry; try again."
#             done
#         fi
#         break
#     else
#         echo "Invalid path; $config_path is not a directory." >&2
#         echo ""
#     fi
# done

repo=$(_rfind ".git/")

if [ -n "$repo" ]; then
    echo "You are in a Git repository!"
    echo "It is recommended to put this file in a directory not committed to Git,"
    echo "or add it to your .gitignore file."
    read -rp "Type 'y' to add this to your .gitignore, or anything else to abort: " add_gitignore

    if [ "$add_gitignore" = 'y' ] || [ "$add_gitignore" = 'Y' ]; then
        printf "Great! I will add '%s' to %s/.gitignore when we're done. " "$config_name" "$(cd "$(dirname "$repo")"; pwd -P)"
    else
        echo "Aborting. Run this command again from a directory outside of a Git repo." >&2
        exit 1
    fi
fi

read -rp "Enter GitHub username: " ghuser

while : ; do
    read -rsp "Enter GitHub password: " ghpass
    echo ""
    read -rsp "Confirm password: " ghpass2
    echo ""

    if [ "$ghpass" = "$ghpass2" ]; then
        break
    else
        echo "Incorrect entry; try one more time."
        read -rsp "Confirm password: " ghpass2
        echo ""

        if [ "$ghpass" = "$ghpass2" ]; then
            break
        else
            echo -e "Password not confirmed. Resetting password entry.\n"
        fi
    fi
done

read -rp "Enter remote webroot (e.g. public_html): " webroot
read -rp "Enter remote drush command [optional]: " remotedrush
read -rp "Enter remote SSH host: " remotehost
read -rp "Enter GitHub repo (e.g. $ghuser/RepoName): " ghrepo
read -rp "Enter remote SSH user: " sshuser
read -rsp "Enter remote SSH password: " sshpass
echo ""

echo "ghuser=$ghuser" >> $PWD/$config_name
echo "ghpass='$ghpass'" >> $PWD/$config_name
echo "webroot=$webroot" >> $PWD/$config_name
[ -n "$remotedrush" ] && echo "remotedrush='$remotedrush'" >> $PWD/$config_name
echo "remotehost=$remotehost" >> $PWD/$config_name
echo "ghrepo=$ghrepo" >> $PWD/$config_name
echo "sshuser=$sshuser" >> $PWD/$config_name
echo "export SSHPASS='$sshpass'" >> $PWD/$config_name

echo "Configuration file written!"

if [ -n "$add_gitignore" ]; then
    echo -e "\n$config_name" >> $(dirname "$repo")/.gitignore
    printf ".gitignore updated in: %s\n" "$(cd "$(dirname "$repo")"; pwd -P)"
fi
