#!/data/data/com.termux/files/usr/bin/bash

# Set branch to work on (change if needed)
BRANCH="main"

echo "➡ Switching to branch $BRANCH..."
git checkout $BRANCH || exit 1

echo "➡ Pulling latest changes with rebase..."
git pull origin $BRANCH --rebase || exit 1

echo "➡ Staging all changes..."
git add . || exit 1

# Prompt for commit message
read -p "Enter commit message (leave empty to skip commit): " COMMIT_MSG

if [ -n "$COMMIT_MSG" ]; then
    echo "➡ Committing changes..."
    git commit -m "$COMMIT_MSG" || exit 1
else
    echo "➡ No commit message entered. Skipping commit."
fi

echo "➡ Pushing to GitHub via SSH..."
git push origin $BRANCH || exit 1

echo "✅ Sync complete!"
