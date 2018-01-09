#!/usr/bin/zsh


if [ $# -le 1 ]
then
    echo "Specify when and what to archive!"
    echo "$0 directory_backup file1 file2 dir1 dir2 file3 ..."
    exit 3
fi



if [ -z "$1" ]
then
    echo "Where should I place the backups? Specify the directory!"
    exit 1
else
    dirname="$1"
    shift
fi




if [ ! -d "$dirname" -o ! -w "$dirname" ]
then
    echo "ABORT: the destination directory [$dirname] does not exist or is not writable!"
    exit 2
fi



for to_backup in $*
do
    fname=$( basename "$to_backup" )
    fname="${fname}."$( date +'%Y-%m-%dT%H%M%S' )

    if [ -f "$to_backup" -a -r "$to_backup" ]
    then
        echo "Single file backup -> ${fname}"
        cp -v "$to_backup" "$dirname/${fname}" > /dev/null
        sha1_src=$( sha1sum "$to_backup" | awk '{print $1;}' )
        sha1_dst=$( sha1sum "$dirname/${fname}" | awk '{print $1;}' )
        if [ $sha1_src = $sha1_dst ]
        then
            echo "$fg_bold[green]\tSHA1 [$sha1_src] OK"

            # rimuovo eventuali altri file vecchi
            fname=$( basename "$to_backup" )
            days=20
            echo "\tdeleting files [$fname] older than $days days"
            find "$dirname" -type f -name "${fname}*" -mtime +"$days" -exec rm {} \;
        else
            echo "$fg_bold[red]\tSHA1 mismatch!\n\t[$sha1_src] vs [$sha1_dst] "
        fi
    else
        if [ -d "$to_backup" -a -r "$to_backup" -a -x "$to_backup" ]
        then
            fname="_DIRECTORY_.${fname}.tar.bz2"
            echo "Directory backup tar -> ${fname}"
            tar cjvf "$dirname/${fname}" "$to_backup"
        fi
    fi

done
