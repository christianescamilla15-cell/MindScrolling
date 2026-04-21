import { t } from "../i18n";
import type { CategoryScores, Lang, MapCategoryKey, MapData } from "../types";

const CATEGORY_COLORS: Record<MapCategoryKey, string> = {
  wisdom:     "#14B8A6",
  discipline: "#F97316",
  reflection: "#A78BFA",
  philosophy: "#F59E0B",
};

const CATEGORY_LABELS: Record<MapCategoryKey, string> = {
  wisdom:     "Wisdom",
  discipline: "Discipline",
  reflection: "Reflection",
  philosophy: "Philosophy",
};

const KEYS: MapCategoryKey[] = ["wisdom", "discipline", "reflection", "philosophy"];
const EVEN_SCORES: CategoryScores = { wisdom: 0.25, discipline: 0.25, reflection: 0.25, philosophy: 0.25 };

interface ProgressBarProps {
  label: string;
  color: string;
  value: number;
  prevValue?: number;
  showDiff?: boolean;
}

function ProgressBar({ label, color, value, prevValue, showDiff }: ProgressBarProps) {
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
function normalize(scores: CategoryScores | null | undefined): CategoryScores {
  if (!scores) return EVEN_SCORES;
  const total = KEYS.reduce((s, k) => s + (scores[k] || 0), 0);
  if (total === 0) return EVEN_SCORES;
  const result = {} as CategoryScores;
  for (const k of KEYS) result[k] = (scores[k] || 0) / total;
  return result;
}

function formatDate(dateStr: string | null | undefined): string {
  if (!dateStr) return "";
  try {
    return new Date(dateStr).toLocaleDateString(undefined, { month: "short", day: "numeric" });
  } catch {
    return dateStr;
  }
}

interface Props {
  mapData: MapData | null;
  lang?: Lang;
  onClose: () => void;
}

export default function PhilosophyMap({ mapData, lang = "en", onClose }: Props) {
  const current  = normalize(mapData?.current);
  const snapshot = mapData?.snapshot ? normalize(mapData.snapshot) : null;
  const hasSnap  = snapshot !== null;

  // Find dominant category
  const dominant = KEYS.reduce<MapCategoryKey>((best, k) =>
    current[k] > current[best] ? k : best, KEYS[0]);

  return (
    <div
      onClick={onClose}
      className="fixed inset-0 z-[200] bg-black/75 flex items-end animate-fade-in"
    >
      <div
        onClick={(e) => e.stopPropagation()}
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
          {KEYS.map(cat => (
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
