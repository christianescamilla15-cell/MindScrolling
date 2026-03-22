# Pending Human Tasks — Post Expansion

## Supabase Migrations (Required)

1. **Run Migration 023** — `backend/src/db/migrations/023_content_model_expansion.sql`
   - Adds content_type, sub_category, tags, locked_by, is_hidden_mode columns
   - Creates GIN index on tags for Insight matching
   - Backfills emotional tags for existing quotes

2. **Run Migration 024** — `backend/src/db/migrations/024_seed_new_packs.sql`
   - Drops/recreates pack_purchases CHECK constraint (6 packs)
   - Inserts pack_prices rows for 3 new packs
   - Inserts 500 new premium quotes (250 EN + 250 ES)
   - Marks 15 preview quotes per pack per language
   - Sets released_at for grandfathering

3. **Run embedding script** after Migration 024:
   ```bash
   cd backend && npm run embed-quotes
   ```

## Google Play Console (Required for IAP)

4. **Create 3 new in-app products:**
   - `com.mindscrolling.pack.renaissance_mind` — $2.99
   - `com.mindscrolling.pack.classical_foundations` — $2.99
   - `com.mindscrolling.pack.modern_human_condition` — $2.99

## Backend Deployment

5. **Deploy backend to Render** — push to main triggers auto-deploy
   - New route: POST /insight/match
   - Updated: GET /quotes/feed (excludes hidden_mode content)
   - Updated: GET /packs (6 packs in catalog)
   - Updated: GET /packs/:id/feed (includes content_type, tags)

## Flutter Build

6. **Build and test APK:**
   ```bash
   cd flutter_app
   flutter build apk --release
   ```

## Content (Future — V2)

7. **Science mode content** — Currently uses the philosophical feed as placeholder.
   Need to seed science content (content_type='science', sub_category=branch, is_hidden_mode=true)

8. **Coding mode content** — Same as above with content_type='coding'

9. **RPC updates** — `get_feed_candidates` and `match_quotes` RPCs may need to be updated
   to support `content_type` and `sub_category` query parameters for hidden mode feeds

## Minor Polish (Optional)

10. Update paywall copy from "3 packs" to "6 packs" in Flutter premium screen UI
11. Add hidden mode entry points in bottom navigation or settings for users who already unlocked
12. Insight welcome modal (first time Inside user opens Insight panel)
