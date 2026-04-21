import { t } from "../i18n";

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

function normalize(scores) {
  if (!scores) return { wisdom: 0.25, discipline: 0.25, reflection: 0.25, philosophy: 0.25 };
  const keys = ["wisdom", "discipline", "reflection", "philosophy"];
  const total = keys.reduce((s, k) => s + (scores[k] || 0), 0);
  if (total === 0) return { wisdom: 0.25, discipline: 0.25, reflection: 0.25, philosophy: 0.25 };
  const r = {};
  for (const k of keys) r[k] = (scores[k] || 0) / total;
  return r;
}

function MiniBar({ color, current, previous }) {
  const curPct  = Math.round(current  * 100);
  const prevPct = Math.round(previous * 100);
  const diff    = curPct - prevPct;

  return (
    <div className="flex-1">
      {/* Current bar */}
      <div className="h-[5px] rounded-[3px] bg-white/[0.06] mb-[3px] overflow-hidden">
        <div
          className="h-full rounded-[3px] transition-[width] duration-700 ease-out"
          style={{
            width: `${curPct}%`,
            background: `linear-gradient(90deg, ${color}99, ${color})`,
          }}
        />
      </div>
      {/* Previous bar (ghost) */}
      <div className="h-[3px] rounded-sm bg-white/[0.04] overflow-hidden">
        <div
          className="h-full rounded-sm"
          style={{ width: `${prevPct}%`, background: `${color}33` }}
        />
      </div>
      {/* Diff */}
      {diff !== 0 && (
        <p
          className="mt-1 mb-0 font-sans text-[10px] font-semibold text-center"
          style={{ color: diff > 0 ? color : "rgba(255,255,255,0.25)" }}
        >
          {diff > 0 ? "+" : ""}{diff}%
        </p>
      )}
    </div>
  );
}

/**
 * EvolutionCard — a special feed-style card showing philosophy evolution.
 * Matches the same dimensions as QuoteCard.
 *
 * Props:
 *   current  — { wisdom, discipline, reflection, philosophy }
 *   previous — { wisdom, discipline, reflection, philosophy }
 *   lang     — "en" | "es"
 */
export default function EvolutionCard({ current, previous, lang = "en" }) {
  const cur  = normalize(current);
  const prev = normalize(previous);

  const categories = ["wisdom", "discipline", "reflection", "philosophy"];

  // Compute the category that changed most positively
  const biggest = categories.reduce((best, k) => {
    const diff = cur[k] - prev[k];
    const bestDiff = cur[best] - prev[best];
    return diff > bestDiff ? k : best;
  }, categories[0]);

  return (
    <div
      className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 min-h-[420px] rounded-[28px] bg-gradient-to-br from-mindscroll-bg-card to-mindscroll-bg-card-end border border-white/[0.07] shadow-[0_32px_80px_rgba(0,0,0,0.6),_0_0_0_1px_rgba(255,255,255,0.05)] flex flex-col px-8 pt-9 pb-7 z-10 select-none"
      style={{ width: "min(380px, 90vw)" }}
    >
      {/* Header */}
      <div className="mb-7">
        <p
          className="mt-0 mb-1 font-sans text-[11px] font-semibold tracking-[0.12em] uppercase"
          style={{ color: CATEGORY_COLORS[biggest] }}
        >
          Philosophy Map
        </p>
        <h2 className="m-0 font-serif text-[22px] font-semibold text-mindscroll-cream italic">
          Your thinking is evolving.
        </h2>
      </div>

      {/* Bars */}
      <div className="flex-1 flex flex-col gap-[18px] justify-center">
        {categories.map(cat => (
          <div key={cat}>
            <div className="flex justify-between items-center mb-1.5">
              <span
                className="font-sans text-[11px] font-semibold tracking-[0.08em] uppercase"
                style={{ color: CATEGORY_COLORS[cat] }}
              >
                {CATEGORY_LABELS[cat]}
              </span>
              <span className="font-sans text-[13px] font-semibold text-mindscroll-cream">
                {Math.round(cur[cat] * 100)}%
              </span>
            </div>
            <MiniBar
              color={CATEGORY_COLORS[cat]}
              current={cur[cat]}
              previous={prev[cat]}
            />
          </div>
        ))}
      </div>

      {/* Legend */}
      <div className="mt-6 pt-5 border-t border-white/[0.06]">
        <div className="flex gap-4">
          <div className="flex items-center gap-1.5">
            <div className="w-4 h-1 bg-white/50 rounded-sm" />
            <span className="font-sans text-[11px] text-white/30">Now</span>
          </div>
          <div className="flex items-center gap-1.5">
            <div className="w-4 h-1 bg-white/20 rounded-sm" />
            <span className="font-sans text-[11px] text-white/30">Before</span>
          </div>
        </div>
      </div>
    </div>
  );
}
