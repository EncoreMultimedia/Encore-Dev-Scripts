_rfind () {
    needle=$1
    cwd=$PWD
    cwd_parent=$(dirname "$cwd")
    path=.

    while [ "$cwd" != "$cwd_parent" ]; do
        if [ -e "$cwd/$needle" ]; then
            echo $path/$needle
            return 0
        else
            path=../$path
            cwd=$cwd_parent
        fi
    done

    echo ""
    return 1
}
