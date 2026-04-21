"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import VaultSheet from "@/components/VaultSheet";
import { apiRemoveVault } from "@/api/quotes";
import { loadState, saveState } from "@/utils/storage";
import type { Lang, Quote } from "@/types";

const LANG_KEY = "mindscroll_lang";

function loadLang(): Lang {
  try {
    const raw = localStorage.getItem(LANG_KEY);
    if (raw === "en" || raw === "es") return raw;
  } catch { /* noop */ }
  return "en";
}

/**
 * Standalone /vault route. Reads the saved-quotes list straight from
 * localStorage (no shared in-memory state with /), supports remove +
 * persists the result, and dismisses via router.back() so the user lands
 * back on the feed exactly where they left it.
 */
export default function VaultPage() {
  const router = useRouter();
  const [items, setItems] = useState<Quote[]>([]);
  const [lang, setLang] = useState<Lang>("en");

  useEffect(() => {
    setLang(loadLang());
    const state = loadState();
    setItems(state?.vault ?? []);
  }, []);

  const handleRemove = (id: string) => {
    setItems(prev => {
      const next = prev.filter(q => q.id !== id);
      const state = loadState();
      saveState({
        liked:        state?.liked ?? [],
        vault:        next,
        streak:       state?.streak ?? 0,
        reflections:  state?.reflections ?? 0,
        swipeCounts:  state?.swipeCounts,
      });
      return next;
    });
    apiRemoveVault(id).catch(() => { /* fire-and-forget */ });
  };

  return (
    <VaultSheet
      items={items}
      onClose={() => router.back()}
      onRemove={handleRemove}
      lang={lang}
    />
  );
}
