import type { MetadataRoute } from "next";
import {
  getAllAuthors,
  getAllQuotes,
} from "@/lib/quotes-catalog";
import { SITE_URL } from "@/lib/site";

/**
 * Static sitemap covering:
 *   - the marketing surface (/)
 *   - every bundled quote landing page
 *   - every bundled author page
 *
 * Per-route surfaces tied to per-device state (/vault, /map, /social,
 * /onboarding, /payment/*) are deliberately omitted — Google has nothing
 * useful to index there and indexing them would dilute the canonical
 * signal for the public catalog.
 */
export default function sitemap(): MetadataRoute.Sitemap {
  const today = new Date();

  return [
    {
      url: `${SITE_URL}/`,
      lastModified: today,
      changeFrequency: "weekly",
      priority: 1.0,
    },
    ...getAllQuotes().map(q => ({
      url: `${SITE_URL}/quotes/${q.id}`,
      lastModified: today,
      changeFrequency: "monthly" as const,
      priority: 0.7,
    })),
    ...getAllAuthors().map(a => ({
      url: `${SITE_URL}/authors/${a.slug}`,
      lastModified: today,
      changeFrequency: "monthly" as const,
      priority: 0.5,
    })),
  ];
}
