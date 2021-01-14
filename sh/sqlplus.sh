#!/bin/bash

############################################
####   CHANGE ME
############################################
# Change these lines to simplify connection!

ORACLE_DEFAULT_USERNAME="luca"
ORACLE_DEFAULT_ENGINE="test"
ORACLE_DEFAULT_PORT=1521
ORACLE_DEFAULT_SERVER="localhost:$ORACLE_DEFAULT_PORT"


###########################################
#######    SCRIPT STARTS HERE
###########################################


# first of all check we can use sqlplus, otherwise
# it does not make sense to ask the user for
# data.
# The `sqlplus` is looked for into the PATH
# or the ORACLE_HOME folder
SQL_PLUS_EXECUTABLE=$(which sqlplus)
SQL_PLUS_EXECUTABLE=${SQL_PLUS_EXECUTABLE:-$ORACLE_HOME/sqlplus}
if [ ! -x "$SQL_PLUS_EXECUTABLE" ]; then
    echo "Cannot find the executable `sqlplus` ..."
    exit 1
fi


# Ask the user if the default connection properties are fine
if [ ! -z "$ORACLE_DEFAULT_USERNAME" -a ! -z "$ORACLE_DEFAULT_SERVER" -a ! -z "$ORACLE_DEFAULT_ENGINE" ]; then
    CONNECTION_STRING="$ORACLE_DEFAULT_USERNAME@$ORACLE_DEFAULT_SERVER/$ORACLE_DEFAULT_ENGINE"
    echo -en "Does this connection sound good?\n\t$CONNECTION_STRING\n\nOK (Y/n)? "
    read -n 1 answer
    case $answer in
        n|N|no|NO|No|nO)
            echo -e "\nPlease specify the following parameters"
            read -p "Username [$ORACLE_DEFAULT_USERNAME] ? " ORACLE_USERNAME
            read -p "Server [$ORACLE_DEFAULT_SERVER] ? "     ORACLE_SERVER
            read -p "Engine [$ORACLE_DEFAULT_ENGINE]? "      ORACLE_ENGINE
            ;;
        *)
            ;;
    esac

    # set arguments to default or what the user has entered
    ORACLE_USERNAME=${ORACLE_USERNAME:-$ORACLE_DEFAULT_USERNAME}
    ORACLE_SERVER=${ORACLE_SERVER:-$ORACLE_DEFAULT_SERVER}
    ORACLE_ENGINE=${ORACLE_ENGINE:-$ORACLE_DEFAULT_ENGINE}
fi

# here ask for the missing arguments like password and schema
read -p "Oracle Schema (proxy) ? " ORACLE_SCHEMA

# make a proxy user by using the syntax
# username[schema]
#
# e.g., luca[mydb]
#
if [ ! -z "$ORACLE_SCHEMA" ]; then
    ORACLE_USERNAME="$ORACLE_USERNAME[$ORACLE_SCHEMA]"
fi

read -p "$ORACLE_USERNAME password (will not echo chars) ? "    -s ORACLE_PASSWORD
echo



# do the connection!
clear
echo "Connecting $ORACLE_USERNAME@$ORACLE_SERVER/$ORACLE_ENGINE ..."
CONNECTION_STRING="$ORACLE_USERNAME"/"$ORACLE_PASSWORD"@"$ORACLE_SERVER"/"$ORACLE_ENGINE"
$SQL_PLUS_EXECUTABLE $CONNECTION_STRING
