#!/bin/bash

CHOICE=$(echo -e "Power On\nPower Off\nDisconnect\nPaired Devices\nScan & Pair\nRemove Device" | setsid wofi --dmenu --cache-file=/dev/null -p "Bluetooth" --width 300 --height 200)

case "$CHOICE" in

  "Power On")
    bluetoothctl power on
    ;;

  "Power Off")
    bluetoothctl devices Connected | awk '{print $2}' | xargs -r bluetoothctl disconnect
    bluetoothctl power off
    ;;

  "Disconnect")
    bluetoothctl devices Connected | awk '{print $2}' | xargs -r bluetoothctl disconnect
    ;;

  "Paired Devices")

    DEVICES=$(bluetoothctl devices | sed 's/\x1b\[[0-9;]*m//g')

    SELECTED=$(echo "$DEVICES" \
      | awk '{print substr($0, index($0,$3))}' \
      | wofi --dmenu -p "Connect Device")

    MAC=$(echo "$DEVICES" \
      | grep " $SELECTED$" \
      | awk '{print $2}')

    [ -n "$MAC" ] && {
      bluetoothctl devices Connected | awk '{print $2}' | xargs -r bluetoothctl disconnect
          bluetoothctl power on
          bluetoothctl connect "$MAC"
    }
  ;;
"Scan & Pair")
    bluetoothctl power on
    bluetoothctl discoverable on
    bluetoothctl --timeout 10 scan on >/dev/null 2>&1 &

    sleep 10

   DEVICES=$(bluetoothctl devices | sed 's/\x1b\[[0-9;]*m//g')

    DEVICE=$(echo "$DEVICES" \
        | awk '{name=substr($0,index($0,$3)); print name}' \
        | sort -u \
        | wofi --dmenu --matching none --prompt "Pair Device")

    MAC=$(echo "$DEVICES" \
        | awk -v dev="$DEVICE" '
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

    SELECTED=$(echo "$DEVICES" \
      | awk '{print substr($0, index($0,$3))}' \
      | wofi --dmenu -p "Connect Device")

    MAC=$(echo "$DEVICES" \
      | grep " $SELECTED$" \
      | awk '{print $2}')
  [ -n "$MAC" ] && bluetoothctl disconnect "$MAC" && bluetoothctl remove "$MAC"
  ;;
esac
