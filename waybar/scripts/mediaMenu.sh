#!/bin/bash

# Hardcoded absolute path for Wofi image parser tracking
ART_CACHE="/tmp/wofi_media_art.png"
rm -f "$ART_CACHE"

# Get current media info using playerctl
if ! playerctl status >/dev/null 2>&1; then
  wofi -e "No media players running"
  exit 0
fi

STATUS=$(playerctl status)
TITLE=$(playerctl metadata title)
ART_URL=$(playerctl metadata mpris:artUrl)

# Fetch or download the artwork link securely
if [ ! -z "$ART_URL" ]; then
  if [[ "$ART_URL" == file://* ]]; then
    cp "${ART_URL#file://}" "$ART_CACHE"
  else
    curl -s "$ART_URL" -o "$ART_CACHE"
  fi
fi

# Fixed fallback image if none is broadcasted by your player
if [ ! -f "$ART_CACHE" ]; then
  ART_CACHE="/usr/share/icons/hicolor/48x48/apps/multimedia-audio-player.png"
fi

# Clean plain text header
if [ "$STATUS" = "Playing" ]; then
  HEADER="󰐊 Now Playing: $TITLE"
else
  HEADER="󰏤 Paused: $TITLE"
fi

# --- THE STALWART IMG: SYNTAX FOR WOFI ---
# Wofi's explicit dmenu format is: img:/path/to/file.png:text:Your Item Text Label
OPTIONS="img:$ART_CACHE:text:Play / Pause\nNext Track\nPrevious Track"

# --- POSITIONING CHANGES HERE ---
CHOICE=$(
  echo -e "$OPTIONS" | wofi --dmenu \
    --cache-file=/dev/null \
    -p "$HEADER" \
    --width 500 \
    --height 220 \
    --location 2 \
    --yoffset 15
)

# Handle the user's choice cleanly (matching strings directly)
case "$CHOICE" in
*Play*)
  playerctl play-pause
  ;;
*Next*)
  playerctl next
  ;;
*Previous*)
  playerctl previous
  ;;
esac
