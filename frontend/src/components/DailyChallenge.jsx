import { t } from "../i18n/index.js";

const DEFAULT_CHALLENGE = {
  id:          "offline_default",
  code:        "complete_eight_swipes",
  title:       "Daily Reflection",
  description: "Swipe 8 quotes with intention today.",
  target:      8,
};

function ProgressRing({ value, target, color = "#14B8A6" }) {
  const pct       = Math.min(1, value / Math.max(1, target));
  const radius    = 28;
  const stroke    = 4;
  const normalizedR = radius - stroke / 2;
  const circ      = 2 * Math.PI * normalizedR;
  const dash      = circ * pct;

  return (
    <svg width={radius * 2} height={radius * 2} style={{ transform: "rotate(-90deg)" }}>
      {/* Track */}
      <circle
        cx={radius} cy={radius} r={normalizedR}
        fill="none"
        stroke="rgba(255,255,255,0.06)"
        strokeWidth={stroke}
      />
      {/* Progress */}
      <circle
        cx={radius} cy={radius} r={normalizedR}
        fill="none"
        stroke={color}
        strokeWidth={stroke}
        strokeLinecap="round"
        strokeDasharray={`${dash} ${circ}`}
        style={{ transition: "stroke-dasharray 0.5s ease" }}
      />
    </svg>
  );
}

export default function DailyChallenge({ challenge, progress, lang = "en", onClose }) {
  const ch       = challenge || DEFAULT_CHALLENGE;
  const target   = ch.target ?? 8;
  const current  = progress?.progress ?? 0;
  const done     = progress?.completed ?? false;
  const pct      = Math.min(100, Math.round((current / Math.max(1, target)) * 100));

  const accentColor = done ? "#14B8A6" : "#F59E0B";

  return (
    <div
      style={{
        position: "fixed", inset: 0, zIndex: 300,
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
          background: "#18181f",
          borderRadius: "28px 28px 0 0",
          border: "1px solid rgba(255,255,255,0.07)",
          animation: "slide-up 0.3s cubic-bezier(0.34,1.56,0.64,1)",
          overflow: "hidden",
        }}
      >
        {/* Handle */}
        <div style={{ display: "flex", justifyContent: "center", padding: "16px 0 0" }}>
          <div style={{ width: 40, height: 4, borderRadius: 2, background: "rgba(255,255,255,0.15)" }} />
        </div>

        <div style={{ padding: "20px 28px 48px" }}>
          {/* Header row */}
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 28 }}>
            <div style={{ flex: 1 }}>
              <p style={{
                margin: "0 0 4px",
                fontFamily: "'DM Sans', sans-serif",
                fontSize: 11,
                fontWeight: 600,
                letterSpacing: "0.12em",
                textTransform: "uppercase",
                color: accentColor,
              }}>
                {t(lang, "challenge_title")}
              </p>
              <h2 style={{
                margin: 0,
                fontFamily: "'Playfair Display', serif",
                fontSize: 22,
                fontWeight: 600,
                color: "#F5F0E8",
              }}>
                {ch.title}
              </h2>
            </div>

            {/* Progress ring or checkmark */}
            <div style={{ flexShrink: 0, marginLeft: 16, display: "flex", alignItems: "center", justifyContent: "center" }}>
              {done ? (
                <div style={{
                  width: 56, height: 56,
                  background: "rgba(20,184,166,0.15)",
                  border: "2px solid rgba(20,184,166,0.5)",
                  borderRadius: "50%",
                  display: "flex", alignItems: "center", justifyContent: "center",
                  fontSize: 22,
                }}>
                  ✓
                </div>
              ) : (
                <div style={{ position: "relative", width: 56, height: 56, display: "flex", alignItems: "center", justifyContent: "center" }}>
                  <ProgressRing value={current} target={target} color={accentColor} />
                  <span style={{
                    position: "absolute",
                    fontFamily: "'DM Sans', sans-serif",
                    fontSize: 12,
                    fontWeight: 700,
                    color: accentColor,
                  }}>
                    {pct}%
                  </span>
                </div>
              )}
            </div>
          </div>

          {/* Description */}
          <p style={{
            margin: "0 0 24px",
            fontFamily: "'DM Sans', sans-serif",
            fontSize: 15,
            color: "rgba(255,255,255,0.55)",
            lineHeight: 1.65,
          }}>
            {ch.description}
          </p>

          {/* Progress bar */}
          <div style={{ marginBottom: 28 }}>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 8 }}>
              <span style={{ fontFamily: "'DM Sans', sans-serif", fontSize: 12, color: "rgba(255,255,255,0.3)" }}>
                Progress
              </span>
              <span style={{ fontFamily: "'DM Sans', sans-serif", fontSize: 12, fontWeight: 600, color: accentColor }}>
                {current} / {target}
              </span>
            </div>
            <div style={{ height: 6, borderRadius: 3, background: "rgba(255,255,255,0.06)", overflow: "hidden" }}>
              <div style={{
                height: "100%",
                width: `${pct}%`,
                background: done
                  ? "linear-gradient(90deg, #14B8A6cc, #14B8A6)"
                  : `linear-gradient(90deg, ${accentColor}cc, ${accentColor})`,
                borderRadius: 3,
                transition: "width 0.6s ease",
              }} />
            </div>
          </div>

          {/* Done message */}
          {done && (
            <div style={{
              background: "rgba(20,184,166,0.1)",
              border: "1px solid rgba(20,184,166,0.25)",
              borderRadius: 12,
              padding: "12px 16px",
              marginBottom: 20,
              fontFamily: "'DM Sans', sans-serif",
              fontSize: 13,
              color: "#14B8A6",
              textAlign: "center",
            }}>
              Challenge complete! Come back tomorrow for a new one.
            </div>
          )}

          {/* Close */}
          <button
            onClick={onClose}
            style={{
              width: "100%",
              padding: "14px",
              background: "rgba(255,255,255,0.04)",
              border: "1px solid rgba(255,255,255,0.08)",
              borderRadius: 14,
              fontSize: 14,
              fontFamily: "'DM Sans', sans-serif",
              fontWeight: 500,
              color: "rgba(255,255,255,0.4)",
              cursor: "pointer",
            }}
          >
            {t(lang, "close")}
          </button>
        </div>
      </div>
    </div>
  );
}
