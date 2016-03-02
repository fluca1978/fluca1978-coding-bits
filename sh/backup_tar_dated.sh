#/bin/sh

# A simple TAR wrapper that does backup of a single file or directory
# into a bz2 archive named after the current date. A log file will be generated
# to provide the tar information.


BACKUP_FROM=$1
BACKUP_TO=$2
FILENAME=$3
EXTENSION=$4
TAR_CMD=`which tar`


if [ $# -lt 2 ]
then
    echo "Usage:"
    echo "$0 BACKUP_FROM BACKUP_TO_DIR [BACKUP_FILENAME] [ONLY_EXTENSIONS]"
    echo "Examples:"
    echo "$0 ~/tmp /backup/ # backup ~/tmp in /backup"
    echo "$0 ~/development /backup DEVELOPMENT_BACKUP # backup ~/development into /backup/DEVELOPMENT.tar.bz2"
    echo "$0 ~/development /backup DEVELOPMENT_BACKUP java # backup only java files"
fi


# check if the dest directory exists
if [ ! -d "$BACKUP_TO" ]
then
    mkdir -p "$BACKUP_TO" > /dev/null 2>&1
    if [ $? -ne 0 ]
    then
	echo "Cannot create directory $BACKUP_TO"
	exit
    fi
fi

# check the write permission against the dest directory
if [ ! -w "$BACKUP_TO" ]
then
    echo "Cannot write to the $BACKUP_TO directory!"
    exit
fi


# check to have a filename or set it as default
if [ -z "$FILENAME" ]
then
    FILENAME="NO_NAME"
fi


# if an extension has been specified, backup all files with such extension
if [ ! -z "$EXTENSION"  -a ! -f "$BACKUP_FROM" ]
then
    BACKUP_FROM="${BACKUP_FROM}/*.${EXTENSION}"
    echo "Only files with the pattern $BACKUP_FROM will be backed-up!"
fi

DATE=$(/bin/date +%d_%m_%y)
LOG_FILE=${BACKUP_TO}/${FILENAME}.log
BACKUP_TAR_FILE=${BACKUP_TO}/${FILENAME}_${DATE}.tar.bz2
echo "Staring backup to $BACKUP_TAR_FILE"
${TAR_CMD} cjvf $BACKUP_TAR_FILE  ${BACKUP_FROM} > ${LOG_FILE} 2>&1
echo "Backup done!"
echo "A log has been generated: $LOG_FILE"
