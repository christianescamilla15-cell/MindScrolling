import {
  QUOTABLE_BASE,
  CATEGORY_TAGS,
  CATEGORY_TO_DIR,
  PER_CATEGORY,
  USER_LANG,
} from "../constants";
import { shuffle } from "../utils/shuffle";
import { getDeviceId } from "../utils/storage";
import QUOTES_EN from "../data/quotes_en";
import QUOTES_ES from "../data/quotes_es";
import { t } from "../i18n";
import type {
  CategoryKey,
  ChallengeData,
  ChallengeProgress,
  Direction,
  FeedResponse,
  Lang,
  MapData,
  PremiumStatus,
  Profile,
  Quote,
  Toast,
} from "../types";

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "";

interface FeedPage {
  quotes: Quote[];
  nextPage: number | null;
  nextCursor: string | null;
}

interface QuotableQuote {
  _id: string;
  content: string;
  author: string;
}

interface QuotableResponse {
  results: QuotableQuote[];
  page: number;
  totalPages: number;
}

type ToastFn = (msg: string, color?: Toast["color"]) => void;

/** Headers sent to our own backend */
function apiHeaders(): HeadersInit {
  return {
    "Content-Type": "application/json",
    "X-Device-ID":  getDeviceId(),
  };
}

/* ─── OWN BACKEND ────────────────────────────────────────────────────────────── */

export async function apiFetchFeed(
  cursor: string | null,
  lang: Lang | string = USER_LANG,
): Promise<FeedResponse> {
  const params = new URLSearchParams({ lang: String(lang), limit: "20" });
  if (cursor) params.set("cursor", cursor);
  const res = await fetch(`${API_BASE}/quotes/feed?${params}`, { headers: apiHeaders() });
  if (!res.ok) throw new Error(String(res.status));
  return res.json() as Promise<FeedResponse>;
}

export async function apiLike(quoteId: string, action: "like" | "unlike" = "like"): Promise<void> {
  await fetch(`${API_BASE}/quotes/${quoteId}/like`, {
    method: "POST",
    headers: apiHeaders(),
    body: JSON.stringify({ action }),
  });
}

export async function apiSaveVault(quoteId: string): Promise<void> {
  await fetch(`${API_BASE}/vault`, {
    method: "POST",
    headers: apiHeaders(),
    body: JSON.stringify({ quote_id: quoteId }),
  });
}

export async function apiRemoveVault(quoteId: string): Promise<void> {
  await fetch(`${API_BASE}/vault/${quoteId}`, {
    method: "DELETE",
    headers: apiHeaders(),
  });
}

export interface StatsResponse {
  streak: number;
  total_reflections: number;
  category_counts: Record<CategoryKey, number>;
}

export async function apiFetchStats(): Promise<StatsResponse> {
  const res = await fetch(`${API_BASE}/stats`, { headers: apiHeaders() });
  if (!res.ok) throw new Error(String(res.status));
  return res.json() as Promise<StatsResponse>;
}

/* ─── FEED (with Quotable.io fallback) ──────────────────────────────────────── */

/**
 * Fetch quotes for infinite scroll.
 * Priority: own backend → Quotable.io → bundled offline fallback
 */
