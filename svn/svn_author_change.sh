#!/bin/sh

# As first step get the local repository path
# and set a pre-revision-property change listener.
REPOSITORY_ROOT=`svn info | grep "Repository Root" | awk '{print $3;}'`
REPOSITORY_PATH=`echo $REPOSITORY_ROOT | sed 's/file:\/\///'`
echo "Working on repository [$REPOSITORY_ROOT] (path = $REPOSITORY_PATH)"


# get the source username and the final username from the command line
# and/or ask the user
FROM_USERNAME=$1
TO_USERNAME=$2

while [ -z "$FROM_USERNAME" ]
do
    echo "Please enter the FROM username (i.e., the username that will be changed"
    echo "in the repository history):"
    read FROM_USERNAME
done


while [ -z "$TO_USERNAME" ]
do
    echo "Please enter the TO username (i.e., the username that will be placed"
    echo "in the repository history):"
    read TO_USERNAME
done

# avoid loops...
if [ "$FROM_USERNAME" = "$TO_USERNAME" ]
then
    echo "Cannot change to the same username!"
    exit
fi


echo "Preparing to substitute $FROM_USERNAME with $TO_USERNAME"


# The repository need to have a pre-property-change hook that
# allows the change of the property, so place a 
# phantom temporary hook to do that.
HOOK_FILE="$REPOSITORY_PATH/hooks/pre-revprop-change"
BACKUP_HOOK_FILE=$HOOK_FILE.backup
if [ -f $HOOK_FILE ]
then
    mv $HOOK_FILE $BACKUP_HOOK_FILE
    chmod 000 $BACKUP_HOOK_FILE
fi

echo "Installing a new temporary pre-revprop-change"
echo "#!/bin/bash" > $HOOK_FILE
echo "exit 0"     >> $HOOK_FILE
chmod 755 $HOOK_FILE


# Now get the list of all the commits that belongs to FROM_USERNAME
COMMITS_DONE=0
REVISIONS_DONE=""
COMMITS_SKIPPED=0
REVISIONS_SKIPPED=""
for commit in `svn log $REPOSITORY_ROOT --quiet | grep "^r" | grep "$FROM_USERNAME" | awk '{print $1;}' | sort`
do
    echo "Commit $commit $FROM_USERNAME -> $TO_USERNAME"
    svn propset --revprop -"$commit" svn:author "$TO_USERNAME" > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
	COMMITS_DONE=`expr $COMMITS_DONE + 1`
	REVISIONS_DONE="$REVISIONS_DONE $commit"
    else
	COMMITS_SKIPPED=`expr $COMMITS_SKIPPED + 1`
	REVISIONS_SKIPPED="$REVISIONS_SKIPPED $commit"
    fi
done



# replace the hook file (if any) with the backup copy
if [ -f $BACKUP_HOOK_FILE ]
then
    echo "Replacing the backup hook file"
    mv $BACKUP_HOOK_FILE $HOOK_FILE
    chmod 755 $HOOK_FILE
fi


# print a summary
echo "-----------------------------------------------"
echo "Changing commits $FROM_USERNAME -> $TO_USERNAME"
echo "Done (with success): $COMMITS_DONE"
echo "Skipped: $COMMITS_SKIPPED"
echo "Changed revision list:"
echo "$REVISIONS_DONE"

if [ $COMMITS_SKIPPED -gt 0 ]
then
    echo "Skipped revisions list:"
    echo "$REVISIONS_SKIPPED"
fi
echo "-----------------------------------------------"