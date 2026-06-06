#!/bin/bash

# Get connected device MAC
MAC=$(bluetoothctl devices Connected | awk '{print $2}')

if [ -z "$MAC" ]; then
    echo " Off"
    exit 0
fi

# Get device name
NAME=$(bluetoothctl info "$MAC" | awk -F': ' '/Name/ {print $2}')

if [ -z "$NAME" ]; then
    NAME="Unknown"
fi

echo " $NAME"
