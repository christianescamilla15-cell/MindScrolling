import type { MetadataRoute } from "next";
import {
  getAllAuthors,
  getAllCategoryKeys,
  getAllQuotes,
} from "@/lib/quotes-catalog";
import { SITE_URL } from "@/lib/site";

/**
 * Static sitemap covering:
 *   - the marketing surface (/)
 *   - every bundled quote landing page
 *   - every bundled author page
 *   - every category landing page (4 today)
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
    // Category pages sit above authors in priority because they are the
    // topical hubs queries land on ("stoicism quotes", "philosophy quotes")
    ...getAllCategoryKeys().map(cat => ({
      url: `${SITE_URL}/categories/${cat}`,
      lastModified: today,
      changeFrequency: "weekly" as const,
      priority: 0.8,
    })),
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
