#!/data/data/com.termux/files/usr/bin/bash
# ================================
# TCOIN Git Integrity Guard v2
# ================================

REPO="$HOME/TCOIN"
SAFE_BRANCH="main"

cd "$REPO" || exit 1

# 1️⃣ Check branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" != "$SAFE_BRANCH" ]; then
    echo "Integrity Guard: Wrong branch ($BRANCH). Aborting push."
    exit 1
fi

# 2️⃣ Check remote
REMOTE=$(git remote get-url origin)
if [[ "$REMOTE" != *"github.com:pablosx/TCOIN.git"* ]]; then
    echo "Integrity Guard: Unexpected remote ($REMOTE). Aborting push."
    exit 1
fi

# 3️⃣ Get staged files
STAGED=$(git diff --cached --name-only)

# 4️⃣ Load ignored files from .gitignore
IGNORED=$(git check-ignore *)

# 5️⃣ Loop through staged files
for f in $STAGED; do
    # Skip files in .gitignore
    if echo "$IGNORED" | grep -qxF "$f"; then
        continue
    fi

    # Only allow files in the safe list
    ALLOWED=false
    SAFE_FILES=("node.py" "wallet.py" "tcoin-autosync-auto.sh" "tcoin-watchdog.sh" \
                ".gitignore" "LICENSE.md" "README.md" "SECURITY.md" "CONTRIBUTING.md")
    for safe in "${SAFE_FILES[@]}"; do
        if [ "$f" == "$safe" ]; then
            ALLOWED=true
            break
        fi
    done

    if [ "$ALLOWED" = false ]; then
        echo "Integrity Guard: Unapproved file staged: $f. Aborting push."
        exit 1
    fi
done

# 6️⃣ Optional: Check remote connectivity
git remote show origin > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Integrity Guard: Cannot reach remote. Aborting push."
    exit 1
fi

# 7️⃣ Log commit hash
HASH=$(git rev-parse HEAD)
echo "$(date): Integrity check passed. Commit hash: $HASH" >> "$REPO/integrity.log"

exit 0
