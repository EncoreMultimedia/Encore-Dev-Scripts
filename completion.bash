#!/usr/bin/env bash
wordlist="$(cd "$(dirname "${BASH_SOURCE[0]}")/bash.d/" || return; command ls ./*.sh | sed 's|.*/||' | sed 's/\.sh$//')"
complete -W "$wordlist" enc
