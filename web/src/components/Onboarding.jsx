import { useState } from "react";
import { apiSaveProfile } from "../api/quotes.js";
import { t } from "../i18n/index.js";

const ONBOARDING_KEY = "mindscroll_onboarding";
const PROFILE_KEY    = "mindscroll_profile";

const selectStyle = {
  width: "100%",
  background: "#1e1e27",
  border: "1px solid rgba(255,255,255,0.12)",
  borderRadius: 12,
  color: "#F5F0E8",
  fontFamily: "'DM Sans', sans-serif",
  fontSize: 14,
  padding: "12px 16px",
  appearance: "none",
  WebkitAppearance: "none",
  cursor: "pointer",
  outline: "none",
};

const labelStyle = {
  fontFamily: "'DM Sans', sans-serif",
  fontSize: 12,
  fontWeight: 600,
  letterSpacing: "0.08em",
  textTransform: "uppercase",
  color: "rgba(255,255,255,0.4)",
  marginBottom: 6,
  display: "block",
};

const primaryBtn = (color = "#14B8A6") => ({
  width: "100%",
  padding: "16px",
  background: `linear-gradient(135deg, ${color}22, ${color}44)`,
  border: `1px solid ${color}66`,
  borderRadius: 16,
  color: color,
  fontFamily: "'DM Sans', sans-serif",
  fontSize: 15,
  fontWeight: 600,
  cursor: "pointer",
  letterSpacing: "0.04em",
  transition: "all 0.2s",
});

/* ─── Screen 1: Swipe explanation ─────────────────────────────────────────── */
function ScreenSwipes({ lang, onNext }) {
  const directions = [
    { key: "onboarding_swipe_up",    color: "#F59E0B", icon: "↑", label: t(lang, "philosophy") },
    { key: "onboarding_swipe_right", color: "#F97316", icon: "→", label: t(lang, "discipline") },
    { key: "onboarding_swipe_left",  color: "#14B8A6", icon: "←", label: t(lang, "stoicism")   },
    { key: "onboarding_swipe_down",  color: "#A78BFA", icon: "↓", label: t(lang, "reflection") },
  ];

  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", flex: 1, padding: "48px 32px 32px" }}>
      {/* Logo */}
      <h1 style={{ margin: "0 0 8px", fontFamily: "'Playfair Display', serif", fontSize: 32, fontWeight: 600, color: "#F5F0E8", letterSpacing: "-0.02em" }}>
        Mind<span style={{ color: "#14B8A6" }}>Scroll</span>
      </h1>
      <p style={{ margin: "0 0 48px", fontFamily: "'DM Sans', sans-serif", fontSize: 14, color: "rgba(255,255,255,0.4)", textAlign: "center" }}>
        {t(lang, "onboarding_subtitle")}
      </p>

      {/* Direction grid */}
      <div style={{ width: "100%", maxWidth: 320, display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, marginBottom: 40 }}>
        {directions.map(d => (
          <div key={d.key} style={{
            background: `${d.color}11`,
            border: `1px solid ${d.color}33`,
            borderRadius: 16,
            padding: "20px 16px",
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            gap: 8,
            animation: "hint-pulse 2.5s ease-in-out infinite",
          }}>
            <span style={{ fontSize: 28, color: d.color, lineHeight: 1 }}>{d.icon}</span>
            <span style={{ fontFamily: "'DM Sans', sans-serif", fontSize: 11, fontWeight: 600, letterSpacing: "0.1em", textTransform: "uppercase", color: d.color }}>{d.label}</span>
            <span style={{ fontFamily: "'DM Sans', sans-serif", fontSize: 12, color: "rgba(255,255,255,0.5)", textAlign: "center" }}>{t(lang, d.key)}</span>
          </div>
        ))}
      </div>

      {/* Swipe graphic hint */}
      <div style={{ marginBottom: 40, display: "flex", flexDirection: "column", alignItems: "center", gap: 6 }}>
        <div style={{
          width: 60, height: 60,
          background: "linear-gradient(145deg, #1c1c22, #161618)",
          border: "1px solid rgba(255,255,255,0.08)",
          borderRadius: 18,
          display: "flex", alignItems: "center", justifyContent: "center",
          fontSize: 24,
        }}>
          ✦
        </div>
        <p style={{ margin: 0, fontFamily: "'DM Sans', sans-serif", fontSize: 11, color: "rgba(255,255,255,0.25)", letterSpacing: "0.08em", textTransform: "uppercase" }}>
          swipe the card
        </p>
      </div>

      <button onClick={onNext} style={primaryBtn("#14B8A6")}>
        {t(lang, "onboarding_next")} →
      </button>
    </div>
  );
}

