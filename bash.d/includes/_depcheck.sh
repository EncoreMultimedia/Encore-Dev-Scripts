#!/bin/bash
# The shebang above is only there to enable the right linter.

_depcheck () {
    missing_counter=0
    for needed_command in $1; do
        if ! [ -x "$(command -v "$needed_command")" ]; then
            echo "Dependency '$needed_command' not found." >&2
            ((missing_counter++))
        fi
    done

    if ((missing_counter > 0)); then
        printf "%d required commands are missing. Aborting.\n" "$missing_counter" >&2
        return 1
    fi
}
