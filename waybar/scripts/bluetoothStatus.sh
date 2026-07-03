#!/bin/bash

while true; do
  STATE=$(bluetoothctl show | awk '/Powered:/ {print $2}')

  if [ "$STATE" = "yes" ]; then
    # Get connected MAC addresses
    CONNECTED_MACS=$(bluetoothctl devices Connected | awk '{print $2}')

    if [ -n "$CONNECTED_MACS" ]; then
      # Count how many devices are connected using word count
      COUNT=$(echo "$CONNECTED_MACS" | wc -w)

      FIRST_DEVICE=""
      TOOLTIP=""
      INDEX=0

      for MAC in $CONNECTED_MACS; do
        # Extract name, trim whitespace, and escape double quotes so it doesn't break the JSON
        NAME=$(bluetoothctl info "$MAC" | awk -F': ' '/Name/ {print $2}' | xargs | sed 's/"/\\"/g')
        BATT=$(bluetoothctl info "$MAC" | awk -F '[()]' '/Battery Percentage/ {print $2}')

        # Format this specific device entry
        if [ -n "$BATT" ]; then
          ENTRY="$NAME $BATT%"
        else
          ENTRY="$NAME"
        fi

        # Save the very first device for the main Waybar text
        if [ "$INDEX" -eq 0 ]; then
          FIRST_DEVICE="$ENTRY"
        fi

        # Build the tooltip list (separated by newlines for Waybar)
        if [ -n "$TOOLTIP" ]; then
          TOOLTIP="$TOOLTIP\n$ENTRY"
        else
          TOOLTIP="$ENTRY"
        fi

        ((INDEX++))
      done

      # Modify main text if there are multiple devices
      if [ "$COUNT" -gt 1 ]; then
        EXTRA=$((COUNT - 1))
        TEXT=" $FIRST_DEVICE (+$EXTRA)"
      else
        TEXT=" $FIRST_DEVICE"
      fi

    else
      TEXT=" On"
      TOOLTIP="No devices connected"
    fi
  else
    TEXT=" Off"
    TOOLTIP="Bluetooth is off"
  fi

  # Output the final JSON for Waybar
  echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\"}"

  sleep 5
done
