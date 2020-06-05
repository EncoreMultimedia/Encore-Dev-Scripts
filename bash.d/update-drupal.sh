#!/usr/bin/env bash

source "$(dirname "$0")/functions/_depcheck.sh"

! _depcheck "ssh sshpass" && exit 1

while getopts ':m' OPT; do
    case $OPT in
        m )
            mods="YES"
            echo "Will update modules" ;;
        \? )
            echo "update-drupal: Invalid option: -$OPTARG" >&2
            exit 1 ;;
    esac
done
shift $((OPTIND -1))

projectdir=$1

config_name=".enc"
[ -n "$2" ] && config_name+="-$2"
enc_path="$projectdir/$config_name"

if [ -f "$enc_path" ]; then
    # Found credentials file so let user know and import those vars
    echo "Using configuration found at: $enc_path"
    source "$enc_path"
elif [ -z "$webroot" ]; then
    # Did not find credentials file and the vars aren't set
    echo "update-drupal: Configuration file '$enc_path' not found." >&2
    echo "update-drupal: Required environment variables not set. Aborting." >&2
    exit 1
fi

if [[ $sitetype == drupal* ]]; then
    [ -z "$remotedrush" ] && remotedrush=drush
else
    echo "Project is not a Drupal site. Aborting." >&2
    exit 1
fi

projectwebroot=""

if [ "$sitetype" = drupal8 ]; then
    projectwebroot="/web"
fi

localpath="$projectname/public_html$projectwebroot"
remotepath="$webroot$projectwebroot"

echo "Starting to update $projectname on $remotehost ..."

if [ ! -d "$projectname/public_html" ]; then
    mkdir "$projectname"
    git clone "https://github.com/$ghrepo.git" "$projectname/public_html"
else
    cd "$projectname/public_html" && git pull "https://$ghuser:$ghpass@github.com/$ghrepo.git"
fi

if [ ! -d "$localpath/sites/default/tmp" ]; then
    mkdir "$localpath/sites/default/tmp"
fi
sshpass -e rsync -vrltz "$sshuser@$remotehost:$remotepath/sites/default/files" ".$projectwebroot/sites/default"
sshpass -e scp "$sshuser@$remotehost:$remotepath/sites/default/settings.php" ".$projectwebroot/sites/default"

echo "Edit Landofile before launching local environment? (y/N)"
read -r LANDO_EDIT_CHOICE
if [ "$LANDO_EDIT_CHOICE" = 'y' ] || [ "$LANDO_EDIT_CHOICE" = 'Y' ]; then
    code .lando.yml
    read -rp "Press Enter to commit any changes."
    git add .lando.yml && git commit -m "updated lando config"
fi

if [ "$sitetype" = drupal7 ]; then
    sudo -S sed -i '' -e "s/'\(database\)' => '.*',/'\1' => 'drupal7',/g" sites/default/settings.php
    sudo -S sed -i '' -e "s/'\(username\)' => '.*',/'\1' => 'drupal7',/g" sites/default/settings.php
    sudo -S sed -i '' -e "s/'\(password\)' => '.*',/'\1' => 'drupal7',/g" sites/default/settings.php
    sudo -S sed -i '' -e "s/'host' => '.*',/'host' => 'database',/" sites/default/settings.php
    sudo -S sed -i '' -e "s/\$cookie_domain/\/\/ \$cookie_domain/" sites/default/settings.php && echo "Settings modified."
fi

echo "Dumping database..."
sshpass -e ssh "$sshuser@$remotehost" "cd $webroot$projectwebroot;$remotedrush sql-dump > ../db-live.sql"
echo "and downloading..."
sshpass -e scp "$sshuser@$remotehost:db-live.sql" .
sshpass -e ssh "$sshuser@$remotehost" "rm db-live.sql"

echo "done. Starting local environment and importing db..."
cd . && lando start && lando db-import db-live.sql && mv db-live.sql ..

if [ -n "$mods" ]; then
    echo "Checking for module updates..."
    cd . && lando drush rf && lando drush up -n
    read -rp "Please update any modules manually and then press Enter to stage and commit."
    git add . && git commit -m "updated modules"
fi

echo "Updating Drupal core..."
cd . && lando drush up -y drupal && git add . && git reset HEAD .gitignore && git checkout -- .gitignore
code .
read -rp "Please inspect staged changes now. Press Enter to commit, push to GitHub, and pull to remote server."
git commit -m "updated core" && git push

sshpass -e ssh "$sshuser@$remotehost" "cd $webroot;git reset --hard HEAD;git pull 'https://$ghuser:$ghpass@github.com/$ghrepo.git';$remotedrush updb -y"
echo "Done! Stopping local environment..."
cd . && lando stop

echo "Destroy Lando app? (y/N)"
read -r lando_choice
if [ "$lando_choice" = 'y' ] || [ "$lando_choice" = 'Y' ]; then
    lando destroy -y
fi

cd ../..
