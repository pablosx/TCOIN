#!/data/data/com.termux/files/usr/bin/bash

# Detect current branch
BRANCH=$(git branch --show-current)

if [ -z "$BRANCH" ]; then
    echo "❌ Could not detect current branch. Make sure you are in a Git repo."
    exit 1
fi

echo "➡ Current branch: $BRANCH"

# Stash uncommitted changes if any
if ! git diff-index --quiet HEAD --; then
    echo "➡ Stashing uncommitted changes..."
    git stash push -u -m "Auto-stash before pull"
    STASHED=true
else
    STASHED=false
fi

# Pull remote changes with rebase
echo "➡ Pulling latest changes from origin/$BRANCH..."
git pull origin "$BRANCH" --rebase || { echo "❌ Pull failed. Resolve conflicts manually."; exit 1; }

# Apply stashed changes if any
if [ "$STASHED" = true ]; then
    echo "➡ Reapplying stashed changes..."
    git stash pop || { echo "❌ Failed to reapply stash. Resolve conflicts manually."; exit 1; }
fi

# Stage all changes
echo "➡ Staging all changes..."
git add . || { echo "❌ Failed to stage files."; exit 1; }

# Auto commit with timestamp if there are changes
if ! git diff-index --quiet HEAD --; then
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    COMMIT_MSG="Auto-sync $TIMESTAMP"
    echo "➡ Committing changes with message: $COMMIT_MSG"
    git commit -m "$COMMIT_MSG" || { echo "❌ Commit failed."; exit 1; }
else
    echo "➡ No changes to commit."
fi

# Push changes via SSH
echo "➡ Pushing to origin/$BRANCH..."
git push origin "$BRANCH" || { echo "❌ Push failed."; exit 1; }

echo "✅ Fully automated sync complete!"
