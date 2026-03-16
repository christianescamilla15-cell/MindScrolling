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
    <div style={{ marginBottom: 20 }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
        <span style={{
          fontFamily: "'DM Sans', sans-serif",
          fontSize: 12,
          fontWeight: 600,
          letterSpacing: "0.08em",
          textTransform: "uppercase",
          color: color,
        }}>
          {label}
        </span>
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          {showDiff && diff !== null && diff !== 0 && (
            <span style={{
              fontFamily: "'DM Sans', sans-serif",
              fontSize: 11,
              color: diff > 0 ? "#14B8A6" : "#EF4444",
              fontWeight: 600,
            }}>
              {diff > 0 ? "+" : ""}{diff}%
            </span>
          )}
          <span style={{
            fontFamily: "'DM Sans', sans-serif",
            fontSize: 14,
            fontWeight: 600,
            color: "#F5F0E8",
          }}>
            {pct}%
          </span>
        </div>
      </div>

      {/* Current bar */}
      <div style={{
        height: 8, borderRadius: 4,
        background: "rgba(255,255,255,0.06)",
        overflow: "hidden",
        marginBottom: prevPct !== null && showDiff ? 4 : 0,
      }}>
        <div style={{
          height: "100%",
          width: `${pct}%`,
          background: `linear-gradient(90deg, ${color}cc, ${color})`,
          borderRadius: 4,
          transition: "width 0.8s cubic-bezier(0.34,1.56,0.64,1)",
        }} />
      </div>

      {/* Previous bar (snapshot comparison) */}
      {prevPct !== null && showDiff && (
        <div style={{
          height: 4, borderRadius: 2,
          background: "rgba(255,255,255,0.04)",
          overflow: "hidden",
        }}>
          <div style={{
            height: "100%",
            width: `${prevPct}%`,
            background: `${color}44`,
            borderRadius: 2,
          }} />
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
      style={{
        position: "fixed", inset: 0, zIndex: 200,
        background: "rgba(0,0,0,0.75)",
        display: "flex", alignItems: "flex-end",
        animation: "fade-in 0.2s ease",
      }}
      onClick={onClose}
    >
      <div
        onClick={e => e.stopPropagation()}
        style={{
          width: "100%",
          maxHeight: "82vh",
          background: "#18181f",
          borderRadius: "28px 28px 0 0",
          border: "1px solid rgba(255,255,255,0.07)",
          display: "flex",
          flexDirection: "column",
          animation: "slide-up 0.3s cubic-bezier(0.34,1.56,0.64,1)",
          overflow: "hidden",
        }}
      >
        {/* Handle */}
        <div style={{ display: "flex", justifyContent: "center", padding: "16px 0 0" }}>
          <div style={{ width: 40, height: 4, borderRadius: 2, background: "rgba(255,255,255,0.15)" }} />
        </div>

        {/* Header */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "16px 28px 0" }}>
          <div>
            <h2 style={{ margin: 0, fontFamily: "'Playfair Display', serif", fontSize: 22, fontWeight: 600, color: "#F5F0E8" }}>
              {t(lang, "map_title")}
            </h2>
            <p style={{ margin: "2px 0 0", fontFamily: "'DM Sans', sans-serif", fontSize: 12, color: "rgba(255,255,255,0.3)" }}>
              Your thinking profile
            </p>
          </div>
          <button
            onClick={onClose}
            style={{
              background: "none", border: "1px solid rgba(255,255,255,0.1)",
              borderRadius: 20, padding: "8px 14px",
              fontSize: 13, fontFamily: "'DM Sans', sans-serif",
              color: "rgba(255,255,255,0.3)", cursor: "pointer",
            }}
          >
            {t(lang, "close")}
          </button>
        </div>

        {/* Scrollable body */}
        <div style={{ overflowY: "auto", flex: 1, padding: "24px 28px 40px" }}>

          {/* Dominant style callout */}
          <div style={{
            background: `${CATEGORY_COLORS[dominant]}14`,
            border: `1px solid ${CATEGORY_COLORS[dominant]}33`,
            borderRadius: 16,
            padding: "16px 20px",
            marginBottom: 28,
            display: "flex",
            alignItems: "center",
            gap: 14,
          }}>
            <div style={{
              width: 12, height: 12, borderRadius: "50%",
              background: CATEGORY_COLORS[dominant],
              flexShrink: 0,
            }} />
            <div>
              <p style={{ margin: 0, fontFamily: "'DM Sans', sans-serif", fontSize: 12, color: "rgba(255,255,255,0.35)", marginBottom: 2 }}>
                Dominant style
              </p>
              <p style={{ margin: 0, fontFamily: "'Playfair Display', serif", fontSize: 16, color: CATEGORY_COLORS[dominant], fontWeight: 600 }}>
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
            <div style={{ marginTop: 8, display: "flex", alignItems: "center", gap: 12 }}>
              <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
                <div style={{ width: 20, height: 4, background: "rgba(255,255,255,0.5)", borderRadius: 2 }} />
                <span style={{ fontFamily: "'DM Sans', sans-serif", fontSize: 11, color: "rgba(255,255,255,0.3)" }}>Today</span>
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
                <div style={{ width: 20, height: 4, background: "rgba(255,255,255,0.2)", borderRadius: 2 }} />
                <span style={{ fontFamily: "'DM Sans', sans-serif", fontSize: 11, color: "rgba(255,255,255,0.3)" }}>
                  Snapshot {mapData?.snapshot_date ? `(${formatDate(mapData.snapshot_date)})` : ""}
                </span>
              </div>
            </div>
          )}

          {/* Empty state */}
          {!mapData && (
            <div style={{ textAlign: "center", padding: "20px 0", color: "rgba(255,255,255,0.25)", fontFamily: "'DM Sans', sans-serif", fontSize: 14 }}>
              Keep swiping to build your philosophy profile.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
