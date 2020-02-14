_rfind () {
    needle=$1
    cwd=$PWD
    path=.

    while [ "$cwd" != "$(dirname "$cwd")" ]; do
        if [ -e "$cwd/$needle" ]; then
            echo $path/$needle
            return 0
        else
            path=../$path
            cwd="$(dirname "$cwd")"
        fi
    done

    echo ""
    return 1
}
