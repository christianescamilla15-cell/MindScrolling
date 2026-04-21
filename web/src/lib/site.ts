// Single source of truth for the public site origin. Used by sitemap,
// robots, and JSON-LD. Falls back to localhost so local builds don't
// emit cross-origin URLs that look real but aren't.
//
// `.trim()` matters: `vercel env add` over stdin preserves trailing
// newlines, which then concat into URLs like `https://host\n/path` —
// valid-looking in the browser's URL bar but rejected by Google's
// sitemap parser and every JSON-LD consumer. `new URL()` (used by
// Next.js metadataBase) normalises that automatically; raw string
// concat does not.
export const SITE_URL =
  process.env.NEXT_PUBLIC_SITE_URL?.trim().replace(/\/$/, "") || "http://localhost:3001";

export function absUrl(path: string): string {
  return `${SITE_URL}${path.startsWith("/") ? "" : "/"}${path}`;
}
