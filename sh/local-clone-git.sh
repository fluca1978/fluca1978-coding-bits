#!/bin/sh

SRC_GIT=$1
SRC_NAME=$2
DST_NAME=$3

if [ -z "$SRC_GIT" -o -z "$DST_NAME" -o -z "SRC_NAME" ]; then
    cat <<EOF
Usage: $0 <src-git-folder> <src-name> <dst-name>

Example usage:
       $0 ~/git/foo pc usb
clones the 'foo' repository into the local folder, adding to
it the 'usb' remote and naming the origin remote to 'pc'.
EOF

    exit 1
fi

cat <<EOF
I will clone
  $SRC_GIT
into local folder
  $(pwd)
creating the remote ref
  $SRC_NAME
into it and adding, if needed, the remote ref
  $DST_NAME
into the remote source repository.
Ok to proceed? (y/n)

EOF

read ANSWER
case "$ANSWER" in
    y|Y) clear ;;
    *) exit 2 ;;
esac


DST_GIT=$( pwd )/$( basename "$SRC_GIT" )

echo "Step 1: clone remote [$SRC_GIT] into $(pwd) ... "
git clone "$SRC_GIT"
if [ $? -ne 0 ]; then
    echo "Clone failed, aborting!"
    exit 3
else
    echo "cloned into $DST_GIT"
fi

cd "$DST_GIT"

echo "Step 2: renaming the default origin remote for the new repository ... "
echo "origin -> $SRC_NAME"
git remote rename origin "$SRC_NAME"

echo "Step 3: cloning all the remotes from the original repository ..."
cd "$SRC_GIT"
src_need_remote=1
for remote_name in $( git remote )
do
    if [ "$remote_name" != "$DST_NAME" ]; then
        remote_url=$( git remote get-url $remote_name )
        echo "Adding [$remote_name] -> [$remote_url]"
        cd "$DST_GIT" && git remote add "$remote_name" "$remote_url"
        cd "$SRC_GIT"
    else
        src_need_remote=0
    fi
done

echo "Step 4: adding $DST_NAME as remote to $SRC_GIT ..."
if [ $src_need_remote -eq 0 ]; then
    echo "source repository $SRC_GIT already has a remote named [$DST_NAME] !"
else
    cd "$SRC_GIT" && git remote add "$DST_NAME" "$DST_GIT"
fi

echo "Step 5: fetching all ..."
cd "$DST_GIT" && git fetch --all

echo
echo "All done! Enjoy the clone repository $DST_GIT !"
echo