/* ─── Screen 2: Profile collection ───────────────────────────────────────── */
function ScreenProfile({ lang, onComplete }) {
  const [profile, setProfile] = useState({
    age_range:          "",
    interest:           "",
    goal:               "",
    preferred_language: lang || "en",
  });

  const set = (key, val) => setProfile(prev => ({ ...prev, [key]: val }));

  const handleSubmit = () => {
    // Fill defaults if empty
    const finalProfile = {
      age_range:          profile.age_range          || "25-34",
      interest:           profile.interest           || "philosophy",
      goal:               profile.goal               || "meaning",
      preferred_language: profile.preferred_language || "en",
    };
    onComplete(finalProfile);
  };

  return (
    <div style={{ display: "flex", flexDirection: "column", flex: 1, padding: "48px 32px 32px" }}>
      <h2 style={{ margin: "0 0 8px", fontFamily: "'Playfair Display', serif", fontSize: 26, fontWeight: 600, color: "#F5F0E8" }}>
        {t(lang, "onboarding_profile")}
      </h2>
      <p style={{ margin: "0 0 36px", fontFamily: "'DM Sans', sans-serif", fontSize: 14, color: "rgba(255,255,255,0.4)" }}>
        {t(lang, "onboarding_subtitle")}
      </p>

      <div style={{ display: "flex", flexDirection: "column", gap: 20, flex: 1 }}>
        {/* Age range */}
        <div>
          <label style={labelStyle}>{t(lang, "age_range")}</label>
          <div style={{ position: "relative" }}>
            <select value={profile.age_range} onChange={e => set("age_range", e.target.value)} style={selectStyle}>
              <option value="">—</option>
              <option value="18-24">18–24</option>
              <option value="25-34">25–34</option>
              <option value="35-44">35–44</option>
              <option value="45+">45+</option>
            </select>
            <span style={{ position: "absolute", right: 14, top: "50%", transform: "translateY(-50%)", color: "rgba(255,255,255,0.3)", pointerEvents: "none" }}>▾</span>
          </div>
        </div>

        {/* Interest */}
        <div>
          <label style={labelStyle}>{t(lang, "interest")}</label>
          <div style={{ position: "relative" }}>
            <select value={profile.interest} onChange={e => set("interest", e.target.value)} style={selectStyle}>
              <option value="">—</option>
              <option value="philosophy">Philosophy</option>
              <option value="stoicism">Stoicism</option>
              <option value="personal_growth">Personal Growth</option>
              <option value="mindfulness">Mindfulness</option>
              <option value="curiosity">Curiosity</option>
            </select>
            <span style={{ position: "absolute", right: 14, top: "50%", transform: "translateY(-50%)", color: "rgba(255,255,255,0.3)", pointerEvents: "none" }}>▾</span>
          </div>
        </div>

        {/* Goal */}
        <div>
          <label style={labelStyle}>{t(lang, "goal")}</label>
          <div style={{ position: "relative" }}>
            <select value={profile.goal} onChange={e => set("goal", e.target.value)} style={selectStyle}>
              <option value="">—</option>
              <option value="calm_mind">Calm Mind</option>
              <option value="discipline">Discipline</option>
              <option value="meaning">Meaning</option>
              <option value="emotional_clarity">Emotional Clarity</option>
            </select>
            <span style={{ position: "absolute", right: 14, top: "50%", transform: "translateY(-50%)", color: "rgba(255,255,255,0.3)", pointerEvents: "none" }}>▾</span>
          </div>
        </div>

        {/* Language */}
        <div>
          <label style={labelStyle}>{t(lang, "language")}</label>
          <div style={{ position: "relative" }}>
            <select value={profile.preferred_language} onChange={e => set("preferred_language", e.target.value)} style={selectStyle}>
              <option value="en">English</option>
              <option value="es">Espa&ntilde;ol</option>
            </select>
            <span style={{ position: "absolute", right: 14, top: "50%", transform: "translateY(-50%)", color: "rgba(255,255,255,0.3)", pointerEvents: "none" }}>▾</span>
          </div>
        </div>
      </div>

      <div style={{ marginTop: 32 }}>
        <button onClick={handleSubmit} style={primaryBtn("#14B8A6")}>
          {t(lang, "onboarding_start")} ✦
        </button>
      </div>
    </div>
  );
}

