#!/data/data/com.termux/files/usr/bin/bash

# Start ssh-agent
eval $(ssh-agent -s)

# Add your SSH key (pre-enter passphrase once manually, then it won't prompt)
ssh-add ~/.ssh/id_ed25519

# Infinite loop to sync TCOIN every hour
while true; do
    echo "=== TCOIN sync started at $(date) ===" >> ~/TCOIN/sync.log
    ~/TCOIN/sync-tcoin-auto-full.sh >> ~/TCOIN/sync.log 2>&1
    echo "=== TCOIN sync finished at $(date) ===" >> ~/TCOIN/sync.log
    sleep 3600
done
