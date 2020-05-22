#!/usr/bin/env bash
self_dir=$(cd "$(dirname "$(stat -f %Y "$0")")" || exit; pwd -P)
script_dir="$self_dir/bash.d"

#_enc_completions() {
#    if [ ${#COMP_WORDS[@]} -gt 2 ]; then
#        return
#    fi
#}
#This will be done later

if [ "$1" = "install" ]; then
    if [ -L /usr/local/bin/enc ]; then
        echo "This script is already installed. Aborting." >&2
        exit 1
    fi

    echo "sudo may ask for the password for your local user account below."
    sudo ln -s "$self_dir/enc.bash" /usr/local/bin/enc

    echo -e "\n# Added by Encore-Dev-Scripts\n[ -f $self_dir/completion.bash ] && source $self_dir/completion.bash\n" >> ~/.bashrc
    source "$self_dir/completion.bash" && echo "Bash command completion installed and activated."
    exit 0
fi

if [ -f "$script_dir/$1.sh" ]; then
    "$script_dir/$1.sh" "${@:2}"
    exit $?
else
    echo "Script not found: $1" >&2
    exit 1
fi