/* ─── Screen 3: All set ───────────────────────────────────────────────────── */
function ScreenReady({ lang, onGo }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", flex: 1, padding: "48px 32px 32px", textAlign: "center" }}>
      <div style={{ fontSize: 64, marginBottom: 24 }}>✦</div>
      <h2 style={{ margin: "0 0 12px", fontFamily: "'Playfair Display', serif", fontSize: 28, fontWeight: 600, color: "#F5F0E8" }}>
        You&apos;re all set.
      </h2>
      <p style={{ margin: "0 0 48px", fontFamily: "'DM Sans', sans-serif", fontSize: 15, color: "rgba(255,255,255,0.5)", lineHeight: 1.6 }}>
        Start scrolling through wisdom.
      </p>
      <button onClick={onGo} style={{ ...primaryBtn("#14B8A6"), maxWidth: 280 }}>
        Let&apos;s go →
      </button>
    </div>
  );
}

/* ─── Main Onboarding component ───────────────────────────────────────────── */
export default function Onboarding({ onComplete, lang = "en" }) {
  const [screen, setScreen] = useState(0);
  const [profile, setProfile] = useState(null);

  const handleProfileComplete = (prof) => {
    setProfile(prof);
    setScreen(2);
  };

  const handleGo = () => {
    const finalProfile = profile || {
      age_range: "25-34",
      interest: "philosophy",
      goal: "meaning",
      preferred_language: lang,
    };
    // Persist onboarding completion
    try {
      localStorage.setItem(ONBOARDING_KEY, "true");
      localStorage.setItem(PROFILE_KEY, JSON.stringify(finalProfile));
    } catch (_) {}
    // Fire-and-forget API save
    apiSaveProfile(finalProfile).catch(() => {});
    onComplete(finalProfile);
  };

  return (
    <div style={{
      position: "fixed", inset: 0, zIndex: 500,
      background: "#0f0f13",
      display: "flex", flexDirection: "column",
      animation: "fade-in 0.3s ease",
    }}>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;600&family=DM+Sans:wght@400;500;600&display=swap');
        @keyframes fade-in { from { opacity:0 } to { opacity:1 } }
        @keyframes hint-pulse { 0%,100%{opacity:0.7} 50%{opacity:1} }
        * { box-sizing:border-box; }
        select option { background:#1e1e27; color:#F5F0E8; }
      `}</style>

      {/* Progress dots */}
      <div style={{ display: "flex", justifyContent: "center", gap: 8, padding: "20px 0 0" }}>
        {[0, 1, 2].map(i => (
          <div key={i} style={{
            width: i === screen ? 20 : 8,
            height: 8,
            borderRadius: 4,
            background: i === screen ? "#14B8A6" : "rgba(255,255,255,0.12)",
            transition: "all 0.3s ease",
          }} />
        ))}
      </div>

      {screen === 0 && <ScreenSwipes lang={lang} onNext={() => setScreen(1)} />}
      {screen === 1 && <ScreenProfile lang={lang} onComplete={handleProfileComplete} />}
      {screen === 2 && <ScreenReady lang={lang} onGo={handleGo} />}
    </div>
  );
}
