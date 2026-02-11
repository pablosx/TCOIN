#!/data/data/com.termux/files/usr/bin/bash

# Watchdog for TCOIN scripts
LOGFILE=~/TCOIN/watchdog.log
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1470988669442850922/kjKcV5aYblGHzHRSfl4_4CTMPvKMigm4P9MKXq9c6aHcnvAx-KFbZcdxuRpDJvz1iSWR"

# Helper to send Discord alerts
discord_alert() {
    local MESSAGE="$1"
    curl -s -H "Content-Type: application/json" \
         -X POST -d "{\"content\":\"$MESSAGE\"}" \
         "$DISCORD_WEBHOOK" > /dev/null 2>&1
}

echo "$(date '+%Y-%m-%d %H:%M:%S') - 🚨 Watchdog started. Monitoring TCOIN scripts..." >> "$LOGFILE"

# Infinite monitoring loop
while true; do
    for SCRIPT in tcoin-autosync-auto.sh tcoin-autosync-network.sh tcoin-integrity-guard.sh; do
        SCRIPT_PATH=~/TCOIN/$SCRIPT

        # Ensure executable
        if [ ! -x "$SCRIPT_PATH" ]; then
            chmod +x "$SCRIPT_PATH"
            echo "$(date '+%Y-%m-%d %H:%M:%S') - 🛠️ Restored execute permission on $SCRIPT" >> "$LOGFILE"
        fi

        # Check if running
        if ! pgrep -f "$SCRIPT_PATH" > /dev/null; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - ⚠️ $SCRIPT not running. Restarting..." >> "$LOGFILE"
            nohup bash "$SCRIPT_PATH" >> ~/TCOIN/${SCRIPT%.sh}.log 2>&1 &
            sleep 3
            if ! pgrep -f "$SCRIPT_PATH" > /dev/null; then
                echo "$(date '+%Y-%m-%d %H:%M:%S') - ❌ Failed to restart $SCRIPT!" >> "$LOGFILE"
                discord_alert "🚨 TCOIN Watchdog: Failed to restart $SCRIPT at $(date '+%Y-%m-%d %H:%M:%S')"
            else
                echo "$(date '+%Y-%m-%d %H:%M:%S') - ✅ $SCRIPT restarted successfully" >> "$LOGFILE"
                discord_alert "✅ TCOIN Watchdog: $SCRIPT restarted successfully at $(date '+%Y-%m-%d %H:%M:%S')"
            fi
        fi
    done

    # Sleep 60 seconds between checks (adjustable)
    sleep 60
done
