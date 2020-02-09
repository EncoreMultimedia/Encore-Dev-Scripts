#!/usr/bin/env bash

config_name=".enc"
[ -n "$1" ] && config_name+="-$1"

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
if [ -f $PWD/$config_name ]; then
    echo "File '$config_name' will be overwritten in this directory: $PWD"
else
    echo "File '$config_name' will be created in this directory: $PWD"
fi # because macOS bash doesn't support `read -i` which is needed above.

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
read -rp "Enter GitHub repo (e.g. $ghuser/RepoName): " repo
read -rp "Enter remote SSH user: " sshuser
read -rsp "Enter remote SSH password: " sshpass
echo ""

echo "ghuser=$ghuser" >> $PWD/$config_name
echo "ghpass='$ghpass'" >> $PWD/$config_name
echo "webroot=$webroot" >> $PWD/$config_name
[ -n "$remotedrush" ] && echo "remotedrush='$remotedrush'" >> $PWD/$config_name
echo "remotehost=$remotehost" >> $PWD/$config_name
echo "repo=$repo" >> $PWD/$config_name
echo "sshuser=$sshuser" >> $PWD/$config_name
echo "export SSHPASS='$sshpass'" >> $PWD/$config_name

echo "Configuration file written!"
