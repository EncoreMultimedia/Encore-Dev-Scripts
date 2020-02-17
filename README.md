# Encore-Dev-Scripts
Scripts for devs to use on their local machines.

## Installation
- Clone this repo to your local machine, anywhere.
- Oh, almost forgot. You will need SSHPass installed or else some of these
  will complain at you and act a fool.
  - Can't figure this one out on your own? Fine. This is the only hint you get.\
    `brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb`
- **SOURCE** (not run) the `install.bash` script, entering your password for
  `sudo` if needed.\
  (That just means type `source install.bash` from within the directory of this repo.)
- **SOURCE** (not run) the `update.bash` script after pulling new changes from
  this repo in order to inform the autocompletion in your current shell about
  what changed.

## Usage
This package creates a global command, `enc`, that can run the rest of the scripts
in the package from anywhere. Bash autocompletion is also enabled for these
script names. (to be improved)

### `[env]`
This is an optional environment signifier. Can be anything.\
Using this option, you can have multiple configuration files corresponding to,
for example, a live server, dev server, staging server, or whatever you want.

### Scripts
- `enc get-db [env]`\
    Downloads remote database to your machine as a .sql.gz file in the same
    directory as the config file (so as to be outside of git).\
    *Requires a `.enc` config file to exist. See the `[env]` note above.*
- `enc import-from-gh [env]`\
    Creates all the files needed to run the site on your local machine
    by cloning the configured GitHub repo.\
    Run this inside a fresh project directory of your making.\
    *Requires a `.enc` config file to exist. See the `[env]` note above.*
- `enc import-from-server [env]`\
    Creates all the files needed to run the site on your local machine
    by copying them all from a remote server.\
    Run this inside a fresh project directory of your making.\
    *Requires a `.enc` config file to exist. See the `[env]` note above.*
- `enc remote-init [env]`\
    Creates a `.enc` (or `.enc-$env`) configuration file in the directory
    where you run the script.\
    *See the `[env]` note above.*
- `enc remote-pull [options] [env]`\
    Logs into a configured remote server for the project whose path you're in,
    and runs a `git pull` as well as other optional commands.\
    *Requires a `.enc` config file to exist. See the `[env]` note above.*
  * Options
    * -c    (Drupal 7) Clears cache with 'drush cc all' after pull
    * -r    (Drupal 8) Clears cache with 'drush cr' after pull
    * -u    Runs 'drush updb -y' after pull
    * -h    this usage information
- `enc ssh [env]`\
    Starts an ssh session using the preconfigured credentials.\
    *Requires a `.enc` config file to exist. See the `[env]` note above.*
