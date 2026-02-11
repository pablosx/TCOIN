#!/data/data/com.termux/files/usr/bin/bash

# Detect current branch
BRANCH=$(git branch --show-current)

if [ -z "$BRANCH" ]; then
    echo "❌ Could not detect current branch. Make sure you are in a Git repo."
    exit 1
fi

echo "➡ Current branch: $BRANCH"

# Pull remote changes with rebase
echo "➡ Pulling latest changes from origin/$BRANCH..."
git pull origin "$BRANCH" --rebase || { echo "❌ Pull failed. Resolve conflicts and try again."; exit 1; }

# Stage all changes
echo "➡ Staging all changes..."
git add . || { echo "❌ Failed to stage files."; exit 1; }

# Prompt for commit message
read -p "Enter commit message (leave empty to skip commit): " COMMIT_MSG

if [ -n "$COMMIT_MSG" ]; then
    echo "➡ Committing changes..."
    git commit -m "$COMMIT_MSG" || { echo "❌ Commit failed."; exit 1; }
else
    echo "➡ No commit message entered. Skipping commit."
fi

# Push changes via SSH
echo "➡ Pushing to origin/$BRANCH..."
git push origin "$BRANCH" || { echo "❌ Push failed."; exit 1; }

echo "✅ Sync complete!"
