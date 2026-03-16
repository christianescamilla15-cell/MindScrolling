import {
  QUOTABLE_BASE,
  CATEGORY_TAGS,
  CATEGORY_TO_DIR,
  PER_CATEGORY,
  USER_LANG,
} from "../constants/index.js";
import { shuffle } from "../utils/shuffle.js";
import { getDeviceId } from "../utils/storage.js";
import QUOTES_EN from "../data/quotes_en.js";
import QUOTES_ES from "../data/quotes_es.js";
import { t } from "../i18n/index.js";

const API_BASE = import.meta.env.VITE_API_URL || "";

/** Headers sent to our own backend */
function apiHeaders() {
  return {
    "Content-Type":  "application/json",
    "X-Device-ID":   getDeviceId(),
  };
}

/* ─── OWN BACKEND ────────────────────────────────────────────────────────────── */

export async function apiFetchFeed(cursor, lang = USER_LANG) {
  const params = new URLSearchParams({ lang, limit: 20 });
  if (cursor) params.set("cursor", cursor);
  const res = await fetch(`${API_BASE}/quotes/feed?${params}`, { headers: apiHeaders() });
  if (!res.ok) throw new Error(res.status);
  return res.json(); // { data: [...], next_cursor, has_more }
}

export async function apiLike(quoteId, action = "like") {
  await fetch(`${API_BASE}/quotes/${quoteId}/like`, {
    method: "POST",
    headers: apiHeaders(),
    body: JSON.stringify({ action }),
  });
}

export async function apiSaveVault(quoteId) {
  await fetch(`${API_BASE}/vault`, {
    method: "POST",
    headers: apiHeaders(),
    body: JSON.stringify({ quote_id: quoteId }),
  });
}

export async function apiRemoveVault(quoteId) {
  await fetch(`${API_BASE}/vault/${quoteId}`, {
    method: "DELETE",
    headers: apiHeaders(),
  });
}

export async function apiFetchStats() {
  const res = await fetch(`${API_BASE}/stats`, { headers: apiHeaders() });
  if (!res.ok) throw new Error(res.status);
  return res.json(); // { streak, total_reflections, category_counts }
}

/* ─── FEED (with Quotable.io fallback) ──────────────────────────────────────── */

/**
 * Fetch quotes for infinite scroll.
 * Priority: own backend → Quotable.io → bundled offline fallback
 */
export async function fetchQuotes(page = 1, lang = USER_LANG, cursor = null) {
  // Spanish: static curated dataset (no API needed)
  if (lang === "es") {
    return { quotes: shuffle([...QUOTES_ES]), nextPage: null, nextCursor: null };
  }

  // Try own backend first (only when VITE_API_URL is set)
  if (import.meta.env.VITE_API_URL) {
    try {
      const data = await apiFetchFeed(cursor, lang);
      const quotes = (data.data ?? []).map(q => ({
        ...q,
        dir: CATEGORY_TO_DIR[q.category] ?? "left",
      }));
      return {
        quotes: shuffle(quotes),
        nextPage:   null,
        nextCursor: data.has_more ? data.next_cursor : null,
      };
    } catch {
      // fall through to Quotable.io
    }
  }

  // Quotable.io (public API, EN only)
  const categories = Object.keys(CATEGORY_TAGS);
  try {
    const results = await Promise.all(
      categories.map(cat =>
        fetch(`${QUOTABLE_BASE}/quotes?tags=${CATEGORY_TAGS[cat]}&page=${page}&limit=${PER_CATEGORY}`)
          .then(r => { if (!r.ok) throw new Error(r.status); return r.json(); })
      )
    );
    const quotes = results.flatMap((result, i) =>
      (result.results ?? []).map(q => ({
        id:       q._id,
        text:     q.content,
        author:   q.author,
        category: categories[i],
        dir:      CATEGORY_TO_DIR[categories[i]],
        lang:     "en",
      }))
    );
    const hasMore = results.some(r => r.page < r.totalPages);
    return { quotes: shuffle(quotes), nextPage: hasMore ? page + 1 : null, nextCursor: null };
  } catch {
    return { quotes: shuffle([...QUOTES_EN]), nextPage: null, nextCursor: null };
  }
}

/* ─── SHARE ──────────────────────────────────────────────────────────────────── */

export async function shareQuote(quote, showToast, lang = "en") {
  const text = `"${quote.text}" \u2014 ${quote.author}\n${t(lang, "share_via")}`;
  if (navigator.share) {
    try {
      await navigator.share({ title: "MindScroll", text });
    } catch (err) {
      if (err.name !== "AbortError") showToast("Share failed", "#EF4444");
    }
  } else {
    try {
      await navigator.clipboard.writeText(text);
      showToast(t(lang, "copied"), "#14B8A6");
    } catch (_) {
      showToast("Could not copy", "#EF4444");
    }
  }
}

/* ─── PROFILE ────────────────────────────────────────────────────────────────── */

export async function apiSaveProfile(profile) {
  await fetch(`${API_BASE}/profile`, {
    method: "POST",
    headers: apiHeaders(),
    body: JSON.stringify(profile),
  });
}

export async function apiGetProfile() {
  const res = await fetch(`${API_BASE}/profile`, { headers: apiHeaders() });
  if (!res.ok) return null;
  return res.json();
}

/* ─── SWIPE RECORDING ────────────────────────────────────────────────────────── */

export async function apiRecordSwipe(quoteId, direction, category, dwellTimeMs = 0) {
  await fetch(`${API_BASE}/swipes`, {
    method: "POST",
    headers: apiHeaders(),
    body: JSON.stringify({ quote_id: quoteId, direction, category, dwell_time_ms: dwellTimeMs }),
  });
}

/* ─── CHALLENGE ──────────────────────────────────────────────────────────────── */

export async function apiGetTodayChallenge() {
  const res = await fetch(`${API_BASE}/challenges/today`, { headers: apiHeaders() });
  if (!res.ok) return null;
  return res.json();
}

export async function apiUpdateChallengeProgress(challengeId, progress, completed) {
  await fetch(`${API_BASE}/challenges/${challengeId}/progress`, {
    method: "POST",
    headers: apiHeaders(),
    body: JSON.stringify({ progress, completed }),
  });
}

/* ─── PHILOSOPHY MAP ─────────────────────────────────────────────────────────── */

export async function apiGetMap() {
  const res = await fetch(`${API_BASE}/map`, { headers: apiHeaders() });
  if (!res.ok) return null;
  return res.json();
}

export async function apiSaveMapSnapshot() {
  await fetch(`${API_BASE}/map/snapshot`, {
    method: "POST",
    headers: apiHeaders(),
  });
}

/* ─── PREMIUM ────────────────────────────────────────────────────────────────── */

export async function apiGetPremiumStatus() {
  const res = await fetch(`${API_BASE}/premium/status`, { headers: apiHeaders() });
  if (!res.ok) return { is_premium: false };
  return res.json();
}

export async function apiUnlockPremium(purchaseData) {
  const res = await fetch(`${API_BASE}/premium/unlock`, {
    method: "POST",
    headers: apiHeaders(),
    body: JSON.stringify(purchaseData),
  });
  return res.json();
}
