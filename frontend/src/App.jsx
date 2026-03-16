import { useState, useEffect, useRef, useCallback, useMemo } from "react";
import {
  fetchQuotes,
  shareQuote,
  apiLike,
  apiSaveVault,
  apiRemoveVault,
  apiRecordSwipe,
  apiGetTodayChallenge,
  apiUpdateChallengeProgress,
  apiGetMap,
  apiGetPremiumStatus,
} from "./api/quotes.js";
import { saveState, loadState } from "./utils/storage.js";
import { shuffle } from "./utils/shuffle.js";
import { CATEGORY_META, DIR_TO_CATEGORY, USER_LANG } from "./constants/index.js";
import { t } from "./i18n/index.js";
import { exportQuoteImage } from "./utils/exportImage.js";
import Onboarding    from "./components/Onboarding.jsx";
import Settings      from "./components/Settings.jsx";
import DonationPanel from "./components/DonationPanel.jsx";
import PhilosophyMap from "./components/PhilosophyMap.jsx";
import DailyChallenge from "./components/DailyChallenge.jsx";

/* ─── ICONS ──────────────────────────────────────────────────────────────────── */
const HeartIcon = ({ filled, size = 20 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={filled ? "#F97316" : "none"} stroke={filled ? "#F97316" : "currentColor"} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
    <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
  </svg>
);
const BookmarkIcon = ({ filled, size = 20 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={filled ? "#14B8A6" : "none"} stroke={filled ? "#14B8A6" : "currentColor"} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
    <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>
  </svg>
);
const FireIcon = ({ size = 18 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="#F59E0B" stroke="none">
    <path d="M12 2C9 7 6 9 6 14a6 6 0 0 0 12 0c0-5-3-7-6-12zm0 18a4 4 0 0 1-4-4c0-3 2-5 4-9 2 4 4 6 4 9a4 4 0 0 1-4 4z"/>
    <ellipse cx="12" cy="17" rx="2" ry="2.5" fill="#FDE68A" opacity="0.8"/>
  </svg>
);
const XIcon = ({ size = 18 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
    <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
  </svg>
);
const ShareIcon = ({ size = 18 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
    <circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/>
    <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>
  </svg>
);
const GearIcon = ({ size = 18 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
    <circle cx="12" cy="12" r="3"/>
    <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>
  </svg>
);
const ImageIcon = ({ size = 18 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
    <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
    <circle cx="8.5" cy="8.5" r="1.5"/>
    <polyline points="21 15 16 10 5 21"/>
  </svg>
);
const LockIcon = ({ size = 18 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
    <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
  </svg>
);

const actionBtn = (color) => ({
  background: "none", border: "none", cursor: "pointer",
  color, padding: 8, borderRadius: 12,
  display: "flex", alignItems: "center", justifyContent: "center",
  transition: "transform 0.15s, opacity 0.15s",
});

/* ─── PARTICLE BURST ─────────────────────────────────────────────────────────── */
function ParticleBurst({ x, y, onDone }) {
  const particles = useMemo(() => Array.from({ length: 10 }, (_, i) => ({
    id: i, angle: (i / 10) * 360,
    dist: 30 + Math.random() * 25, size: 4 + Math.random() * 4,
    color: ["#F97316","#F59E0B","#EF4444","#EC4899","#FBBF24"][i % 5],
  })), []);

  useEffect(() => { const tm = setTimeout(onDone, 700); return () => clearTimeout(tm); }, [onDone]);

  return (
    <div style={{ position: "fixed", left: x, top: y, pointerEvents: "none", zIndex: 9999 }}>
      {particles.map(p => {
        const rad = (p.angle * Math.PI) / 180;
        return (
          <div key={p.id} style={{
            position: "absolute", width: p.size, height: p.size,
            borderRadius: "50%", background: p.color,
            transform: "translate(-50%,-50%)",
            animation: "particle-burst 0.6s ease-out forwards",
            "--tx": `${Math.cos(rad) * p.dist}px`,
            "--ty": `${Math.sin(rad) * p.dist}px`,
          }}/>
        );
      })}
    </div>
  );
}

/* ─── SWIPE HINTS ────────────────────────────────────────────────────────────── */
function SwipeHints() {
  return (
    <>
      {[
        { label: "Philosophy", color: "#F59E0B", style: { top: 16, left: "50%", transform: "translateX(-50%)" } },
        { label: "Reflection", color: "#A78BFA", style: { bottom: 100, left: "50%", transform: "translateX(-50%)" } },
        { label: "Stoicism",   color: "#14B8A6", style: { left: 12, top: "50%", transform: "translateY(-50%)" } },
        { label: "Discipline", color: "#F97316", style: { right: 12, top: "50%", transform: "translateY(-50%)" } },
      ].map(h => (
        <div key={h.label} style={{
          position: "absolute", ...h.style,
          fontFamily: "'DM Sans', sans-serif", fontSize: 10, fontWeight: 600,
          letterSpacing: "0.12em", textTransform: "uppercase",
          color: h.color, opacity: 0.35,
          animation: "hint-pulse 2.5s ease-in-out infinite",
          pointerEvents: "none", zIndex: 5,
        }}>{h.label}</div>
      ))}
    </>
  );
}

/* ─── QUOTE CARD ─────────────────────────────────────────────────────────────── */
function QuoteCard({ quote, onSwipe, onLike, onSave, onShare, onExport, isLiked, isSaved, swipeHint, isPremium, lang }) {
  const cardRef   = useRef(null);
  const dragStart = useRef(null);
  const tapTimer  = useRef(null);
  const [dragging, setDragging] = useState(false);
  const [offset,   setOffset]   = useState({ x: 0, y: 0 });
  const [flyDir,   setFlyDir]   = useState(null);
  const [tapCount, setTapCount] = useState(0);
  const [burst,    setBurst]    = useState(null);
  const meta = CATEGORY_META[quote.category];

  const getDir = (dx, dy) =>
    Math.abs(dx) > Math.abs(dy) ? (dx > 0 ? "right" : "left") : (dy > 0 ? "down" : "up");

  const startDrag = (cx, cy) => { dragStart.current = { x: cx, y: cy }; setDragging(true); };
  const moveDrag  = (cx, cy) => {
    if (!dragStart.current || flyDir) return;
    setOffset({ x: cx - dragStart.current.x, y: cy - dragStart.current.y });
  };
  const endDrag = (cx, cy) => {
    if (!dragStart.current) return;
    const dx = cx - dragStart.current.x, dy = cy - dragStart.current.y;
    dragStart.current = null;
    setDragging(false);
    if (Math.sqrt(dx * dx + dy * dy) > 80) {
      const dir = getDir(dx, dy);
      setFlyDir(dir);
      setTimeout(() => { setFlyDir(null); setOffset({ x: 0, y: 0 }); onSwipe(dir); }, 350);
    } else {
      setOffset({ x: 0, y: 0 });
    }
  };

  const handleTap = () => {
    const next = tapCount + 1;
    setTapCount(next);
    clearTimeout(tapTimer.current);
    if (next >= 2) {
      const rect = cardRef.current?.getBoundingClientRect();
      setBurst({ x: (rect?.left || 0) + (rect?.width || 0) / 2, y: (rect?.top || 0) + (rect?.height || 0) / 2 });
      onLike(quote.id);
      setTapCount(0);
    } else {
      tapTimer.current = setTimeout(() => setTapCount(0), 300);
    }
  };

  const flyTransform = flyDir ? {
    up:    "translate(-50%, calc(-50% - 120vh)) rotate(-8deg)",
    down:  "translate(-50%, calc(-50% + 120vh)) rotate(5deg)",
    left:  "translate(calc(-50% - 120vw), -50%) rotate(-15deg)",
    right: "translate(calc(50vw + 50%), -50%) rotate(15deg)",
  }[flyDir] : null;

  const edgeColor = offset.x > 40 ? "#F97316" : offset.x < -40 ? "#14B8A6" : offset.y < -40 ? "#F59E0B" : offset.y > 40 ? "#A78BFA" : "transparent";
  const edgeGlow  = Math.min(1, Math.sqrt(offset.x ** 2 + offset.y ** 2) / 120);

  return (
    <>
      {burst && <ParticleBurst x={burst.x} y={burst.y} onDone={() => setBurst(null)} />}
      <div
        ref={cardRef}
        onMouseDown={e => startDrag(e.clientX, e.clientY)}
        onMouseMove={e => dragging && moveDrag(e.clientX, e.clientY)}
        onMouseUp={e => endDrag(e.clientX, e.clientY)}
        onMouseLeave={e => { if (dragging) endDrag(e.clientX, e.clientY); }}
        onTouchStart={e => startDrag(e.touches[0].clientX, e.touches[0].clientY)}
        onTouchMove={e => moveDrag(e.touches[0].clientX, e.touches[0].clientY)}
        onTouchEnd={e => endDrag(e.changedTouches[0].clientX, e.changedTouches[0].clientY)}
        onClick={handleTap}
        style={{
          position: "absolute", top: "50%", left: "50%",
          width: "min(380px, 90vw)", minHeight: 420,
          transform: flyTransform || `translate(-50%, -50%) translate(${offset.x}px, ${offset.y}px) rotate(${offset.x / 20}deg)`,
          transition: flyDir ? "transform 0.35s cubic-bezier(0.4,0,1,1), opacity 0.35s" : dragging ? "none" : "transform 0.4s cubic-bezier(0.34,1.56,0.64,1)",
          opacity: flyDir ? 0 : Math.max(0.6, 1 - Math.sqrt(offset.x ** 2 + offset.y ** 2) / 400),
          cursor: dragging ? "grabbing" : "grab", userSelect: "none", zIndex: 10,
          borderRadius: 28, background: "linear-gradient(145deg, #1c1c22, #161618)",
          border: "1px solid rgba(255,255,255,0.07)",
          boxShadow: edgeColor !== "transparent"
            ? `0 0 0 2px ${edgeColor}${Math.round(edgeGlow * 255).toString(16).padStart(2,"0")}, 0 32px 80px rgba(0,0,0,0.6)`
            : "0 32px 80px rgba(0,0,0,0.6), 0 0 0 1px rgba(255,255,255,0.05)",
          display: "flex", flexDirection: "column", padding: "36px 32px 28px", boxSizing: "border-box",
        }}
      >
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 32 }}>
          <span style={{ fontSize: 11, fontFamily: "'DM Sans', sans-serif", fontWeight: 600, letterSpacing: "0.12em", textTransform: "uppercase", color: meta.color, background: meta.bg, padding: "5px 12px", borderRadius: 20 }}>
            {meta.label}
          </span>
          <span style={{ fontSize: 11, color: "rgba(255,255,255,0.25)", fontFamily: "'DM Sans', sans-serif" }}>
            {meta.dir}
          </span>
        </div>

        <div style={{ flex: 1, display: "flex", alignItems: "center" }}>
          <blockquote style={{ margin: 0, padding: 0, fontFamily: "'Playfair Display', Georgia, serif", fontSize: "clamp(18px, 4vw, 24px)", fontWeight: 400, fontStyle: "italic", lineHeight: 1.65, color: "#F5F0E8", letterSpacing: "-0.01em" }}>
            <span style={{ color: meta.color, fontSize: "2em", lineHeight: 0.3, verticalAlign: "-0.3em", marginRight: 4, fontStyle: "normal" }}>&ldquo;</span>
            {quote.text}
            <span style={{ color: meta.color, fontSize: "2em", lineHeight: 0.3, verticalAlign: "-0.3em", marginLeft: 4, fontStyle: "normal" }}>&rdquo;</span>
          </blockquote>
        </div>

        <div style={{ marginTop: 28, marginBottom: 24 }}>
          <div style={{ width: 32, height: 1, background: meta.color, opacity: 0.5, marginBottom: 10 }} />
          <p style={{ margin: 0, fontFamily: "'DM Sans', sans-serif", fontSize: 13, fontWeight: 500, color: "rgba(255,255,255,0.45)", letterSpacing: "0.05em" }}>
            &mdash; {quote.author}
          </p>
        </div>

        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", paddingTop: 20, borderTop: "1px solid rgba(255,255,255,0.06)" }}>
          <button onClick={e => { e.stopPropagation(); onLike(quote.id); }} style={actionBtn(isLiked ? "#F97316" : "rgba(255,255,255,0.2)")}>
            <HeartIcon filled={isLiked} size={19} />
          </button>
          <p style={{ margin: 0, fontFamily: "'DM Sans', sans-serif", fontSize: 11, color: "rgba(255,255,255,0.18)", letterSpacing: "0.08em" }}>
            {t(lang, "double_tap")}
          </p>
          <div style={{ display: "flex", gap: 8 }}>
            {/* Export image — premium gated */}
            <button
              onClick={e => { e.stopPropagation(); onExport(quote); }}
              style={actionBtn(isPremium ? "rgba(255,255,255,0.2)" : "rgba(255,255,255,0.1)")}
              title={isPremium ? t(lang, "export_image") : t(lang, "premium_feature")}
            >
              {isPremium ? <ImageIcon size={19} /> : <LockIcon size={17} />}
            </button>
            <button onClick={e => { e.stopPropagation(); onSave(quote); }} style={actionBtn(isSaved ? "#14B8A6" : "rgba(255,255,255,0.2)")}>
              <BookmarkIcon filled={isSaved} size={19} />
            </button>
            <button onClick={e => { e.stopPropagation(); onShare(quote); }} style={actionBtn("rgba(255,255,255,0.2)")}>
              <ShareIcon size={19} />
            </button>
          </div>
        </div>
      </div>
      {swipeHint && !dragging && !flyDir && <SwipeHints />}
    </>
  );
}

/* ─── VAULT SHEET ────────────────────────────────────────────────────────────── */
function VaultSheet({ items, onClose, onRemove, lang }) {
  return (
    <div style={{ position: "fixed", inset: 0, zIndex: 100, background: "rgba(0,0,0,0.7)", display: "flex", alignItems: "flex-end", animation: "fade-in 0.2s ease" }} onClick={onClose}>
      <div onClick={e => e.stopPropagation()} style={{ width: "100%", maxHeight: "78vh", background: "#18181f", borderRadius: "28px 28px 0 0", border: "1px solid rgba(255,255,255,0.07)", display: "flex", flexDirection: "column", animation: "slide-up 0.3s cubic-bezier(0.34,1.56,0.64,1)", overflow: "hidden" }}>
        <div style={{ display: "flex", justifyContent: "center", padding: "16px 0 0" }}>
          <div style={{ width: 40, height: 4, borderRadius: 2, background: "rgba(255,255,255,0.15)" }} />
        </div>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "16px 28px 12px" }}>
          <div>
            <h2 style={{ margin: 0, fontFamily: "'Playfair Display', serif", fontSize: 22, fontWeight: 600, color: "#F5F0E8" }}>{t(lang, "vault")}</h2>
            <p style={{ margin: "2px 0 0", fontFamily: "'DM Sans', sans-serif", fontSize: 12, color: "rgba(255,255,255,0.3)" }}>
              {items.length} saved reflection{items.length !== 1 ? "s" : ""}
            </p>
          </div>
          <button onClick={onClose} style={{ ...actionBtn("rgba(255,255,255,0.3)"), border: "1px solid rgba(255,255,255,0.1)", borderRadius: 20, padding: "8px 14px", fontSize: 13, fontFamily: "'DM Sans', sans-serif" }}>{t(lang, "close")}</button>
        </div>
        <div style={{ overflowY: "auto", flex: 1, padding: "0 20px 32px" }}>
          {items.length === 0 ? (
            <div style={{ textAlign: "center", padding: "60px 20px", color: "rgba(255,255,255,0.2)", fontFamily: "'DM Sans', sans-serif", fontSize: 14 }}>
              <div style={{ fontSize: 32, marginBottom: 12 }}>🔮</div>Save quotes to build your vault
            </div>
          ) : items.map(q => {
            const m = CATEGORY_META[q.category];
            return (
              <div key={q.id} style={{ background: "#1e1e27", borderRadius: 16, padding: "18px 20px", marginBottom: 12, border: "1px solid rgba(255,255,255,0.05)", display: "flex", gap: 14, alignItems: "flex-start" }}>
                <div style={{ width: 3, minHeight: 40, borderRadius: 2, background: m.color, flexShrink: 0, marginTop: 2 }} />
                <div style={{ flex: 1 }}>
                  <p style={{ margin: "0 0 8px", fontFamily: "'Playfair Display', serif", fontSize: 14, fontStyle: "italic", color: "#E8E3D8", lineHeight: 1.6 }}>"{q.text}"</p>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                    <span style={{ fontFamily: "'DM Sans', sans-serif", fontSize: 11, color: "rgba(255,255,255,0.35)" }}>— {q.author}</span>
                    <span style={{ fontSize: 10, color: m.color, fontFamily: "'DM Sans', sans-serif", fontWeight: 600, letterSpacing: "0.1em", textTransform: "uppercase" }}>{q.category}</span>
                  </div>
                </div>
                <button onClick={() => onRemove(q.id)} style={{ ...actionBtn("rgba(255,255,255,0.2)"), padding: 6, flexShrink: 0 }}>
                  <XIcon size={14} />
                </button>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

/* ─── CATEGORY STATS ─────────────────────────────────────────────────────────── */
function CategoryStats({ counts }) {
  const total = Object.values(counts).reduce((a, b) => a + b, 0) || 1;
  return (
    <div style={{ display: "flex", gap: 8, padding: "0 20px" }}>
      {Object.entries(CATEGORY_META).map(([cat, meta]) => {
        const pct = Math.round(((counts[cat] || 0) / total) * 100);
        return (
          <div key={cat} style={{ flex: 1, textAlign: "center" }}>
            <div style={{ height: 3, borderRadius: 2, background: "rgba(255,255,255,0.06)", marginBottom: 6, overflow: "hidden" }}>
              <div style={{ height: "100%", width: `${pct}%`, background: meta.color, borderRadius: 2, transition: "width 0.5s ease" }} />
            </div>
            <span style={{ fontSize: 9, fontFamily: "'DM Sans', sans-serif", fontWeight: 600, letterSpacing: "0.1em", textTransform: "uppercase", color: "rgba(255,255,255,0.25)" }}>
              {cat.slice(0, 4)}
            </span>
          </div>
        );
      })}
    </div>
  );
}

/* ─── localStorage helpers ───────────────────────────────────────────────────── */
function loadLang() {
  try {
    return localStorage.getItem("mindscroll_lang") || USER_LANG || "en";
  } catch (_) { return "en"; }
}
function saveLang(lang) {
  try { localStorage.setItem("mindscroll_lang", lang); } catch (_) {}
}
function loadIsPremium() {
  try { return localStorage.getItem("mindscroll_premium") === "true"; } catch (_) { return false; }
}
function saveIsPremium(val) {
  try { localStorage.setItem("mindscroll_premium", val ? "true" : "false"); } catch (_) {}
}
function loadProfile() {
  try {
    const raw = localStorage.getItem("mindscroll_profile");
    return raw ? JSON.parse(raw) : null;
  } catch (_) { return null; }
}
function hasCompletedOnboarding() {
  try { return localStorage.getItem("mindscroll_onboarding") === "true"; } catch (_) { return false; }
}

/* ─── MAIN APP ───────────────────────────────────────────────────────────────── */
export default function App() {
  const [deck,        setDeck]        = useState([]);
  const [loading,     setLoading]     = useState(true);
  const [current,     setCurrent]     = useState(0);
  const [liked,       setLiked]       = useState(() => new Set(loadState()?.liked ?? []));
  const [vault,       setVault]       = useState(() => loadState()?.vault ?? []);
  const [showVault,   setShowVault]   = useState(false);
  const [streak,      setStreak]      = useState(() => loadState()?.streak ?? 0);
  const [reflections, setReflections] = useState(() => loadState()?.reflections ?? 0);
  const [showHints,   setShowHints]   = useState(true);
  const [swipeCounts, setSwipeCounts] = useState({ philosophy: 0, stoicism: 0, discipline: 0, reflection: 0 });
  const [toastMsg,    setToastMsg]    = useState(null);
  const [streakPulse, setStreakPulse] = useState(false);

  // New Sprint 4 state
  const [showOnboarding, setShowOnboarding] = useState(() => !hasCompletedOnboarding());
  const [showSettings,   setShowSettings]   = useState(false);
  const [showDonation,   setShowDonation]   = useState(false);
  const [showMap,        setShowMap]        = useState(false);
  const [showChallenge,  setShowChallenge]  = useState(false);
  const [mapData,        setMapData]        = useState(null);
  const [challengeData,  setChallengeData]  = useState(null);
  const [challengeProgress, setChallengeProgress] = useState({ progress: 0, completed: false });
  const [isPremium,      setIsPremium]      = useState(() => loadIsPremium());
  const [lang,           setLang]           = useState(() => loadLang());
  const [profile,        setProfile]        = useState(() => loadProfile());

  const toastTimer      = useRef(null);
  const pageRef         = useRef(1);
  const loadingMore     = useRef(false);
  const swipeStartTime  = useRef(Date.now());

  // Initial data load
  useEffect(() => {
    const useLang = profile?.preferred_language || lang;
    fetchQuotes(1, useLang).then(({ quotes, nextPage }) => {
      setDeck(quotes);
      pageRef.current = nextPage;
      setLoading(false);
    });
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  // Prefetch more quotes when nearing end
  useEffect(() => {
    if (!loadingMore.current && pageRef.current && deck.length > 0 && current >= deck.length - 5) {
      loadingMore.current = true;
      const useLang = profile?.preferred_language || lang;
      fetchQuotes(pageRef.current, useLang).then(({ quotes, nextPage }) => {
        setDeck(prev => [...prev, ...quotes]);
        pageRef.current = nextPage;
        loadingMore.current = false;
      });
    }
  }, [current, deck.length]); // eslint-disable-line react-hooks/exhaustive-deps

  // Persist core state
  useEffect(() => {
    saveState({ liked: [...liked], vault, streak, reflections });
  }, [liked, vault, streak, reflections]);

  // Load challenge from API on mount (fire-and-forget)
  useEffect(() => {
    if (!showOnboarding) {
      apiGetTodayChallenge().then(ch => {
        if (ch) setChallengeData(ch);
      }).catch(() => {});
    }
  }, [showOnboarding]);

  // Load philosophy map from API (fire-and-forget)
  useEffect(() => {
    if (!showOnboarding) {
      apiGetMap().then(data => {
        if (data) setMapData(data);
      }).catch(() => {});
    }
  }, [showOnboarding]);

  // Load premium status from API; always respect cached value as optimistic state
  useEffect(() => {
    if (!showOnboarding) {
      apiGetPremiumStatus().then(data => {
        if (data?.is_premium) {
          setIsPremium(true);
          saveIsPremium(true);
        }
      }).catch(() => {});
    }
  }, [showOnboarding]);

  // Track swipe start time for dwell measurement
  useEffect(() => {
    swipeStartTime.current = Date.now();
  }, [current]);

  const showToast = useCallback((msg, color = "#14B8A6") => {
    clearTimeout(toastTimer.current);
    setToastMsg({ msg, color });
    toastTimer.current = setTimeout(() => setToastMsg(null), 2200);
  }, []);

  const handleLangChange = useCallback((newLang) => {
    setLang(newLang);
    saveLang(newLang);
  }, []);

  const handleOnboardingComplete = useCallback((prof) => {
    setProfile(prof);
    if (prof.preferred_language) {
      setLang(prof.preferred_language);
      saveLang(prof.preferred_language);
    }
    setShowOnboarding(false);
  }, []);

  const handleSwipe = useCallback((dir) => {
    const quote    = deck[current % Math.max(1, deck.length)];
    const category = DIR_TO_CATEGORY[dir];
    const dwell    = Date.now() - swipeStartTime.current;

    setSwipeCounts(prev => ({ ...prev, [category]: (prev[category] || 0) + 1 }));
    setShowHints(false);
    setReflections(r => {
      const next = r + 1;
      if (next % 5 === 0) {
        setStreak(s => s + 1);
        setStreakPulse(true);
        setTimeout(() => setStreakPulse(false), 1000);
        showToast(t(lang, "streak_extended"), "#F59E0B");
      }

      // Update challenge progress (fire-and-forget)
      if (challengeData) {
        const newProgress = Math.min(next, challengeData.target ?? 8);
        const completed   = newProgress >= (challengeData.target ?? 8);
        setChallengeProgress({ progress: newProgress, completed });
        apiUpdateChallengeProgress(challengeData.id, newProgress, completed).catch(() => {});
      } else {
        // Offline default challenge: 8 swipes
        setChallengeProgress(prev => {
          const newProg = prev.progress + 1;
          return { progress: newProg, completed: newProg >= 8 };
        });
      }

      return next;
    });

    // Record swipe fire-and-forget
    if (quote) {
      apiRecordSwipe(quote.id, dir, category, dwell).catch(() => {});
    }

    setCurrent(c => c + 1);
  }, [showToast, lang, challengeData, deck, current]);

  const handleLike = useCallback((id) => {
    setLiked(prev => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
        showToast(t(lang, "removed_like"));
        apiLike(id, "unlike").catch(() => {});
      } else {
        next.add(id);
        showToast(t(lang, "liked"));
        apiLike(id, "like").catch(() => {});
      }
      return next;
    });
  }, [showToast, lang]);

  const handleSave = useCallback((q) => {
    setVault(prev => {
      if (prev.find(v => v.id === q.id)) {
        showToast(t(lang, "already_vault"), "#F59E0B");
        return prev;
      }
      showToast(t(lang, "saved_vault"), "#14B8A6");
      apiSaveVault(q.id).catch(() => {});
      return [q, ...prev];
    });
  }, [showToast, lang]);

  const handleRemove = useCallback((id) => {
    setVault(prev => prev.filter(v => v.id !== id));
    apiRemoveVault(id).catch(() => {});
  }, []);

  const handleExport = useCallback((quote) => {
    if (!isPremium) {
      showToast(t(lang, "premium_feature"), "#F97316");
      return;
    }
    exportQuoteImage(quote)
      .then(() => showToast(t(lang, "export_image"), "#14B8A6"))
      .catch(() => showToast("Export failed", "#EF4444"));
  }, [isPremium, showToast, lang]);

  const handleShare = useCallback((quote) => {
    shareQuote(quote, showToast, lang);
  }, [showToast, lang]);

  const quote = deck[current % Math.max(1, deck.length)];
  const meta  = CATEGORY_META[quote?.category] || CATEGORY_META.reflection;

  // Loading screen
  if (loading) return (
    <div style={{ width: "100%", minHeight: "100vh", background: "#0f0f13", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 16 }}>
      <style>{`@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:ital@1&display=swap');`}</style>
      <p style={{ fontFamily: "'Playfair Display', serif", fontStyle: "italic", fontSize: 22, color: "#F5F0E8", margin: 0 }}>
        Mind<span style={{ color: "#14B8A6" }}>Scroll</span>
      </p>
      <p style={{ fontFamily: "sans-serif", fontSize: 12, color: "rgba(255,255,255,0.25)", margin: 0, letterSpacing: "0.1em", textTransform: "uppercase" }}>
        {t(lang, "loading")}
      </p>
    </div>
  );

  return (
    <div style={{ width: "100%", minHeight: "100vh", background: "#0f0f13", position: "relative", overflow: "hidden", fontFamily: "'DM Sans', sans-serif" }}>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;1,400;1,600&family=DM+Sans:wght@400;500;600&display=swap');
        @keyframes fade-in { from { opacity:0 } to { opacity:1 } }
        @keyframes slide-up { from { transform:translateY(100%) } to { transform:translateY(0) } }
        @keyframes hint-pulse { 0%,100%{opacity:0.25} 50%{opacity:0.5} }
        @keyframes streak-pulse { 0%,100%{transform:scale(1)} 50%{transform:scale(1.25)} }
        @keyframes toast-in { 0%{opacity:0;transform:translateX(-50%) translateY(10px)} 100%{opacity:1;transform:translateX(-50%) translateY(0)} }
        @keyframes particle-burst { 0%{transform:translate(-50%,-50%) translate(0,0) scale(1);opacity:1} 100%{transform:translate(-50%,-50%) translate(var(--tx),var(--ty)) scale(0);opacity:0} }
        * { box-sizing:border-box; -webkit-tap-highlight-color:transparent; }
        button:hover { opacity:0.8; }
        ::-webkit-scrollbar { width:4px; }
        ::-webkit-scrollbar-thumb { background:rgba(255,255,255,0.1); border-radius:2px; }
      `}</style>

      {/* Onboarding overlay */}
      {showOnboarding && (
        <Onboarding lang={lang} onComplete={handleOnboardingComplete} />
      )}

      {/* Ambient background glow */}
      <div style={{ position: "fixed", inset: 0, pointerEvents: "none", zIndex: 0, background: `radial-gradient(ellipse 60% 50% at 50% 100%, ${meta.color}18 0%, transparent 70%)`, transition: "background 0.8s ease" }} />

      {/* Header */}
      <header style={{ position: "relative", zIndex: 20, display: "flex", justifyContent: "space-between", alignItems: "center", padding: "20px 24px 0" }}>
        <h1 style={{ margin: 0, fontSize: 18, fontWeight: 600, fontFamily: "'Playfair Display', serif", color: "#F5F0E8", letterSpacing: "-0.02em" }}>
          Mind<span style={{ color: meta.color, transition: "color 0.4s" }}>Scroll</span>
        </h1>
        <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
          <div style={{ display: "flex", alignItems: "center", gap: 6, background: "rgba(245,158,11,0.1)", border: "1px solid rgba(245,158,11,0.2)", borderRadius: 20, padding: "6px 12px", animation: streakPulse ? "streak-pulse 0.4s ease" : "none" }}>
            <FireIcon size={15} />
            <span style={{ fontSize: 13, fontWeight: 600, color: "#F59E0B" }}>{streak}</span>
          </div>
          <div style={{ display: "flex", alignItems: "center", gap: 6, background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.08)", borderRadius: 20, padding: "6px 12px" }}>
            <span style={{ fontSize: 13, color: "rgba(255,255,255,0.5)" }}>✦</span>
            <span style={{ fontSize: 13, fontWeight: 600, color: "rgba(255,255,255,0.7)" }}>{reflections}</span>
          </div>
          {/* Settings gear button */}
          <button
            onClick={() => setShowSettings(true)}
            style={{
              background: "rgba(255,255,255,0.05)",
              border: "1px solid rgba(255,255,255,0.08)",
              borderRadius: 20,
              padding: "8px",
              cursor: "pointer",
              color: "rgba(255,255,255,0.4)",
              display: "flex", alignItems: "center", justifyContent: "center",
              transition: "all 0.2s",
            }}
            title={t(lang, "settings")}
          >
            <GearIcon size={16} />
          </button>
        </div>
      </header>

      {/* Category stats bar */}
      <div style={{ position: "relative", zIndex: 20, paddingTop: 16 }}>
        <CategoryStats counts={swipeCounts} />
      </div>

      {/* Card area */}
      <div style={{ position: "relative", zIndex: 10, height: "calc(100vh - 200px)", minHeight: 480 }}>
        {deck[(current + 1) % Math.max(1, deck.length)] && (
          <div style={{ position: "absolute", top: "50%", left: "50%", transform: "translate(-50%, calc(-50% + 12px)) scale(0.94)", width: "min(380px, 90vw)", height: 420, background: "#1a1a21", borderRadius: 28, border: "1px solid rgba(255,255,255,0.04)", zIndex: 9 }} />
        )}
        {quote && (
          <QuoteCard
            key={current}
            quote={quote}
            onSwipe={handleSwipe}
            onLike={handleLike}
            onSave={handleSave}
            onShare={handleShare}
            onExport={handleExport}
            isLiked={liked.has(quote.id)}
            isSaved={vault.some(v => v.id === quote.id)}
            swipeHint={showHints}
            isPremium={isPremium}
            lang={lang}
          />
        )}
      </div>

      {/* Bottom nav */}
      <nav style={{ position: "fixed", bottom: 0, left: 0, right: 0, zIndex: 30, display: "flex", justifyContent: "space-around", alignItems: "center", padding: "14px 32px 24px", background: "linear-gradient(to top, #0f0f13 60%, transparent)" }}>
        <div style={{ display: "flex", gap: 6 }}>
          {Object.entries(CATEGORY_META).map(([cat, m]) => (
            <div key={cat} title={m.label} style={{ width: 8, height: 8, borderRadius: "50%", background: swipeCounts[cat] > 0 ? m.color : "rgba(255,255,255,0.12)", transition: "background 0.3s" }} />
          ))}
        </div>
        <button onClick={() => setShowVault(true)} style={{ background: vault.length > 0 ? "rgba(20,184,166,0.12)" : "rgba(255,255,255,0.05)", border: `1px solid ${vault.length > 0 ? "rgba(20,184,166,0.3)" : "rgba(255,255,255,0.08)"}`, borderRadius: 22, padding: "10px 20px", display: "flex", alignItems: "center", gap: 8, cursor: "pointer", color: vault.length > 0 ? "#14B8A6" : "rgba(255,255,255,0.4)", fontFamily: "'DM Sans', sans-serif", fontSize: 13, fontWeight: 500, transition: "all 0.2s" }}>
          <BookmarkIcon size={16} filled={vault.length > 0} />
          {t(lang, "vault")} {vault.length > 0 && <span style={{ background: "#14B8A6", color: "#0f0f13", borderRadius: 10, padding: "1px 6px", fontSize: 11, fontWeight: 700 }}>{vault.length}</span>}
        </button>
        <span style={{ fontSize: 11, color: "rgba(255,255,255,0.2)", fontFamily: "'DM Sans', sans-serif" }}>
          {deck.length > 0 ? `${(current % deck.length) + 1} / ${deck.length}` : "—"}
        </span>
      </nav>

      {/* Overlays */}
      {showVault && (
        <VaultSheet
          items={vault}
          onClose={() => setShowVault(false)}
          onRemove={handleRemove}
          lang={lang}
        />
      )}

      {showSettings && (
        <Settings
          lang={lang}
          onLangChange={handleLangChange}
          isPremium={isPremium}
          onClose={() => setShowSettings(false)}
          showToast={showToast}
          onShowMap={() => { setShowSettings(false); setShowMap(true); }}
          onShowChallenge={() => { setShowSettings(false); setShowChallenge(true); }}
          onShowDonation={() => { setShowSettings(false); setShowDonation(true); }}
        />
      )}

      {showDonation && (
        <DonationPanel
          lang={lang}
          onClose={() => setShowDonation(false)}
        />
      )}

      {showMap && (
        <PhilosophyMap
          mapData={mapData || {
            current: {
              wisdom:     swipeCounts.stoicism   || 0,
              discipline: swipeCounts.discipline || 0,
              reflection: swipeCounts.reflection || 0,
              philosophy: swipeCounts.philosophy || 0,
            },
            snapshot: null,
            snapshot_date: null,
          }}
          lang={lang}
          onClose={() => setShowMap(false)}
        />
      )}

      {showChallenge && (
        <DailyChallenge
          challenge={challengeData}
          progress={challengeProgress}
          lang={lang}
          onClose={() => setShowChallenge(false)}
        />
      )}

      {/* Toast */}
      {toastMsg && (
        <div style={{ position: "fixed", bottom: 100, left: "50%", transform: "translateX(-50%)", background: "#1e1e27", border: `1px solid ${toastMsg.color}40`, borderRadius: 24, padding: "10px 20px", fontFamily: "'DM Sans', sans-serif", fontSize: 13, fontWeight: 500, color: toastMsg.color, zIndex: 200, whiteSpace: "nowrap", animation: "toast-in 0.25s ease", boxShadow: "0 8px 32px rgba(0,0,0,0.4)" }}>
          {toastMsg.msg}
        </div>
      )}
    </div>
  );
}
