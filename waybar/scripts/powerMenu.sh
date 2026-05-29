#!/bin/bash

CHOICE=$(echo -e "Shutdown\nReboot\nLogout" | setsid wofi --dmenu --cache-file=/dev/null -p "Power Menu" --width 100 --height 200)

case "$CHOICE" in
  "Shutdown")
    shutdown -h now
    ;;
  "Reboot")
    reboot
    ;;
  "Logout")
    hyprlock
    ;;

  esac

