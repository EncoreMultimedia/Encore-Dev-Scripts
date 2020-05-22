_rfind () {
    needle=$1
    cwd=$PWD
    path=.

    while : ; do
        if [ -e "$cwd/$needle" ]; then
            echo $path/$needle
            return 0
        fi

        path=../$path
        cwd_parent=$(dirname "$cwd")

        # While condition
        [ "$cwd" != "$cwd_parent" ] || break;

        cwd=$cwd_parent
    done

    echo ""
    return 1
}
