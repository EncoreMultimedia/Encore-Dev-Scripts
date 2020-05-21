missing_counter=0
for needed_command in $my_needed_commands; do
    if ! [ -x "$(command -v $needed_command)" ]; then
        echo "Dependency '$needed_command' not found." >&2
        ((missing_counter++))
    fi
done

if ((missing_counter > 0)); then
    printf "%d required commands are missing. Aborting.\n" "$missing_counter" >&2
    exit 1
fi
