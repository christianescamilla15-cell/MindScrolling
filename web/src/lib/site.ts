// Single source of truth for the public site origin. Used by sitemap,
// robots, and JSON-LD. Falls back to localhost so local builds don't
// emit cross-origin URLs that look real but aren't.

export const SITE_URL =
  process.env.NEXT_PUBLIC_SITE_URL?.replace(/\/$/, "") || "http://localhost:3001";

export function absUrl(path: string): string {
  return `${SITE_URL}${path.startsWith("/") ? "" : "/"}${path}`;
}
