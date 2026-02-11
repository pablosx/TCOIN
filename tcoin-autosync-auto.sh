#!/data/data/com.termux/files/usr/bin/bash

# Fully automated TCOIN sync with dynamic heartbeat + daily summary

# Start ssh-agent if not running
if [ -z "$SSH_AGENT_PID" ]; then
    eval $(ssh-agent -s)
fi

SSH_KEY="$HOME/.ssh/id_ed25519"
if ! ssh-add -l | grep -q "$(ssh-keygen -lf $SSH_KEY | awk '{print $2}')" ; then
    ssh-add $SSH_KEY < /dev/null 2>/dev/null
fi

# Heartbeat & summary configuration
MIN_HEARTBEAT=$((6*3600))   # 6 hours
MAX_HEARTBEAT=$((12*3600))  # 12 hours
LAST_SUCCESSFUL_SYNC=$(date +%s)
LAST_HEARTBEAT=$(date +%s)
DAILY_SUMMARY_FILE="$HOME/TCOIN/daily_summary.log"
TODAY=$(date +%Y-%m-%d)

# Initialize daily summary file
echo "Daily summary for $TODAY" > "$DAILY_SUMMARY_FILE"

while true; do
    NOW=$(date +%s)
    DATE_STR=$(date)
    SYNC_SUCCESS=false

    # --- Sync cycle ---
    if ping -c 1 github.com &>/dev/null; then
        if ~/TCOIN/sync-tcoin-auto-full.sh >> ~/TCOIN/sync.log 2>&1; then
            SYNC_SUCCESS=true
            LAST_SUCCESSFUL_SYNC=$NOW
            termux-notification --title "TCOIN Sync ✅" --content "Sync completed at $DATE_STR" --priority high
            echo "$DATE_STR: Sync ✅" >> "$DAILY_SUMMARY_FILE"
        else
            termux-notification --title "TCOIN Sync ⚠️" --content "Sync failed at $DATE_STR" --priority high
            echo "$DATE_STR: Sync ⚠️" >> "$DAILY_SUMMARY_FILE"
        fi
    else
        termux-notification --title "TCOIN Sync ⚠️" --content "Network unreachable at $DATE_STR" --priority high
        echo "$DATE_STR: Network unreachable ⚠️" >> "$DAILY_SUMMARY_FILE"
    fi

    # --- Dynamic heartbeat ---
    TIME_SINCE_LAST_SYNC=$(( NOW - LAST_SUCCESSFUL_SYNC ))
    TIME_SINCE_LAST_HEARTBEAT=$(( NOW - LAST_HEARTBEAT ))

    if (( TIME_SINCE_LAST_SYNC >= MIN_HEARTBEAT )) && (( TIME_SINCE_LAST_HEARTBEAT >= MIN_HEARTBEAT )); then
        HEARTBEAT_MSG="TCOIN alive. Last successful sync: $(date -d @$LAST_SUCCESSFUL_SYNC)"
        termux-notification --title "TCOIN Heartbeat 💓" --content "$HEARTBEAT_MSG" --priority low
        echo "$DATE_STR: Heartbeat 💓" >> "$DAILY_SUMMARY_FILE"
        LAST_HEARTBEAT=$NOW
    fi

    if (( TIME_SINCE_LAST_HEARTBEAT >= MAX_HEARTBEAT )); then
        HEARTBEAT_MSG="TCOIN alive. Forced heartbeat. Last sync: $(date -d @$LAST_SUCCESSFUL_SYNC)"
        termux-notification --title "TCOIN Heartbeat 💓" --content "$HEARTBEAT_MSG" --priority low
        echo "$DATE_STR: Forced heartbeat 💓" >> "$DAILY_SUMMARY_FILE"
        LAST_HEARTBEAT=$NOW
    fi

    # --- Daily summary notification at midnight ---
    CURRENT_DATE=$(date +%Y-%m-%d)
    if [[ "$CURRENT_DATE" != "$TODAY" ]]; then
        # Send summary notification
        SUMMARY=$(tail -n 20 "$DAILY_SUMMARY_FILE" | tr '\n' ' ')
        termux-notification --title "TCOIN Daily Summary 📊" --content "$SUMMARY" --priority high
        # Reset for new day
        TODAY="$CURRENT_DATE"
        echo "Daily summary for $TODAY" > "$DAILY_SUMMARY_FILE"
    fi

    # Wait 1 hour before next sync
    sleep 3600
done
