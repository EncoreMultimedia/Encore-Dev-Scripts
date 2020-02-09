#!/usr/bin/env bash

### Check dependencies

my_needed_commands="mysql mysqldump"

missing_counter=0
for needed_command in $my_needed_commands; do
  if ! hash "$needed_command" >/dev/null 2>&1; then
    printf "Command not found in PATH: %s\n" "$needed_command" >&2
    ((missing_counter++))
  fi
done

if ((missing_counter > 0)); then
  printf "%d required commands are missing in PATH, aborting\n" "$missing_counter" >&2
  exit 1
fi

### Parse args

while getopts ':u:p:h' OPT; do
    case $OPT in
        u )
            user=$OPTARG ;;
        p )
            pass=$OPTARG ;;
        h )
            echo "Usage:"
            echo "    mysql_clone [options] src_table dest_table"
            echo ""
            echo "Options:"
            echo "    -u username"
            echo "    -p password"
            echo "    -h            this usage information"
            echo ""
            exit 0 ;;
        \? )
            echo "$0: Invalid option: -$OPTARG" 1>&2
            exit 1 ;;
        : )
            echo "$0: Invalid Option: -$OPTARG requires an argument" 1>&2
            exit 1 ;;
    esac
done
shift $((OPTIND -1))

if [ -z "$user" ]; then
    read -rp "Enter a MySQL user: " user
fi

if [ -z "$pass" ]; then
    read -rp "Enter $user's password: " pass
fi

if [ -z "$1" ]; then
    read -rp "Enter name of source database: " src_db
else
    src_db=$1
fi

if [ -z "$2" ]; then
    read -rp "Enter name of new database: " tgt_db
else
    tgt_db=$2
fi

mysqldump -u $user -p$pass -B $src_db | mysql -u $user -p$pass
