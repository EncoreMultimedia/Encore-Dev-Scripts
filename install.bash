#!/usr/bin/env bash

#_enc_completions() {
#    if [ ${#COMP_WORDS[@]} -gt 2 ]; then
#        return
#    fi
#}
#This will be done later

self_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd -P)

if [ -L /usr/local/bin/enc ]; then
    echo "This script is already installed. Aborting." >&2
    exit 1
else
    echo "sudo may ask for the password for your local user account below."
    sudo ln -s "$self_dir/enc" /usr/local/bin/enc
fi

echo -e "\n# Added by Encore-Dev-Scripts\n[ -f $self_dir/bash_completion ] && source $self_dir/bash_completion\n" >> ~/.bashrc
source "$self_dir/bash_completion" && echo "Bash command completion installed and activated."
