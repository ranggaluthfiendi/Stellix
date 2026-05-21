#!/bin/bash
# Volume/Brightness control with Quickshell IPC indicator

TYPE="${1:-volume}"
ACTION="${2:-up}"

show_indicator() {
    local type="$1"
    local value="$2"
    local muted="$3"
    quickshell ipc call -- indicator show "$type" "$value" "$muted"
}

if [ "$TYPE" = "volume" ]; then
    case "$ACTION" in
        up)
            wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
            ;;
        down)
            wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
            ;;
        mute)
            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
            ;;
    esac

    # Get current volume (0.0 to 1.0)
    VOL_RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -oE '[0-9]+\.[0-9]+' | head -1)
    if [ -z "$VOL_RAW" ]; then VOL_RAW="0"; fi
    # If value > 1, it's percentage, convert to decimal
    if (( $(echo "$VOL_RAW > 1" | bc -l 2>/dev/null || echo 0) )); then
        VOL_RAW=$(echo "scale=2; $VOL_RAW / 100" | bc)
    fi

    MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c MUTED)
    show_indicator "volume" "$VOL_RAW" "$([ "$MUTED" -gt 0 ] && echo true || echo false)"

elif [ "$TYPE" = "brightness" ]; then
    case "$ACTION" in
        up)
            brightnessctl set 5%+
            ;;
        down)
            brightnessctl set 5%-
            ;;
    esac

    # Get current brightness (0.0 to 1.0)
    BRIGHT=$(brightnessctl get)
    MAX=$(brightnessctl max)
    BRIGHT_VAL=$(echo "scale=2; $BRIGHT / $MAX" | bc)

    show_indicator "brightness" "$BRIGHT_VAL" "false"
fi