export async function fetchQuotes(
  page = 1,
  lang: Lang | string = USER_LANG,
  cursor: string | null = null,
): Promise<FeedPage> {
  // Spanish: static curated dataset (no API needed)
  if (lang === "es") {
    return { quotes: shuffle([...QUOTES_ES]), nextPage: null, nextCursor: null };
  }

  // Try own backend first (only when NEXT_PUBLIC_API_URL is set)
  if (process.env.NEXT_PUBLIC_API_URL) {
    try {
      const data = await apiFetchFeed(cursor, lang);
      const quotes: Quote[] = (data.data ?? []).map(q => ({
        ...q,
        dir: CATEGORY_TO_DIR[q.category] ?? "left",
      }));
      return {
        quotes:     shuffle(quotes),
        nextPage:   null,
        nextCursor: data.has_more ? data.next_cursor : null,
      };
    } catch {
      // fall through to Quotable.io
    }
  }

  // Quotable.io (public API, EN only)
  const categories = Object.keys(CATEGORY_TAGS) as CategoryKey[];
  try {
    const results: QuotableResponse[] = await Promise.all(
      categories.map(cat =>
        fetch(`${QUOTABLE_BASE}/quotes?tags=${CATEGORY_TAGS[cat]}&page=${page}&limit=${PER_CATEGORY}`)
          .then(r => {
            if (!r.ok) throw new Error(String(r.status));
            return r.json() as Promise<QuotableResponse>;
          })
      )
    );
    const quotes: Quote[] = results.flatMap((result, i) =>
      (result.results ?? []).map(q => ({
        id:       q._id,
        text:     q.content,
        author:   q.author,
        category: categories[i],
        dir:      CATEGORY_TO_DIR[categories[i]],
        lang:     "en" as const,
      }))
    );
    const hasMore = results.some(r => r.page < r.totalPages);
    return { quotes: shuffle(quotes), nextPage: hasMore ? page + 1 : null, nextCursor: null };
  } catch {
    return { quotes: shuffle([...QUOTES_EN]), nextPage: null, nextCursor: null };
  }
}

/* ─── SHARE ──────────────────────────────────────────────────────────────────── */

export async function shareQuote(
  quote: Quote,
  showToast: ToastFn,
  lang: Lang | string = "en",
): Promise<void> {
  const text = `"${quote.text}" \u2014 ${quote.author}\n${t(lang, "share_via")}`;
  if (navigator.share) {
    try {
      await navigator.share({ title: "MindScroll", text });
    } catch (err) {
      if ((err as DOMException)?.name !== "AbortError") showToast("Share failed", "#EF4444");
    }
  } else {
    try {
      await navigator.clipboard.writeText(text);
      showToast(t(lang, "copied"), "#14B8A6");
    } catch {
      showToast("Could not copy", "#EF4444");
    }
  }
}

/* ─── PROFILE ────────────────────────────────────────────────────────────────── */

export async function apiSaveProfile(profile: Profile): Promise<void> {
  await fetch(`${API_BASE}/profile`, {
    method: "POST",
    headers: apiHeaders(),
    body: JSON.stringify(profile),
  });
}

export async function apiGetProfile(): Promise<Profile | null> {
  const res = await fetch(`${API_BASE}/profile`, { headers: apiHeaders() });
  if (!res.ok) return null;
  return res.json() as Promise<Profile>;
}

/* ─── SWIPE RECORDING ────────────────────────────────────────────────────────── */

export async function apiRecordSwipe(
  quoteId: string,
  direction: Direction,
  category: CategoryKey,
  dwellTimeMs = 0,
): Promise<void> {
  await fetch(`${API_BASE}/swipes`, {
    method: "POST",
    headers: apiHeaders(),
    body: JSON.stringify({ quote_id: quoteId, direction, category, dwell_time_ms: dwellTimeMs }),
  });
}

/* ─── CHALLENGE ──────────────────────────────────────────────────────────────── */

export async function apiGetTodayChallenge(): Promise<ChallengeData | null> {
  const res = await fetch(`${API_BASE}/challenges/today`, { headers: apiHeaders() });
  if (!res.ok) return null;
  return res.json() as Promise<ChallengeData>;
}

export async function apiUpdateChallengeProgress(
  challengeId: string,
  progress: number,
  completed: boolean,
): Promise<void> {
  await fetch(`${API_BASE}/challenges/${challengeId}/progress`, {
    method: "POST",
    headers: apiHeaders(),
    body: JSON.stringify({ progress, completed } satisfies ChallengeProgress),
  });
}

/* ─── PHILOSOPHY MAP ─────────────────────────────────────────────────────────── */

export async function apiGetMap(): Promise<MapData | null> {
  const res = await fetch(`${API_BASE}/map`, { headers: apiHeaders() });
  if (!res.ok) return null;
  return res.json() as Promise<MapData>;
}

export async function apiSaveMapSnapshot(): Promise<void> {
  await fetch(`${API_BASE}/map/snapshot`, {
    method: "POST",
    headers: apiHeaders(),
  });
}

/* ─── PREMIUM ────────────────────────────────────────────────────────────────── */

