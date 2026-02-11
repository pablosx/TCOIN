#!/data/data/com.termux/files/usr/bin/bash

SCRIPT="$HOME/TCOIN/tcoin-autosync-auto.sh"
LOG="$HOME/TCOIN/watchdog.log"
NOHUP_LOG="$HOME/TCOIN/nohup.out"

MAX_RESTARTS=5
WINDOW=3600          # 1 hour window
CHECK_INTERVAL=60
CPU_LIMIT=80         # percent
MEM_LIMIT=150000     # KB (~150MB)

RESTART_COUNT=0
WINDOW_START=$(date +%s)

echo "=== TCOIN Watchdog started at $(date) ===" >> $LOG

while true; do

    NOW=$(date +%s)

    # Reset restart window if expired
    if (( NOW - WINDOW_START > WINDOW )); then
        RESTART_COUNT=0
        WINDOW_START=$NOW
        echo "$(date): Restart window reset." >> $LOG
    fi

    PID=$(pgrep -f tcoin-autosync-auto.sh)

    if [ -z "$PID" ]; then
        echo "$(date): Autosync not running. Restarting..." >> $LOG
        
        nohup $SCRIPT >> $NOHUP_LOG 2>&1 &
        ((RESTART_COUNT++))

        termux-notification --title "TCOIN Restarted 🔁" \
        --content "Autosync restarted by watchdog." \
        --priority high

        if (( RESTART_COUNT >= MAX_RESTARTS )); then
            echo "$(date): Too many restarts. Entering SAFE MODE." >> $LOG

            termux-notification --title "TCOIN SAFE MODE ⚠" \
            --content "Excessive crashes detected. Supervisor paused." \
            --priority max

            sleep 600
        fi
    else
        # Resource monitoring
        CPU=$(ps -p $PID -o %cpu= | awk '{print int($1)}')
        MEM=$(ps -p $PID -o rss=)

        if (( CPU > CPU_LIMIT )); then
            echo "$(date): High CPU detected ($CPU%). Restarting..." >> $LOG
            kill $PID
        fi

        if (( MEM > MEM_LIMIT )); then
            echo "$(date): High memory usage (${MEM}KB). Restarting..." >> $LOG
            kill $PID
        fi
    fi

    sleep $CHECK_INTERVAL
done
