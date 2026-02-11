#!/data/data/com.termux/files/usr/bin/bash

# Fully automated TCOIN sync with heartbeat

# Start ssh-agent if not running
if [ -z "$SSH_AGENT_PID" ]; then
    eval $(ssh-agent -s)
fi

SSH_KEY="$HOME/.ssh/id_ed25519"
if ! ssh-add -l | grep -q "$(ssh-keygen -lf $SSH_KEY | awk '{print $2}')" ; then
    ssh-add $SSH_KEY < /dev/null 2>/dev/null
fi

# Heartbeat interval in seconds (e.g., every 6 hours)
HEARTBEAT_INTERVAL=$((6*3600))
LAST_HEARTBEAT=$(date +%s)

while true; do
    NOW=$(date +%s)
    DATE_STR=$(date)

    # Sync cycle
    if ping -c 1 github.com &>/dev/null; then
        echo "Network OK, syncing TCOIN at $DATE_STR" >> ~/TCOIN/sync.log
        if ~/TCOIN/sync-tcoin-auto-full.sh >> ~/TCOIN/sync.log 2>&1; then
            termux-notification --title "TCOIN Sync ✅" --content "Sync completed at $DATE_STR" --priority high
            echo "Sync finished at $DATE_STR" >> ~/TCOIN/sync.log
        else
            termux-notification --title "TCOIN Sync ⚠️" --content "Sync failed at $DATE_STR" --priority high
            echo "Sync failed at $DATE_STR" >> ~/TCOIN/sync.log
        fi
    else
        termux-notification --title "TCOIN Sync ⚠️" --content "Network unreachable at $DATE_STR" --priority high
        echo "Network unreachable, skipping this cycle." >> ~/TCOIN/sync.log
    fi

    # Heartbeat notification
    if (( NOW - LAST_HEARTBEAT >= HEARTBEAT_INTERVAL )); then
        termux-notification --title "TCOIN Heartbeat 💓" --content "TCOIN auto-sync alive at $DATE_STR" --priority low
        echo "Heartbeat sent at $DATE_STR" >> ~/TCOIN/sync.log
        LAST_HEARTBEAT=$NOW
    fi

    # Wait 1 hour before next sync
    sleep 3600
done
