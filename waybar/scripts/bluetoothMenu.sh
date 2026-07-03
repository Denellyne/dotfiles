#!/bin/bash

CHOICE=$(echo -e "Power On\nPower Off\nDisconnect\nPaired Devices\nScan and Pair\nRemove Device" | setsid wofi --dmenu --cache-file=/dev/null -p "Bluetooth" --width 300 --height 200 --location 3 --yoffset 15 --xoffset -25)

case "$CHOICE" in

"Power On")
  bluetoothctl power on
  ;;

"Power Off")
  bluetoothctl devices Connected | awk '{print $2}' | xargs -r bluetoothctl disconnect
  bluetoothctl power off
  ;;

"Disconnect")
  # 1. Get ONLY currently connected devices
  CONNECTED=$(bluetoothctl devices Connected | sed 's/\x1b\[[0-9;]*m//g')

  # Exit silently if nothing is connected
  [ -z "$CONNECTED" ] && exit 0

  # 2. Open Wofi to select which specific device to disconnect
  SELECTED=$(echo "$CONNECTED" |
    awk '{print substr($0, index($0,$3))}' |
    wofi --dmenu -p "Disconnect Device")

  MAC=$(echo "$CONNECTED" |
    grep " $SELECTED$" |
    awk '{print $2}')

  # 3. Disconnect only the selected MAC address
  [ -n "$MAC" ] && bluetoothctl disconnect "$MAC"
  ;;

"Paired Devices")
  DEVICES=$(bluetoothctl devices | sed 's/\x1b\[[0-9;]*m//g')

  SELECTED=$(echo "$DEVICES" |
    awk '{print substr($0, index($0,$3))}' |
    wofi --dmenu -p "Connect Device")

  MAC=$(echo "$DEVICES" |
    grep " $SELECTED$" |
    awk '{print $2}')

  [ -n "$MAC" ] && {
    bluetoothctl power on
    bluetoothctl trust "$MAC"
    bluetoothctl connect "$MAC"
  }
  ;;

"Scan and Pair")
  bluetoothctl power on
  bluetoothctl discoverable on
  bluetoothctl --timeout 10 scan on >/dev/null 2>&1 &
  sleep 11

  DEVICES=$(bluetoothctl devices | sed 's/\x1b\[[0-9;]*m//g')

  DEVICE=$(echo "$DEVICES" |
    awk '{name=substr($0,index($0,$3)); print name}' |
    sort -u |
    wofi --dmenu --matching none --prompt "Pair Device")

  MAC=$(echo "$DEVICES" |
    awk -v dev="$DEVICE" '
            {
                name=substr($0,index($0,$3))
                if (name == dev) {
                    print $2
                    exit
                }
            }')

  if [ -n "$MAC" ]; then
    bluetoothctl pair "$MAC"
    bluetoothctl trust "$MAC"
    bluetoothctl connect "$MAC"
  fi

  bluetoothctl discoverable off
  ;;

"Remove Device")
  DEVICES=$(bluetoothctl devices | sed 's/\x1b\[[0-9;]*m//g')

  SELECTED=$(echo "$DEVICES" |
    awk '{print substr($0, index($0,$3))}' |
    wofi --dmenu -p "Remove Device")

  MAC=$(echo "$DEVICES" |
    grep " $SELECTED$" |
    awk '{print $2}')

  [ -n "$MAC" ] && bluetoothctl disconnect "$MAC" && bluetoothctl remove "$MAC"
  ;;
esac
