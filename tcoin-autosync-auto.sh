#!/data/data/com.termux/files/usr/bin/bash

# -----------------------------
# Fully automated TCOIN sync
# -----------------------------

# Start ssh-agent if not already running
if [ -z "$SSH_AGENT_PID" ]; then
    eval $(ssh-agent -s)
fi

# Add SSH key silently (enter passphrase once)
SSH_KEY="$HOME/.ssh/id_ed25519"
if ! ssh-add -l | grep -q "$(ssh-keygen -lf $SSH_KEY | awk '{print $2}')" ; then
    # Check if ssh-key has passphrase
    ssh-add $SSH_KEY < /dev/null 2>/dev/null
fi

# Infinite loop to sync every hour
while true; do
    echo "=== TCOIN auto-sync check: $(date) ===" >> ~/TCOIN/sync.log

    # Check if GitHub is reachable
    if ping -c 1 github.com &>/dev/null; then
        echo "Network OK, syncing TCOIN..." >> ~/TCOIN/sync.log
        ~/TCOIN/sync-tcoin-auto-full.sh >> ~/TCOIN/sync.log 2>&1
        echo "Sync finished at $(date)" >> ~/TCOIN/sync.log
    else
        echo "Network unreachable, skipping this cycle." >> ~/TCOIN/sync.log
    fi

    # Wait 1 hour before next cycle
    sleep 3600
done
