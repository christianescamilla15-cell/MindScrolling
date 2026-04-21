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

export interface PersistedState {
  liked: string[];
  vault: Quote[];
  streak: number;
  reflections: number;
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
