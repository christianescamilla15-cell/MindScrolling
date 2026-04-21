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
    <div style={{ flex: 1 }}>
      {/* Current bar */}
      <div style={{ height: 5, borderRadius: 3, background: "rgba(255,255,255,0.06)", marginBottom: 3, overflow: "hidden" }}>
        <div style={{
          height: "100%",
          width: `${curPct}%`,
          background: `linear-gradient(90deg, ${color}99, ${color})`,
          borderRadius: 3,
          transition: "width 0.6s ease",
        }} />
      </div>
      {/* Previous bar (ghost) */}
      <div style={{ height: 3, borderRadius: 2, background: "rgba(255,255,255,0.04)", overflow: "hidden" }}>
        <div style={{
          height: "100%",
          width: `${prevPct}%`,
          background: `${color}33`,
          borderRadius: 2,
        }} />
      </div>
      {/* Diff */}
      {diff !== 0 && (
        <p style={{
          margin: "4px 0 0",
          fontFamily: "'DM Sans', sans-serif",
          fontSize: 10,
          color: diff > 0 ? color : "rgba(255,255,255,0.25)",
          fontWeight: 600,
          textAlign: "center",
        }}>
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
    <div style={{
      position: "absolute", top: "50%", left: "50%",
      transform: "translate(-50%, -50%)",
      width: "min(380px, 90vw)",
      minHeight: 420,
      borderRadius: 28,
      background: "linear-gradient(145deg, #1c1c22, #161618)",
      border: "1px solid rgba(255,255,255,0.07)",
      boxShadow: "0 32px 80px rgba(0,0,0,0.6), 0 0 0 1px rgba(255,255,255,0.05)",
      display: "flex", flexDirection: "column",
      padding: "36px 32px 28px",
      boxSizing: "border-box",
      zIndex: 10,
      userSelect: "none",
    }}>
      {/* Header */}
      <div style={{ marginBottom: 28 }}>
        <p style={{
          margin: "0 0 4px",
          fontFamily: "'DM Sans', sans-serif",
          fontSize: 11,
          fontWeight: 600,
          letterSpacing: "0.12em",
          textTransform: "uppercase",
          color: CATEGORY_COLORS[biggest],
        }}>
          Philosophy Map
        </p>
        <h2 style={{
          margin: 0,
          fontFamily: "'Playfair Display', serif",
          fontSize: 22,
          fontWeight: 600,
          color: "#F5F0E8",
          fontStyle: "italic",
        }}>
          Your thinking is evolving.
        </h2>
      </div>

      {/* Bars */}
      <div style={{ flex: 1, display: "flex", flexDirection: "column", gap: 18, justifyContent: "center" }}>
        {categories.map(cat => (
          <div key={cat}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 6 }}>
              <span style={{
                fontFamily: "'DM Sans', sans-serif",
                fontSize: 11,
                fontWeight: 600,
                letterSpacing: "0.08em",
                textTransform: "uppercase",
                color: CATEGORY_COLORS[cat],
              }}>
                {CATEGORY_LABELS[cat]}
              </span>
              <span style={{
                fontFamily: "'DM Sans', sans-serif",
                fontSize: 13,
                fontWeight: 600,
                color: "#F5F0E8",
              }}>
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
      <div style={{ marginTop: 24, paddingTop: 20, borderTop: "1px solid rgba(255,255,255,0.06)" }}>
        <div style={{ display: "flex", gap: 16 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
            <div style={{ width: 16, height: 4, background: "rgba(255,255,255,0.5)", borderRadius: 2 }} />
            <span style={{ fontFamily: "'DM Sans', sans-serif", fontSize: 11, color: "rgba(255,255,255,0.3)" }}>Now</span>
          </div>
          <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
            <div style={{ width: 16, height: 4, background: "rgba(255,255,255,0.2)", borderRadius: 2 }} />
            <span style={{ fontFamily: "'DM Sans', sans-serif", fontSize: 11, color: "rgba(255,255,255,0.3)" }}>Before</span>
          </div>
        </div>
      </div>
    </div>
  );
}
