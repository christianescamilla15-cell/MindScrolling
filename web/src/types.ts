// ─── Shared domain types — single source of truth for the webapp ──────────
// These mirror the Fastify backend's quote schema and the legacy Vite app's
// runtime shapes. Anything tying api/, components/, and utils/ together
// flows through here so we get one definition per concept.

export type Lang = "en" | "es";

export type CategoryKey = "philosophy" | "stoicism" | "discipline" | "reflection";

export type Direction = "up" | "down" | "left" | "right";

export interface CategoryMeta {
  label: string;
  color: string;
  bg: string;
  dir: string;
}

export interface Quote {
  id: string;
  text: string;
  author: string;
  category: CategoryKey;
  /** Swipe direction this category maps to. Backfilled by api/quotes.fetchQuotes. */
  dir?: Direction;
  /** Origin language. Optional because some legacy fixtures don't tag it. */
  lang?: Lang;
}

export interface Profile {
  age_range: string;
  interest: string;
  goal: string;
  preferred_language: Lang;
}

/** 4-category swipe counts. Mirrors CategoryKey one-to-one. */
export type SwipeCounts = Record<CategoryKey, number>;

export const EMPTY_SWIPE_COUNTS: SwipeCounts = {
  philosophy: 0,
  stoicism: 0,
  discipline: 0,
  reflection: 0,
};

export interface PersistedState {
  liked: string[];
  vault: Quote[];
  streak: number;
  reflections: number;
  /** Optional for back-compat: legacy state from before 1d-ii lacked this. */
  swipeCounts?: SwipeCounts;
}

export interface ChallengeData {
  id: string;
  code: string;
  title: string;
  description: string;
  target?: number;
}

export interface ChallengeProgress {
  progress: number;
  completed: boolean;
}

/** PhilosophyMap / EvolutionCard use a different key set than CategoryKey
 *  (wisdom replaces stoicism by intent — see CATEGORY_LABELS in those
 *  components). Keeping a parallel type rather than aliasing avoids a
 *  silent rename if the backend ever returns the wrong keys. */
export type MapCategoryKey = "wisdom" | "discipline" | "reflection" | "philosophy";

export type CategoryScores = Record<MapCategoryKey, number>;

export interface MapData {
  current: CategoryScores | null;
  snapshot: CategoryScores | null;
  snapshot_date: string | null;
}

/** Toast colour is used as both text colour and (with a 40-suffix alpha)
 *  border colour. Typed as string so callers can pass any hex without
 *  enumerating every possibility. */
export interface Toast {
  msg: string;
  color: string;
}

/** Shape of /quotes/feed responses from the Fastify backend. */
export interface FeedResponse {
  data: Quote[];
  next_cursor: string | null;
  has_more: boolean;
}

/** Shape of /premium/status. */
export interface PremiumStatus {
  is_premium: boolean;
}

/** Catalog of Stripe products the backend exposes via GET /stripe/prices. */
export type StripeProduct =
  | "inside"
  | "stoicism_deep"
  | "existentialism"
  | "zen_mindfulness"
  | "renaissance_mind"
  | "classical_foundations"
  | "modern_human_condition";

export interface StripeCheckoutSession {
  url: string;
  session_id: string;
}

export interface StripePriceEntry {
  product: StripeProduct;
  price_id: string;
  payment_link: string | null;
  amount: number;
  currency: string;
  type: "premium_unlock" | "pack_purchase";
}

/* ─── Social ──────────────────────────────────────────────────────────────── */

/** A user the current device follows. `since` is the follow timestamp. */
export interface SocialUser {
  user_id: string;
  display_name: string;
  since: string;
}

/** Backend uses these action types in social_activity.action_type. */
export type SocialAction = "like" | "save" | "share";

/** A row in /social/feed: someone you follow did something with a quote. */
export interface SocialFeedItem {
  id: string;
  user: string;
  action: SocialAction;
  quote: {
    id: string;
    text?: string;
    author?: string;
    category?: CategoryKey;
  };
  at: string;
}

export interface SocialStreak {
  streak: number;
  longest: number;
  last_active?: string;
  active_today: boolean;
}

/** Response of POST /social/streak/checkin. */
export interface StreakCheckin {
  streak: number;
  longest: number;
  /** True when checkin happened earlier today; no streak change. */
  already?: boolean;
  /** True on every 7th day — UI can fire confetti. */
  milestone?: boolean;
}

/** A single Quote of the Day. The backend ships `swipe_dir` next to the
 *  Quote shape — we keep it loose to match. */
export interface QuoteOfDay {
  date: string;
  quote: (Quote & { swipe_dir?: Direction }) | null;
}