export async function apiGetPremiumStatus(): Promise<PremiumStatus> {
  const res = await fetch(`${API_BASE}/premium/status`, { headers: apiHeaders() });
  if (!res.ok) return { is_premium: false };
  return res.json() as Promise<PremiumStatus>;
}

/** purchaseData shape varies by store (Stripe vs RevenueCat) — leave open. */
export async function apiUnlockPremium(purchaseData: Record<string, unknown>): Promise<PremiumStatus> {
  const res = await fetch(`${API_BASE}/premium/unlock`, {
    method: "POST",
    headers: apiHeaders(),
    body: JSON.stringify(purchaseData),
  });
  return res.json() as Promise<PremiumStatus>;
}

/* ─── STRIPE ──────────────────────────────────────────────────────────────── */

/**
 * Open a Stripe Checkout session for the given product. Returns the URL the
 * caller should redirect to. The webhook on the backend (POST /stripe/webhook)
 * is what actually flips is_premium once the payment lands; this endpoint
 * just creates the session.
 */
export async function apiCreateCheckoutSession(
  product: import("../types").StripeProduct,
): Promise<import("../types").StripeCheckoutSession> {
  const res = await fetch(`${API_BASE}/stripe/checkout`, {
    method: "POST",
    headers: apiHeaders(),
    body: JSON.stringify({ product }),
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({})) as { error?: string };
    throw new Error(err.error || `Checkout failed (${res.status})`);
  }
  return res.json() as Promise<import("../types").StripeCheckoutSession>;
}

/** List all Stripe prices the backend knows about. */
export async function apiGetStripePrices(): Promise<{ prices: import("../types").StripePriceEntry[] }> {
  const res = await fetch(`${API_BASE}/stripe/prices`, { headers: apiHeaders() });
  if (!res.ok) throw new Error(String(res.status));
  return res.json() as Promise<{ prices: import("../types").StripePriceEntry[] }>;
}

/* ─── SOCIAL ──────────────────────────────────────────────────────────────── */

import type {
  QuoteOfDay,
  SocialFeedItem,
  SocialStreak,
  SocialUser,
  StreakCheckin,
} from "../types";

export async function apiSocialFollow(userId: string): Promise<void> {
  await fetch(`${API_BASE}/social/follow`, {
    method: "POST",
    headers: apiHeaders(),
    body: JSON.stringify({ user_id: userId }),
  });
}

export async function apiSocialUnfollow(userId: string): Promise<void> {
  await fetch(`${API_BASE}/social/follow/${userId}`, {
    method: "DELETE",
    headers: apiHeaders(),
  });
}

export async function apiGetFollowing(): Promise<{ following: SocialUser[] }> {
  const res = await fetch(`${API_BASE}/social/following`, { headers: apiHeaders() });
  if (!res.ok) return { following: [] };
  return res.json() as Promise<{ following: SocialUser[] }>;
}

export async function apiGetSocialFeed(limit = 20): Promise<{ feed: SocialFeedItem[]; message?: string }> {
  const res = await fetch(`${API_BASE}/social/feed?limit=${limit}`, { headers: apiHeaders() });
  if (!res.ok) return { feed: [] };
  return res.json() as Promise<{ feed: SocialFeedItem[]; message?: string }>;
}

export async function apiGetSocialStreak(): Promise<SocialStreak> {
  const res = await fetch(`${API_BASE}/social/streak`, { headers: apiHeaders() });
  if (!res.ok) return { streak: 0, longest: 0, active_today: false };
  return res.json() as Promise<SocialStreak>;
}

/** Records the user as active today. Idempotent — calling twice the same day
 *  returns `already: true` without bumping the streak. */
export async function apiSocialCheckin(): Promise<StreakCheckin | null> {
  const res = await fetch(`${API_BASE}/social/streak/checkin`, {
    method: "POST",
    headers: apiHeaders(),
  });
  if (!res.ok) return null;
  return res.json() as Promise<StreakCheckin>;
}

export async function apiGetQuoteOfDay(lang: import("../types").Lang | string = "en"): Promise<QuoteOfDay | null> {
  const res = await fetch(`${API_BASE}/social/qotd?lang=${encodeURIComponent(String(lang))}`, { headers: apiHeaders() });
  if (!res.ok) return null;
  return res.json() as Promise<QuoteOfDay>;
}
