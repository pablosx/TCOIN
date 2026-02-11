#!/data/data/com.termux/files/usr/bin/bash

# Start ssh-agent
eval $(ssh-agent -s)

# Add your SSH key (enter passphrase once)
ssh-add ~/.ssh/id_ed25519

# Infinite loop to sync TCOIN every hour
while true; do
    echo "=== Checking network and GitHub at $(date) ===" >> ~/TCOIN/sync.log

    # Check network connectivity
    if ping -c 1 github.com &>/dev/null; then
        echo "Network OK. Starting TCOIN sync..." >> ~/TCOIN/sync.log
        ~/TCOIN/sync-tcoin-auto-full.sh >> ~/TCOIN/sync.log 2>&1
        echo "TCOIN sync finished at $(date)" >> ~/TCOIN/sync.log
    else
        echo "Network unreachable. Skipping this sync cycle." >> ~/TCOIN/sync.log
    fi

    # Wait 1 hour before next cycle
    sleep 3600
done
