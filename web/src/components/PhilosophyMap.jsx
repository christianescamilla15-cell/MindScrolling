import { t } from "../i18n/index.js";

const CATEGORY_COLORS = {
  wisdom:     "#14B8A6",
  discipline: "#F97316",
  reflection: "#A78BFA",
  philosophy: "#F59E0B",
};

const CATEGORY_LABELS = {
  wisdom:     "Wisdom",
  discipline: "Discipline",
  reflection: "Reflection",
  philosophy: "Philosophy",
};

function ProgressBar({ label, color, value, prevValue, showDiff }) {
  const pct     = Math.min(100, Math.max(0, Math.round(value * 100)));
  const prevPct = prevValue !== undefined ? Math.min(100, Math.max(0, Math.round(prevValue * 100))) : null;
  const diff    = prevPct !== null ? pct - prevPct : null;

  return (
    <div className="mb-5">
      <div className="flex justify-between items-center mb-2">
        <span
          className="font-sans text-xs font-semibold tracking-[0.08em] uppercase"
          style={{ color }}
        >
          {label}
        </span>
        <div className="flex items-center gap-2">
          {showDiff && diff !== null && diff !== 0 && (
            <span
              className="font-sans text-[11px] font-semibold"
              style={{ color: diff > 0 ? "#14B8A6" : "#EF4444" }}
            >
              {diff > 0 ? "+" : ""}{diff}%
            </span>
          )}
          <span className="font-sans text-sm font-semibold text-mindscroll-cream">
            {pct}%
          </span>
        </div>
      </div>

      {/* Current bar */}
      <div className={`h-2 rounded bg-white/[0.06] overflow-hidden ${prevPct !== null && showDiff ? "mb-1" : ""}`}>
        <div
          className="h-full rounded transition-[width] duration-700"
          style={{
            width: `${pct}%`,
            background: `linear-gradient(90deg, ${color}cc, ${color})`,
          }}
        />
      </div>

      {/* Previous bar (snapshot comparison) */}
      {prevPct !== null && showDiff && (
        <div className="h-1 rounded-sm bg-white/[0.04] overflow-hidden">
          <div
            className="h-full rounded-sm"
            style={{ width: `${prevPct}%`, background: `${color}44` }}
          />
        </div>
      )}
    </div>
  );
}

/**
 * Normalizes a category scores object so values sum to 1.
 * Accepts either raw counts or already-fractional values.
 */
function normalize(scores) {
  if (!scores) return { wisdom: 0.25, discipline: 0.25, reflection: 0.25, philosophy: 0.25 };
  const keys = ["wisdom", "discipline", "reflection", "philosophy"];
  const total = keys.reduce((s, k) => s + (scores[k] || 0), 0);
  if (total === 0) return { wisdom: 0.25, discipline: 0.25, reflection: 0.25, philosophy: 0.25 };
  const result = {};
  for (const k of keys) result[k] = (scores[k] || 0) / total;
  return result;
}

function formatDate(dateStr) {
  if (!dateStr) return "";
  try {
    return new Date(dateStr).toLocaleDateString(undefined, { month: "short", day: "numeric" });
  } catch (_) {
    return dateStr;
  }
}

export default function PhilosophyMap({ mapData, lang = "en", onClose }) {
  const current  = normalize(mapData?.current);
  const snapshot = mapData?.snapshot ? normalize(mapData.snapshot) : null;
  const hasSnap  = snapshot !== null;

  const categories = ["wisdom", "discipline", "reflection", "philosophy"];

  // Find dominant category
  const dominant = categories.reduce((best, k) =>
    current[k] > current[best] ? k : best, categories[0]);

  return (
    <div
      onClick={onClose}
      className="fixed inset-0 z-[200] bg-black/75 flex items-end animate-fade-in"
    >
      <div
        onClick={e => e.stopPropagation()}
        className="w-full max-h-[82vh] bg-mindscroll-bg-soft rounded-t-[28px] border border-white/[0.07] flex flex-col animate-slide-up overflow-hidden"
      >
        {/* Handle */}
        <div className="flex justify-center pt-4">
          <div className="w-10 h-1 rounded-sm bg-white/[0.15]" />
        </div>

        {/* Header */}
        <div className="flex justify-between items-center pt-4 px-7">
          <div>
            <h2 className="m-0 font-serif text-[22px] font-semibold text-mindscroll-cream">
              {t(lang, "map_title")}
            </h2>
            <p className="mt-0.5 mb-0 font-sans text-xs text-white/30">
              Your thinking profile
            </p>
          </div>
          <button
            onClick={onClose}
            className="bg-transparent border border-white/10 rounded-[20px] py-2 px-3.5 text-[13px] font-sans text-white/30 cursor-pointer"
          >
            {t(lang, "close")}
          </button>
        </div>

        {/* Scrollable body */}
        <div className="overflow-y-auto flex-1 pt-6 px-7 pb-10">

          {/* Dominant style callout */}
          <div
            className="rounded-2xl py-4 px-5 mb-7 flex items-center gap-3.5 border"
            style={{
              background: `${CATEGORY_COLORS[dominant]}14`,
              borderColor: `${CATEGORY_COLORS[dominant]}33`,
            }}
          >
            <div
              className="w-3 h-3 rounded-full shrink-0"
              style={{ background: CATEGORY_COLORS[dominant] }}
            />
            <div>
              <p className="m-0 mb-0.5 font-sans text-xs text-white/35">
                Dominant style
              </p>
              <p
                className="m-0 font-serif text-base font-semibold"
                style={{ color: CATEGORY_COLORS[dominant] }}
              >
                {CATEGORY_LABELS[dominant]}
              </p>
            </div>
          </div>

          {/* Bars */}
          {categories.map(cat => (
            <ProgressBar
              key={cat}
              label={CATEGORY_LABELS[cat]}
              color={CATEGORY_COLORS[cat]}
              value={current[cat]}
              prevValue={hasSnap ? snapshot[cat] : undefined}
              showDiff={hasSnap}
            />
          ))}

          {/* Snapshot comparison legend */}
          {hasSnap && (
            <div className="mt-2 flex items-center gap-3">
              <div className="flex items-center gap-1.5">
                <div className="w-5 h-1 bg-white/50 rounded-sm" />
                <span className="font-sans text-[11px] text-white/30">Today</span>
              </div>
              <div className="flex items-center gap-1.5">
                <div className="w-5 h-1 bg-white/20 rounded-sm" />
                <span className="font-sans text-[11px] text-white/30">
                  Snapshot {mapData?.snapshot_date ? `(${formatDate(mapData.snapshot_date)})` : ""}
                </span>
              </div>
            </div>
          )}

          {/* Empty state */}
          {!mapData && (
            <div className="text-center py-5 text-white/25 font-sans text-sm">
              Keep swiping to build your philosophy profile.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
