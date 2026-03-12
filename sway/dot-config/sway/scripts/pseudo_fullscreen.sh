#!/bin/bash
# ~/.config/sway/scripts/pseudo-fullscreen-advanced.sh

STATE_DIR="$XDG_RUNTIME_DIR/sway-pseudo-fs"
mkdir -p "$STATE_DIR"

# Hole Informationen über das fokussierte Fenster
get_focused_container() {
    swaymsg -t get_tree | jq -r '
        .. | select(.focused? == true) | 
        {
            id: .id,
            floating: (.type == "floating_con"),
            rect: .rect
        }
    '
}

CONTAINER_INFO=$(get_focused_container)
CONTAINER_ID=$(echo "$CONTAINER_INFO" | jq -r '.id')
STATE_FILE="$STATE_DIR/${CONTAINER_ID}.json"

if [ -f "$STATE_FILE" ]; then
    # Restore: Lade gespeicherten Zustand
    SAVED_STATE=$(cat "$STATE_FILE")
    WAS_FLOATING=$(echo "$SAVED_STATE" | jq -r '.was_floating')
    
    if [ "$WAS_FLOATING" = "true" ]; then
        # War ursprünglich floating - stelle Geometrie wieder her
        RECT=$(echo "$SAVED_STATE" | jq -r '.original_rect')
        X=$(echo "$RECT" | jq -r '.x')
        Y=$(echo "$RECT" | jq -r '.y')
        W=$(echo "$RECT" | jq -r '.width')
        H=$(echo "$RECT" | jq -r '.height')
        
        swaymsg "floating enable, resize set ${W}px ${H}px, move position ${X}px ${Y}px"
    else
        # War ursprünglich getiled
        swaymsg "floating disable"
    fi
    
    # Lösche State-Datei
    rm "$STATE_FILE"
else
    # Speichere aktuellen Zustand
    CURRENT_FLOATING=$(echo "$CONTAINER_INFO" | jq -r '.floating')
    CURRENT_RECT=$(echo "$CONTAINER_INFO" | jq -r '.rect')
    
    # Erstelle State-Datei
    cat > "$STATE_FILE" << EOF
{
    "container_id": $CONTAINER_ID,
    "was_floating": $CURRENT_FLOATING,
    "original_rect": $CURRENT_RECT,
    "timestamp": $(date +%s)
}
EOF
    
    # Aktiviere Pseudo-Fullscreen
    swaymsg "floating enable, resize set 100ppt 100ppt, move position 0 0"
fi
