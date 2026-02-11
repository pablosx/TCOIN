#!/data/data/com.termux/files/usr/bin/bash

SCRIPT="$HOME/TCOIN/tcoin-autosync-auto.sh"
LOG="$HOME/TCOIN/watchdog.log"

RESTART_COUNT=0
MAX_RESTARTS=5
WINDOW=3600  # 1 hour restart window

echo "TCOIN Watchdog started at $(date)" >> $LOG

while true; do

    if ! pgrep -f "tcoin-autosync-auto.sh" > /dev/null; then

        echo "$(date): Autosync not running. Restarting..." >> $LOG
        
        nohup $SCRIPT >> $HOME/TCOIN/nohup.out 2>&1 &
        ((RESTART_COUNT++))

        termux-notification --title "TCOIN Restarted 🔁" \
        --content "Autosync was restarted by watchdog." \
        --priority high

        if (( RESTART_COUNT >= MAX_RESTARTS )); then
            termux-notification --title "TCOIN ALERT ⚠" \
            --content "Multiple restarts detected in 1 hour." \
            --priority max
        fi
    fi

    sleep 60
done
