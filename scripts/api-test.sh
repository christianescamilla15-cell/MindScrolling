#!/bin/bash
# MindScrolling API Integration Test Suite
# Run: bash scripts/api-test.sh [base_url]
# Default: https://mindscrolling.onrender.com

BASE="${1:-https://mindscrolling.onrender.com}"
DID="00000000-0000-0000-0000-000000000001"
PASS=0; FAIL=0
# Handle 429 rate limiting with retry
MAX_RETRIES=2
TMPBODY=$(mktemp)
trap "rm -f $TMPBODY" EXIT

t() {
  local m="$1" u="$2" e="$3" d="$4" b="$5"
  local ca=(-s -w "\n%{http_code}" -H "x-device-id: $DID" -H "Content-Type: application/json" --max-time 15)
  if [ "$m" = "POST" ]; then
    if [ -n "$b" ]; then printf '%s' "$b" > "$TMPBODY"
    else printf '%s' '{}' > "$TMPBODY"; fi
    ca+=(-X POST --data-binary "@$TMPBODY")
  fi
  [ "$m" = "DELETE" ] && ca+=(-X DELETE)
  local r s retry=0
  while true; do
    r=$(curl "${ca[@]}" "$BASE$u" 2>/dev/null)
    s=$(printf '%s' "$r" | tail -1)
    if [ "$s" = "429" ] && [ $retry -lt $MAX_RETRIES ]; then
      ((retry++))
      sleep 10
      continue
    fi
    break
  done
  if [ "$s" = "$e" ]; then echo "  PASS [$s] $m $u"; ((PASS++))
  else echo "  FAIL [$s!=$e] $m $u — $d"; printf '    %.120s\n' "$(printf '%s' "$r" | head -n -1)"; ((FAIL++)); fi
}

tn() {
  local r s retry=0
  while true; do
    r=$(curl -s -w "\n%{http_code}" --max-time 10 "$BASE$1" 2>/dev/null)
    s=$(printf '%s' "$r" | tail -1)
    if [ "$s" = "429" ] && [ $retry -lt $MAX_RETRIES ]; then
      ((retry++)); sleep 10; continue
    fi
    break
  done
  if [ "$s" = "$2" ]; then echo "  PASS [$s] NO-HDR $1"; ((PASS++))
  else echo "  FAIL [$s!=$2] NO-HDR $1"; ((FAIL++)); fi
}

echo ""
echo "  MindScrolling API Tests — $BASE"
echo "  $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "  ────────────────────────────────────────"

echo ""; echo "── Core ──"
t GET "/health" 200 "Health"
t GET "/quotes/feed?lang=en" 200 "Feed EN"
t GET "/quotes/feed?lang=es" 200 "Feed ES"
t GET "/quotes/feed" 200 "Feed default"
t GET "/quotes/feed?lang=xx" 200 "Feed invalid lang"

echo ""; echo "── Authors ──"
t GET "/authors" 200 "List"
t GET "/authors/marcus_aurelius" 200 "Valid slug"
t GET "/authors/nonexistent" 404 "Not found"

echo ""; echo "── Challenges ──"
t GET "/challenges/today" 200 "Today"
t GET "/challenges/today?lang=en" 200 "EN"
t GET "/challenges/today?lang=es" 200 "ES"

echo ""; echo "── Stats ──"
t GET "/stats" 200 "Stats"

echo ""; echo "── Profile ──"
t GET "/profile" 200 "Get"
t POST "/profile" 200 "Update" '{"preferred_categories":["stoicism"]}'

echo ""; echo "── Vault ──"
t GET "/vault" 200 "List"
t GET "/vault?lang=en" 200 "EN"

echo ""; echo "── Swipes ──"
t POST "/swipes" 400 "Empty body" '{}'
t POST "/swipes" 400 "Invalid UUID" '{"quote_id":"xxx","direction":"right","category":"stoicism"}'

echo ""; echo "── Likes ──"
t POST "/quotes/test/like" 400 "Invalid ID" '{"action":"like"}'

echo ""; echo "── Packs ──"
t GET "/packs" 200 "List"
t GET "/packs?lang=en" 200 "EN"

echo ""; echo "── Premium ──"
t GET "/premium/status" 200 "Status"
t POST "/premium/start-trial" 200 "Start trial"
t POST "/premium/restore" 400 "Empty restore" '{}'

echo ""; echo "── Map ──"
t GET "/map" 200 "Map"

echo ""; echo "── Mind Profile ──"
t GET "/mind-profile/daily" 200 "Daily"

echo ""; echo "── Insights ──"
t GET "/insights/weekly" 200 "Weekly"

echo ""; echo "── Analytics ──"
t POST "/analytics/event" 202 "Event" '{"event_type":"test","properties":{}}'

echo ""; echo "── Admin (403) ──"
t GET "/admin/codes/list" 403 "No secret"
t GET "/admin/audit" 403 "No secret"

echo ""; echo "── Webhooks (401) ──"
t POST "/webhooks/revenuecat" 401 "No auth" '{"event":{}}'

echo ""; echo "── Missing Header (401) ──"
tn "/quotes/feed" 401
tn "/stats" 401
tn "/vault" 401
tn "/packs" 401
tn "/premium/status" 401

echo ""
echo "  ────────────────────────────────────────"
echo "  TOTAL: $PASS passed, $FAIL failed"
exit $FAIL
