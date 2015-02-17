# rmemptydir - remove empty directories
# Heiner Steven (heiner.steven@odn.de), 2000-07-17
#
# Category: File Utilities

[ $# -lt 1 ] && set -- .

find "$@" -type d -depth -print |
    while read dir
    do
        [ `ls "$dir" | wc -l` -lt 1 ] || continue
        echo >&2 "$0: removing empty directory: $dir"
        rmdir "$dir" || exit $?
    done
exit 0
