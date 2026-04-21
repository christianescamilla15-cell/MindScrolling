"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import PhilosophyMap from "@/components/PhilosophyMap";
import { apiGetMap } from "@/api/quotes";
import { loadState } from "@/utils/storage";
import { EMPTY_SWIPE_COUNTS } from "@/types";
import type { Lang, MapData } from "@/types";

const LANG_KEY = "mindscroll_lang";

function loadLang(): Lang {
  try {
    const raw = localStorage.getItem(LANG_KEY);
    if (raw === "en" || raw === "es") return raw;
  } catch { /* noop */ }
  return "en";
}

/**
 * Standalone /map route. Tries the backend first (apiGetMap → backend's
 * snapshot + comparison view) and falls back to the persisted swipeCounts
 * from localStorage so the offline experience still shows something.
 *
 * The fallback re-keys swipeCounts (philosophy / stoicism / discipline /
 * reflection) into the MapCategoryKey set (philosophy / wisdom /
 * discipline / reflection) — wisdom replaces stoicism at the map layer.
 */
export default function MapPage() {
  const router = useRouter();
  const [mapData, setMapData] = useState<MapData | null>(null);
  const [lang, setLang] = useState<Lang>("en");

  useEffect(() => {
    setLang(loadLang());

    // Optimistic: build a local fallback from persisted swipeCounts.
    const state = loadState();
    const counts = state?.swipeCounts ?? EMPTY_SWIPE_COUNTS;
    setMapData({
      current: {
        wisdom:     counts.stoicism,
        discipline: counts.discipline,
        reflection: counts.reflection,
        philosophy: counts.philosophy,
      },
      snapshot: null,
      snapshot_date: null,
    });

    // Then try the backend; replace if it returns something.
    apiGetMap().then(data => {
      if (data) setMapData(data);
    }).catch(() => { /* fire-and-forget */ });
  }, []);

  return (
    <PhilosophyMap
      mapData={mapData}
      lang={lang}
      onClose={() => router.back()}
    />
  );
}
