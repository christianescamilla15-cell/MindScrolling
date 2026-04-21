import type { CategoryKey, CategoryMeta, Direction, Lang } from "../types";

export const CATEGORY_META: Record<CategoryKey, CategoryMeta> = {
  philosophy: { label: "Classical Philosophy", color: "#F59E0B", bg: "rgba(245,158,11,0.12)", dir: "↑ Up" },
  stoicism:   { label: "Stoicism",             color: "#14B8A6", bg: "rgba(20,184,166,0.12)", dir: "← Left" },
  discipline: { label: "Discipline",           color: "#F97316", bg: "rgba(249,115,22,0.12)", dir: "→ Right" },
  reflection: { label: "Reflection",           color: "#A78BFA", bg: "rgba(167,139,250,0.12)", dir: "↓ Down" },
};

export const DIR_TO_CATEGORY: Record<Direction, CategoryKey> = {
  up:    "philosophy",
  left:  "stoicism",
  right: "discipline",
  down:  "reflection",
};

export const CATEGORY_TO_DIR: Record<CategoryKey, Direction> = {
  philosophy: "up",
  stoicism:   "left",
  discipline: "right",
  reflection: "down",
};

/** Quotable.io tags mapped to our 4 categories.
 *  reflection / philosophy share `philosophy` tag space — see fetchQuotes
 *  for how that is fanned out. */
export const CATEGORY_TAGS: Record<CategoryKey, string> = {
  stoicism:   "wisdom",
  philosophy: "philosophy",
  discipline: "success|motivational",
  reflection: "inspirational|life",
};

export const QUOTABLE_BASE = "https://api.quotable.io";
export const PER_CATEGORY  = 8;
export const STORAGE_KEY   = "mindscroll_state";

/** Best-effort browser language detection. SSR returns "en"; the actual
 *  user lang is hydrated from localStorage on first client render. */
export const USER_LANG: Lang = (typeof navigator !== "undefined"
  ? (navigator.language.slice(0, 2) as Lang)
  : "en") || "en";

// Premium pricing display (display-only, store manages real price)
export const PREMIUM_PRICE_DISPLAY: Record<string, string> = {
  USD: "$2.99",
  MXN: "$59",
  BRL: "R$14,90",
  ARS: "$299",
  EUR: "\u20AC2.79",
};

export const PREMIUM_BASE_PRICE_USD = 2.99;

// Pack names
export const PACK_NAMES = {
  free:               "Free",
  stoicism_pack:      "Stoicism Pack",
  zen_pack:           "Zen Pack",
  existential_pack:   "Existential Pack",
  modern_thinkers:    "Modern Thinkers",
  dark_philosophy:    "Dark Philosophy",
  life_reflections:   "Life Reflections",
  science_meaning:    "Science & Meaning",
} as const;

// Daily challenge codes
export const CHALLENGE_CODES = {
  SAVE_ONE:         "save_one_quote",
  LIKE_THREE:       "like_three_quotes",
  EXPLORE_CATEGORY: "explore_new_category",
  EIGHT_SWIPES:     "complete_eight_swipes",
  SHARE_ONE:        "share_one_quote",
} as const;
