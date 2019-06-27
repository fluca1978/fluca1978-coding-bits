#!/bin/sh

# A simple script to wrap Virtual Box commands in a more consistent way.

VBOX_MANAGER_CMD=$(which VBoxManage)
COLUMN_CMD=$(which column)

# check that the command if found
if [ -z "$VBOX_MANAGER_CMD" ]; then
    echo "Cannot find the command VBoxManage"
    exit 1
fi

ACTION=$1
VM=$2

if [ -z "$ACTION" ]; then
    echo "Specify at least an action!"
    exit 2
fi

# echo "${ACTION}-ing $VM ..."


case $ACTION in
    list)
        echo "Available Virtual Machines:"
        $VBOX_MANAGER_CMD $ACTION vms | $COLUMN_CMD -s \" -t
          ;;
    start|stop)
        if [ -z "$VM" ]; then
            echo "Which machine?"
            exit 2
        fi

        # check the machine exists
        VM_UUID=$($VBOX_MANAGER_CMD list vms | grep "$VM" | awk '{print $2;}' | sed s/\{// | sed s/\}// )
        if [ -z "$VM_UUID" ]; then
            echo "The machine [$VM] does not appear to exist!"
            # invoke myself to list the machines
            $0 list
            exit 2
        fi

        echo "${ACTION}ing $VM ($VM_UUID) ..."
        case $ACTION in
            start) ACTION="startvm"
                   OPTIONS="--type headless"
                   ;;
            stop) ACTION="controlvm"
                  OPTIONS="poweroff"
                  ;;
        esac


        $VBOX_MANAGER_CMD ${ACTION} $VM $OPTIONS
        ;;
esac
