import { t } from "../i18n/index.js";

const APP_VERSION = "1.0.0";

const rowStyle = {
  display: "flex",
  justifyContent: "space-between",
  alignItems: "center",
  padding: "16px 0",
  borderBottom: "1px solid rgba(255,255,255,0.06)",
  cursor: "pointer",
};

const rowLabelStyle = {
  fontFamily: "'DM Sans', sans-serif",
  fontSize: 15,
  fontWeight: 500,
  color: "#F5F0E8",
};

const rowSubStyle = {
  fontFamily: "'DM Sans', sans-serif",
  fontSize: 12,
  color: "rgba(255,255,255,0.3)",
  marginTop: 2,
};

const chevron = (color = "rgba(255,255,255,0.25)") => (
  <span style={{ fontSize: 16, color, lineHeight: 1 }}>›</span>
);

const sectionHeader = (label) => (
  <p style={{
    margin: "24px 0 4px",
    fontFamily: "'DM Sans', sans-serif",
    fontSize: 11,
    fontWeight: 600,
    letterSpacing: "0.12em",
    textTransform: "uppercase",
    color: "rgba(255,255,255,0.25)",
  }}>{label}</p>
);

export default function Settings({ lang, onLangChange, isPremium, onClose, showToast, onShowMap, onShowChallenge, onShowDonation }) {
  return (
    <div
      style={{
        position: "fixed", inset: 0, zIndex: 200,
        background: "rgba(0,0,0,0.7)",
        display: "flex", alignItems: "flex-end",
        animation: "fade-in 0.2s ease",
      }}
      onClick={onClose}
    >
      <div
        onClick={e => e.stopPropagation()}
        style={{
          width: "100%",
          maxHeight: "86vh",
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
          <h2 style={{ margin: 0, fontFamily: "'Playfair Display', serif", fontSize: 22, fontWeight: 600, color: "#F5F0E8" }}>
            {t(lang, "settings")}
          </h2>
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
        <div style={{ overflowY: "auto", flex: 1, padding: "0 28px 40px" }}>

          {/* Language */}
          {sectionHeader("Preferences")}
          <div style={rowStyle}>
            <div>
              <p style={rowLabelStyle}>{t(lang, "language")}</p>
              <p style={rowSubStyle}>{lang === "es" ? "Espa\u00F1ol" : "English"}</p>
            </div>
            <div style={{ display: "flex", gap: 8 }}>
              {["en", "es"].map(code => (
                <button
                  key={code}
                  onClick={() => onLangChange(code)}
                  style={{
                    background: lang === code ? "rgba(20,184,166,0.15)" : "rgba(255,255,255,0.05)",
                    border: `1px solid ${lang === code ? "rgba(20,184,166,0.4)" : "rgba(255,255,255,0.1)"}`,
                    borderRadius: 10,
                    padding: "6px 12px",
                    fontSize: 13,
                    fontFamily: "'DM Sans', sans-serif",
                    fontWeight: 600,
                    color: lang === code ? "#14B8A6" : "rgba(255,255,255,0.4)",
                    cursor: "pointer",
                    transition: "all 0.15s",
                  }}
                >
                  {code.toUpperCase()}
                </button>
              ))}
            </div>
          </div>

          {/* Explore */}
          {sectionHeader("Explore")}

          <div style={{ ...rowStyle, cursor: "pointer" }} onClick={onShowMap}>
            <div>
              <p style={rowLabelStyle}>{t(lang, "map_title")}</p>
              <p style={rowSubStyle}>Visualize your thinking style</p>
            </div>
            {chevron("#A78BFA")}
          </div>

          <div style={{ ...rowStyle, cursor: "pointer" }} onClick={onShowChallenge}>
            <div>
              <p style={rowLabelStyle}>{t(lang, "challenge_title")}</p>
              <p style={rowSubStyle}>Today&apos;s reflection challenge</p>
            </div>
            {chevron("#F59E0B")}
          </div>

          {/* Premium */}
          {sectionHeader("Premium")}

          {!isPremium ? (
            <div
              style={{
                ...rowStyle,
                background: "linear-gradient(135deg, rgba(249,115,22,0.08), rgba(245,158,11,0.08))",
                border: "1px solid rgba(249,115,22,0.2)",
                borderRadius: 16,
                padding: "16px",
                marginBottom: 12,
                cursor: "pointer",
              }}
              onClick={() => showToast && showToast("Premium coming soon!", "#F97316")}
            >
              <div>
                <p style={{ ...rowLabelStyle, color: "#F97316" }}>{t(lang, "premium_unlock")}</p>
                <p style={rowSubStyle}>Export images, unlock all packs</p>
              </div>
              <span style={{ fontFamily: "'DM Sans', sans-serif", fontSize: 15, fontWeight: 700, color: "#F59E0B" }}>
                {t(lang, "premium_price")}
              </span>
            </div>
          ) : (
            <div style={{ ...rowStyle, cursor: "default" }}>
              <div>
                <p style={{ ...rowLabelStyle, color: "#14B8A6" }}>Premium Active</p>
                <p style={rowSubStyle}>All features unlocked</p>
              </div>
              <span style={{ fontSize: 18 }}>✦</span>
            </div>
          )}

          {/* Donation */}
          <div style={{ ...rowStyle, cursor: "pointer" }} onClick={onShowDonation}>
            <div>
              <p style={rowLabelStyle}>{t(lang, "donate_title")}</p>
              <p style={rowSubStyle}>Support the project</p>
            </div>
            {chevron("#F59E0B")}
          </div>

          {/* About */}
          {sectionHeader("About")}
          <div style={{ padding: "16px 0" }}>
            <p style={{ margin: "0 0 4px", fontFamily: "'Playfair Display', serif", fontSize: 16, color: "#F5F0E8" }}>
              Mind<span style={{ color: "#14B8A6" }}>Scroll</span>
            </p>
            <p style={{ margin: "0 0 8px", fontFamily: "'DM Sans', sans-serif", fontSize: 12, color: "rgba(255,255,255,0.3)" }}>
              Version {APP_VERSION}
            </p>
            <p style={{ margin: 0, fontFamily: "'DM Sans', sans-serif", fontSize: 13, color: "rgba(255,255,255,0.35)", lineHeight: 1.6 }}>
              Philosophical wisdom for your daily mind. Swipe, reflect, grow.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
