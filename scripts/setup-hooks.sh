#!/bin/sh
# MindScrolling — Git hooks setup script
# Run once after cloning: sh scripts/setup-hooks.sh
#
# Installs three hooks into .git/hooks/:
#   pre-commit       — blocks secrets, .env files, keystores before commit
#   commit-msg       — validates Conventional Commits format
#   prepare-commit-msg — prepopulates commit editor with format reminder

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$REPO_ROOT" ]; then
  echo "ERROR: not inside a git repository"
  exit 1
fi

HOOKS_DIR="$REPO_ROOT/.git/hooks"
SOURCE_DIR="$REPO_ROOT/scripts/hooks"

echo "Installing MindScrolling git hooks..."

for HOOK in pre-commit commit-msg prepare-commit-msg; do
  if [ -f "$SOURCE_DIR/$HOOK" ]; then
    cp "$SOURCE_DIR/$HOOK" "$HOOKS_DIR/$HOOK"
    chmod +x "$HOOKS_DIR/$HOOK"
    echo "  ✓ $HOOK installed"
  else
    echo "  ✗ $HOOK not found in scripts/hooks/ — skipping"
  fi
done

echo ""
echo "Done. Hooks are active for this repository."
echo "To verify: ls -la .git/hooks/ | grep -v sample"
