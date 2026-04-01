# Design — Interest Selector + Share with Friends

## Feature 1: Multi-Interest Selector

### Current State
- InterestSelector: single select (String? selected)
- 5 options: philosophy, stoicism, personal_growth, mindfulness, curiosity
- Saves 1 preference to user_preferences table

### Proposed Change
- InterestSelector: multi-select (Set<String> selected, max 3)
- 7 options: add "creativity" and "humor" to existing 5
- Save all selected to user_preferences with equal weight
- Feed algorithm: distribute weight across selected categories

### New Options
| Value | EN Label | ES Label | Emoji |
|-------|----------|----------|-------|
| creativity | Creativity | Creatividad | 🎨 |
| humor | Humor & Wit | Humor e Ingenio | 😄 |

### UI Change
- Tile shows checkmark when selected (not just border)
- Counter: "2/3 selected" below the list
- Continue button enabled when >= 1 selected

## Feature 2: Share with Friends

### Architecture
```
User A (sender):
  Long-press quote -> "Share with friend" -> Search by username/device_id
  -> POST /api/shares { from_device_id, to_device_id, quote_id }
  -> Insert into shared_quotes table

User B (receiver):
  Opens feed -> Backend injects shared quotes at top
  -> Shows quote with badge "Recommended by [sender_name]"
  -> Can like/save/dismiss
```

### New DB Table: shared_quotes
```sql
CREATE TABLE shared_quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_device_id VARCHAR(100) REFERENCES users(device_id),
  to_device_id VARCHAR(100) REFERENCES users(device_id),
  quote_id UUID REFERENCES quotes(id),
  seen BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### New Backend Endpoints
- POST /api/shares — create a share
- GET /api/shares/pending — get unread shared quotes for current user
- POST /api/shares/:id/seen — mark as seen

### Flutter Changes
- New ShareWithFriendSheet (bottom sheet on long-press)
- FriendSearchWidget (search by display name)
- SharedQuoteBadge widget ("Recommended by [name]")
- Feed injects shared quotes before regular feed

## Tradeoffs
| Decision | Chosen | Rejected | Why |
|----------|--------|----------|-----|
| Friend lookup | By display name | By phone/email | Privacy, simpler |
| Share visibility | Top of feed | Separate tab | More natural discovery |
| Max interests | 3 | Unlimited | Keeps feed algorithm focused |
