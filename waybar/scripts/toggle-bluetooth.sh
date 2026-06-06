#!/bin/bash

CHOICE=$(bluetoothctl devices | awk '{print $2 " " substr($0, index($0,$3))}' | wofi --dmenu -p "Bluetooth")

MAC=$(echo "$CHOICE" | awk '{print $1}')

[ -z "$MAC" ] && exit 0

bluetoothctl connect "$MAC"
