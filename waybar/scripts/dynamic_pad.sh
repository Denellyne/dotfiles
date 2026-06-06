#!/bin/bash

PIPE="$HOME/.config/waybar/workspaces_pad.fifo"

# 1. Safely create a fresh FIFO pipe
rm -f "$PIPE"
mkfifo "$PIPE"

# 2. Open the pipe on file descriptor 3. 
# This prevents EOF (End of File) so Waybar never disconnects or freezes.
exec 3<> "$PIPE"

# 3. Wrap your exact working logic inside a function
send_padding() {
    COUNT=$(hyprctl workspaces -j | jq '. | length')
    [ -z "$COUNT" ] || [ "$COUNT" -eq 0 ] && COUNT=1

    BASE_SPACES=7
    SUBTRACT=1

    SPACES=$(( BASE_SPACES - (COUNT * SUBTRACT) ))

    if [ "$SPACES" -gt 0 ]; then
        # Capture your exact printf logic and echo it straight into the pipe
        PAD=$(printf ' %.0s' $(seq 1 $SPACES))
        echo "$PAD" >&3
    else
        echo "" >&3
    fi
}

# 4. Prime the bar at startup
send_padding

# 5. The Event Loop: Idles at 0% CPU until you change workspaces
socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    if [[ "$line" =~ (workspace|createworkspace|destroyworkspace)\>\> ]]; then
        # Tiny delay to let Hyprland's internal JSON state update
        sleep 0.08
        send_padding
    fi
done
