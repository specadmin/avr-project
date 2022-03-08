#!/bin/bash

ADAPTER=usbasp

# Detecting MCU
detected=`avrdude -c $ADAPTER -p m8 -U lfuse:r:/dev/null:h 2> /dev/stdout | grep signature | grep probably | sed 's/\(.*probably \)\(.*\))/\2/'`
echo
echo "Detected AVR MCU: $detected"

# Test detected MCU
set -e
avrdude -c $ADAPTER -p $detected -U lfuse:r:/dev/null:h > /dev/null 2>&1
set +e

tmp="/tmp/fuse-data.dat"

read_fuses()
{
    echo
    echo "Reading fuses values"
    FUSE_LIST="efuse hfuse lfuse"
    for fuse in $FUSE_LIST; do
        fuse_upper=`echo $fuse | tr [:lower:] [:upper:]`
        avrdude -c $ADAPTER -p $detected -U $fuse:r:$tmp:h > /dev/null 2>&1
        value=`cat $tmp | tr [:lower:] [:upper:] | sed -r 's/0X(.*)/\1/'`
        echo "  $fuse_upper: $value"
    done
}

write_fuse()
{
    fuse=$1
    fuse_upper=`echo $fuse | tr [:lower:] [:upper:]`
    echo -n "Enter new value for $fuse_upper: "
    read value
    echo "0x`echo $value | tr [:lower:] [:upper:]`" > $tmp
    avrdude -c $ADAPTER -p $detected -U $fuse:w:`cat $tmp`:m #> /dev/null 2>&1
}


while true; do
    read_fuses
    echo
    echo "1. Change EFUSE"
    echo "2. Change HFUSE"
    echo "3. Change LFUSE"
    echo "4. Exit"
    echo -n "Your choice: "
    read choice

    case $choice in
        1)
            write_fuse efuse
            ;;
        2)
            write_fuse hfuse
            priority=2
            ;;
        3)
            write_fuse lfuse
            priority=3
            ;;
        4)
            break
            ;;
    esac
done

echo
echo "Completed"

