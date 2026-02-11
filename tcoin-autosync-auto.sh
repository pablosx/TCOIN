#!/data/data/com.termux/files/usr/bin/bash

# Fully automated TCOIN sync with dynamic heartbeat

# Start ssh-agent if not running
if [ -z "$SSH_AGENT_PID" ]; then
    eval $(ssh-agent -s)
fi

SSH_KEY="$HOME/.ssh/id_ed25519"
if ! ssh-add -l | grep -q "$(ssh-keygen -lf $SSH_KEY | awk '{print $2}')" ; then
    ssh-add $SSH_KEY < /dev/null 2>/dev/null
fi

# Dynamic heartbeat: minimum interval (seconds) and max interval (seconds)
MIN_HEARTBEAT=$((6*3600))   # 6 hours
MAX_HEARTBEAT=$((12*3600))  # 12 hours
LAST_SUCCESSFUL_SYNC=$(date +%s)
LAST_HEARTBEAT=$(date +%s)

while true; do
    NOW=$(date +%s)
    DATE_STR=$(date)

    SYNC_SUCCESS=false

    # --- Sync cycle ---
    if ping -c 1 github.com &>/dev/null; then
        echo "Network OK, syncing TCOIN at $DATE_STR" >> ~/TCOIN/sync.log
        if ~/TCOIN/sync-tcoin-auto-full.sh >> ~/TCOIN/sync.log 2>&1; then
            termux-notification --title "TCOIN Sync ✅" --content "Sync completed at $DATE_STR" --priority high
            echo "Sync finished at $DATE_STR" >> ~/TCOIN/sync.log
            SYNC_SUCCESS=true
            LAST_SUCCESSFUL_SYNC=$NOW
        else
            termux-notification --title "TCOIN Sync ⚠️" --content "Sync failed at $DATE_STR" --priority high
            echo "Sync failed at $DATE_STR" >> ~/TCOIN/sync.log
        fi
    else
        termux-notification --title "TCOIN Sync ⚠️" --content "Network unreachable at $DATE_STR" --priority high
        echo "Network unreachable, skipping this cycle." >> ~/TCOIN/sync.log
    fi

    # --- Dynamic heartbeat ---
    TIME_SINCE_LAST_SYNC=$(( NOW - LAST_SUCCESSFUL_SYNC ))
    TIME_SINCE_LAST_HEARTBEAT=$(( NOW - LAST_HEARTBEAT ))

    # Send heartbeat only if no successful sync for at least MIN_HEARTBEAT
    if (( TIME_SINCE_LAST_SYNC >= MIN_HEARTBEAT )) && (( TIME_SINCE_LAST_HEARTBEAT >= MIN_HEARTBEAT )); then
        HEARTBEAT_MSG="TCOIN alive. Last successful sync: $(date -d @$LAST_SUCCESSFUL_SYNC)"
        termux-notification --title "TCOIN Heartbeat 💓" --content "$HEARTBEAT_MSG" --priority low
        echo "Heartbeat sent at $DATE_STR" >> ~/TCOIN/sync.log
        LAST_HEARTBEAT=$NOW
    fi

    # Ensure heartbeat never exceeds MAX_HEARTBEAT
    if (( TIME_SINCE_LAST_HEARTBEAT >= MAX_HEARTBEAT )); then
        HEARTBEAT_MSG="TCOIN alive. Force heartbeat (last sync $(date -d @$LAST_SUCCESSFUL_SYNC))"
        termux-notification --title "TCOIN Heartbeat 💓" --content "$HEARTBEAT_MSG" --priority low
        echo "Forced heartbeat sent at $DATE_STR" >> ~/TCOIN/sync.log
        LAST_HEARTBEAT=$NOW
    fi

    sleep 3600
done
