// Server-only quote catalog.
//
// For Fase 3 SEO we pre-render landing pages from the bundled offline
// dataset (47 quotes total: 15 EN + 32 ES). When the backend grows a
// public-by-slug quotes endpoint, swap the source here without touching
// the page templates.

import QUOTES_EN from "../data/quotes_en";
import QUOTES_ES from "../data/quotes_es";
import type { CategoryKey, Quote } from "../types";
import { CATEGORY_META } from "../constants";

/** Strips diacritics and non-alphanumeric characters → "Marc Aurelio" → "marc-aurelio". */
export function slugify(input: string): string {
  return input
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "");
}

/** Quote slugs use the existing string id (`en-3`, `es-s1`) — stable + URL-safe.
 *  Author slugs are derived from the display name. */
export interface AuthorEntry {
  slug: string;
  name: string;
  /** Sample quote count (capped to bundled data; not the global total). */
  quoteCount: number;
}

const ALL_QUOTES: Quote[] = [...QUOTES_EN, ...QUOTES_ES];

const QUOTES_BY_ID = new Map<string, Quote>();
for (const q of ALL_QUOTES) QUOTES_BY_ID.set(q.id, q);

const AUTHOR_INDEX = new Map<string, { name: string; quotes: Quote[] }>();
for (const q of ALL_QUOTES) {
  const slug = slugify(q.author);
  const entry = AUTHOR_INDEX.get(slug) ?? { name: q.author, quotes: [] };
  entry.quotes.push(q);
  AUTHOR_INDEX.set(slug, entry);
}

export function getAllQuotes(): Quote[] {
  return ALL_QUOTES;
}

export function getQuoteById(id: string): Quote | undefined {
  return QUOTES_BY_ID.get(id);
}

export function getAllAuthors(): AuthorEntry[] {
  return Array.from(AUTHOR_INDEX.entries())
    .map(([slug, { name, quotes }]) => ({ slug, name, quoteCount: quotes.length }))
    .sort((a, b) => a.name.localeCompare(b.name));
}

export function getAuthorBySlug(slug: string): AuthorEntry | undefined {
  const entry = AUTHOR_INDEX.get(slug);
  return entry ? { slug, name: entry.name, quoteCount: entry.quotes.length } : undefined;
}

export function getQuotesByAuthor(slug: string): Quote[] {
  return AUTHOR_INDEX.get(slug)?.quotes ?? [];
}

/** Picks up to N other quotes for the "more like this" rail on quote pages. */
export function getRelatedQuotes(id: string, max = 3): Quote[] {
  const seed = QUOTES_BY_ID.get(id);
  if (!seed) return [];
  const sameAuthor = getQuotesByAuthor(slugify(seed.author)).filter(q => q.id !== id);
  if (sameAuthor.length >= max) return sameAuthor.slice(0, max);
  const sameCategory = ALL_QUOTES
    .filter(q => q.category === seed.category && q.id !== id && !sameAuthor.find(s => s.id === q.id))
    .slice(0, max - sameAuthor.length);
  return [...sameAuthor, ...sameCategory];
}

/** Used by /sitemap.ts and generateStaticParams. */
export function getQuoteSlugs(): string[] {
  return ALL_QUOTES.map(q => q.id);
}

export function getAuthorSlugs(): string[] {
  return Array.from(AUTHOR_INDEX.keys());
}

/** Category slugs match the CategoryKey strings themselves — already URL-safe. */
export function getAllCategoryKeys(): CategoryKey[] {
  return Object.keys(CATEGORY_META) as CategoryKey[];
}

export function getQuotesByCategory(key: CategoryKey): Quote[] {
  return ALL_QUOTES.filter(q => q.category === key);
}
