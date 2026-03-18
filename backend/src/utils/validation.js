/** RFC 4122 UUID regex — case-insensitive. */
export const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** Normalize lang to 'en' or 'es'. Anything else defaults to 'en'. */
export function normalizeLang(raw) {
  if (!raw) return "en";
  const l = String(raw).slice(0, 2).toLowerCase();
  return l === "es" ? "es" : "en";
}

/** Derive author slug from display name — NFD decomposition strips accents. */
export function authorSlug(name) {
  if (!name) return "";
  return name
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
}
