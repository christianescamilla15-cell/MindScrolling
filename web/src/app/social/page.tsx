"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import SocialSheet from "@/components/SocialSheet";
import {
  apiGetSocialFeed,
  apiGetSocialStreak,
  apiSocialCheckin,
  apiGetQuoteOfDay,
} from "@/api/quotes";
import type {
  Lang,
  QuoteOfDay,
  SocialFeedItem,
  SocialStreak,
} from "@/types";

const LANG_KEY = "mindscroll_lang";

function loadLang(): Lang {
  try {
    const raw = localStorage.getItem(LANG_KEY);
    if (raw === "en" || raw === "es") return raw;
  } catch { /* noop */ }
  return "en";
}

/**
 * Standalone /social route. Three concurrent loads on mount:
 *   - apiSocialCheckin: fire-and-forget; records the user as active today
 *     (idempotent — backend returns `already: true` if already done)
 *   - apiGetSocialStreak: real source of truth for the streak badge
 *   - apiGetQuoteOfDay: today's curated quote (lang-scoped)
 *   - apiGetSocialFeed: friends' recent activity (capped at 20)
 *
 * Backend's social.js returns an empty feed with a `message` field when the
 * user follows nobody yet — passed through to the empty-state CTA.
 */
export default function SocialPage() {
  const router = useRouter();
  const [streak, setStreak] = useState<SocialStreak | null>(null);
  const [qotd, setQotd] = useState<QuoteOfDay | null>(null);
  const [feed, setFeed] = useState<SocialFeedItem[]>([]);
  const [emptyMessage, setEmptyMessage] = useState<string | undefined>();

  useEffect(() => {
    const lang = loadLang();

    // Fire-and-forget checkin — opening the social tab counts as activity.
    apiSocialCheckin()
      .then(result => {
        if (result) {
          // Refresh streak with the post-checkin number.
          setStreak({
            streak: result.streak,
            longest: result.longest,
            active_today: true,
          });
        }
      })
      .catch(() => { /* swallow — UI falls back to /streak GET */ });

    apiGetSocialStreak().then(s => {
      // Only overwrite if the checkin hasn't landed yet (avoid flicker).
      setStreak(prev => prev ?? s);
    }).catch(() => { /* noop */ });

    apiGetQuoteOfDay(lang).then(setQotd).catch(() => { /* noop */ });

    apiGetSocialFeed(20).then(({ feed: items, message }) => {
      setFeed(items);
      if (message) setEmptyMessage(message);
    }).catch(() => { /* noop */ });
  }, []);

  return (
    <SocialSheet
      streak={streak}
      qotd={qotd}
      feed={feed}
      emptyMessage={emptyMessage}
      onClose={() => router.back()}
    />
  );
}
