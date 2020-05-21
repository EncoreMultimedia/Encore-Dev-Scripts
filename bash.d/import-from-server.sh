#!/usr/bin/env bash
# shellcheck disable=SC2154

# shellcheck disable=SC2034
my_needed_commands="ssh sshpass rsync scp sed git"

source "$(dirname "$0")/_depcheck.inc"
source "$(dirname "$0")/_rfind.inc"

### Let's go

config_name=".enc"
[ -n "$1" ] && config_name+="-$1"
enc_path=$(_rfind "$config_name")
enc_path_parent=$(cd "$(dirname "$enc_path")" || exit; pwd -P)

if [ -n "$1" ]; then
    envname=$1
else
    envname=live
fi

if [ -f "$enc_path" ]; then
    # Found credentials file so let user know and import those vars
    echo "Using configuration found at: $enc_path_parent/$(basename "$enc_path")"
    source "$enc_path"
elif [ -z "$webroot" ]; then
    # Did not find credentials file and the vars aren't set
    echo "import-from-gh: Configuration file '$config_name' not found in any parent directory" >&2
    echo "import-from-gh: Required environment variables not set. Aborting." >&2
    exit 1
fi

sshpass -e rsync -vrltz "$sshuser@$remotehost:$webroot" ./ --exclude=sites/default --exclude=*-old/
[ "$webroot" != "public_html" ] && mv "$webroot" public_html

if [[ $sitetype == drupal* ]]; then
    rm -rf public_html/sites/all/libraries/dompdf/.git
    mkdir public_html/sites/default
    mkdir public_html/sites/default/tmp
    sshpass -e rsync -vrltz "$sshuser@$remotehost:$webroot/sites/default/files" public_html/sites/default --exclude=styles --exclude=css --exclude=js --exclude=php
    sshpass -e rsync -vrltz "$sshuser@$remotehost:$webroot/sites/default/themes" public_html/sites/default
    sshpass -e scp "$sshuser@$remotehost:$webroot/sites/default/settings.php" public_html/sites/default

    sudo sed -i '' -e "s/'\(database\)' => '.*',/'\1' => 'drupal7',/g" public_html/sites/default/settings.php
    sudo sed -i '' -e "s/'\(username\)' => '.*',/'\1' => 'drupal7',/g" public_html/sites/default/settings.php
    sudo sed -i '' -e "s/'\(password\)' => '.*',/'\1' => 'drupal7',/g" public_html/sites/default/settings.php
    sudo sed -i '' -e "s/'host' => '.*',/'host' => 'database',/" public_html/sites/default/settings.php
    sudo sed -i '' -e "s/\$cookie_domain/\/\/ \$cookie_domain/" public_html/sites/default/settings.php && echo "Settings modified."

    enc get-db "$envname"
fi

git init public_html

cat << EOF > public_html/.lando.yml
name: $projectname
recipe: $sitetype
config:
  php: '7.2'
  via: nginx
  webroot: .
  drush: 8.3.2
  xdebug: true

services:
  database:
    type: mariadb
  pma:
    type: phpmyadmin
    hosts:
      - database
EOF

cd public_html || exit
