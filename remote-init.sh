#!/usr/bin/env bash

source "$(dirname $0)/_rfind.inc"

config_name=".enc"
[ -n "$1" ] && config_name+="-$1"

repo=$(_rfind ".git/")

if [ -n "$repo" ]; then
    echo "You are in a Git repository!"
    echo "It is recommended to put this file outside of a Git repository or"
    echo -e "add it to your .gitignore file.\n"

    PS3="Choose an option: "
    options=("Add to .gitignore" "Create in parent directory" "Abort")
    select opt in "${options[@]}"; do
        case $opt in
            "Add to .gitignore")
                printf "Great! I will add '%s' to %s/.gitignore when we're done.\n\n" "$config_name" "$(cd "$(dirname "$repo")"; pwd -P)"
                add_gitignore="yes"
                break ;;
            "Create in parent directory")
                PWD="$(dirname "$(cd "$(dirname "$repo")"; pwd -P)")"
                echo -e "Ok, going up to the parent directory.\n"
                # TODO: check if another parent dir has a .git/
                break ;;
            "Abort")
                echo "Aborting. Run this command again from a directory outside of a Git repo." >&2
                exit 1 ;;
            *) echo "Invalid option" ;;
        esac
    done
fi

# As macOS bash doesn't support `read -i` which is needed below, we do this:
if [ -f $PWD/$config_name ]; then
    echo "File '$config_name' EXISTS and will be overwritten in: $(cd "$PWD"; pwd -P)"
else
    echo "File '$config_name' will be created in: $(cd "$PWD"; pwd -P)"
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

read -rp "Enter project name (for lando; no punctuation): " projectname
read -rp "Enter site type (CMS; e.g. drupal7): " sitetype
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
[[ $sitetype == drupal* ]] && read -rp "Enter remote drush command [optional]: " remotedrush
read -rp "Enter remote SSH host: " remotehost
read -rp "Enter GitHub repo (e.g. $ghuser/RepoName): " ghrepo
read -rp "Enter remote SSH user: " sshuser
read -rsp "Enter remote SSH password: " sshpass
echo ""

echo "projectname=$projectname" >> $PWD/$config_name
echo "sitetype=$sitetype" >> $PWD/$config_name
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
