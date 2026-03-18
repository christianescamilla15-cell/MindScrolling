#!/usr/bin/env bash
# MindScrolling — Branch Protection & Repo Governance Setup
# Run once with a GitHub Personal Access Token (classic, scope: repo)
#
# Usage:
#   export GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
#   bash .github/setup-branch-protection.sh

set -euo pipefail

OWNER="christianescamilla15-cell"
REPO="MindScrolling"
BRANCH="main"
API="https://api.github.com"

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "ERROR: GITHUB_TOKEN is not set."
  echo "Create a classic token at: https://github.com/settings/tokens"
  echo "Required scope: repo (Full control of private repositories)"
  exit 1
fi

echo "Configuring branch protection for ${OWNER}/${REPO}:${BRANCH}..."

curl -s -X PUT \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "${API}/repos/${OWNER}/${REPO}/branches/${BRANCH}/protection" \
  -d '{
    "required_status_checks": {
      "strict": true,
      "contexts": ["security-scan"]
    },
    "enforce_admins": true,
    "required_pull_request_reviews": {
      "dismiss_stale_reviews": true,
      "require_code_owner_reviews": true,
      "required_approving_review_count": 1
    },
    "restrictions": null,
    "allow_force_pushes": false,
    "allow_deletions": false,
    "block_creations": false,
    "required_conversation_resolution": true
  }' | python3 -m json.tool 2>/dev/null || true

echo ""
echo "Done. Verifying..."

RESULT=$(curl -s \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "${API}/repos/${OWNER}/${REPO}/branches/${BRANCH}/protection")

if echo "$RESULT" | grep -q '"url"'; then
  echo "Branch protection configured successfully on '${BRANCH}'."
else
  echo "WARNING: Could not verify. Check GitHub repo settings manually."
  echo "URL: https://github.com/${OWNER}/${REPO}/settings/branches"
fi

echo ""
echo "Manual verification: https://github.com/${OWNER}/${REPO}/settings/branches"
