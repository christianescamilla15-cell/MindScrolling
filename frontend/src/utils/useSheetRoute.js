import { useLocation, useNavigate } from "react-router-dom";

/**
 * Maps top-level routes to overlay sheets so the UI stays modal-based
 * while URLs become shareable/bookmarkable.
 *
 *   /           -> feed (no sheet)
 *   /vault      -> vault sheet open
 *   /settings   -> settings overlay open
 *   /map        -> philosophy map open
 *   /challenge  -> daily challenge open
 *   /donation   -> donation panel open
 *   /onboarding -> handled separately (has completion gate)
 *
 * Returned `active` is the sheet name or null. `open(name)` and `close()`
 * navigate without polluting browser history (replace: false so Back works).
 */
const SHEETS = new Set(["vault", "settings", "map", "challenge", "donation"]);

export function useSheetRoute() {
  const location = useLocation();
  const navigate = useNavigate();
  const segment  = location.pathname.slice(1).split("/")[0];
  const active   = SHEETS.has(segment) ? segment : null;

  const open  = (name) => { if (SHEETS.has(name)) navigate(`/${name}`); };
  const close = () => navigate("/");

  return { active, open, close };
}
