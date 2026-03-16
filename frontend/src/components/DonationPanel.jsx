import { t } from "../i18n/index.js";

const FALLBACK_URL = "#";

export default function DonationPanel({ lang = "en", onClose }) {
  const donationUrl = (typeof import.meta !== "undefined" && import.meta.env && import.meta.env.VITE_DONATION_LINK)
    ? import.meta.env.VITE_DONATION_LINK
    : FALLBACK_URL;

  const handleCoffee = () => {
    if (donationUrl !== "#") {
      window.open(donationUrl, "_blank", "noopener,noreferrer");
    }
  };

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

        <div style={{ padding: "24px 32px 48px", display: "flex", flexDirection: "column", alignItems: "center", textAlign: "center" }}>
          {/* Amber accent icon */}
          <div style={{
            width: 72, height: 72,
            background: "linear-gradient(135deg, rgba(245,158,11,0.15), rgba(249,115,22,0.15))",
            border: "1px solid rgba(245,158,11,0.25)",
            borderRadius: 24,
            display: "flex", alignItems: "center", justifyContent: "center",
            fontSize: 32,
            marginBottom: 20,
          }}>
            &#x2615;
          </div>

          <h2 style={{
            margin: "0 0 12px",
            fontFamily: "'Playfair Display', serif",
            fontSize: 22,
            fontWeight: 600,
            color: "#F5F0E8",
          }}>
            {t(lang, "donate_title")}
          </h2>

          <p style={{
            margin: "0 0 32px",
            fontFamily: "'DM Sans', sans-serif",
            fontSize: 14,
            color: "rgba(255,255,255,0.5)",
            lineHeight: 1.7,
            maxWidth: 300,
          }}>
            {t(lang, "donate_body")}
          </p>

          {/* Coffee button */}
          <button
            onClick={handleCoffee}
            style={{
              width: "100%",
              maxWidth: 320,
              padding: "16px",
              background: "linear-gradient(135deg, rgba(245,158,11,0.18), rgba(249,115,22,0.18))",
              border: "1px solid rgba(245,158,11,0.4)",
              borderRadius: 16,
              color: "#F59E0B",
              fontFamily: "'DM Sans', sans-serif",
              fontSize: 15,
              fontWeight: 600,
              cursor: "pointer",
              letterSpacing: "0.03em",
              transition: "all 0.2s",
              marginBottom: 16,
            }}
          >
            {t(lang, "donate_btn")}
          </button>

          {/* Close button */}
          <button
            onClick={onClose}
            style={{
              background: "none",
              border: "1px solid rgba(255,255,255,0.1)",
              borderRadius: 12,
              padding: "10px 24px",
              fontSize: 13,
              fontFamily: "'DM Sans', sans-serif",
              color: "rgba(255,255,255,0.3)",
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
