#!/data/data/com.termux/files/usr/bin/bash

# Start ssh-agent
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_ed25519

# Run fully automated sync every hour
while true; do
    ~/TCOIN/sync-tcoin-auto-full.sh >> ~/TCOIN/sync.log 2>&1
    sleep 3600
done
