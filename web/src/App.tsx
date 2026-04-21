"use client";

import { useState, useEffect, useRef, useCallback, useMemo, type CSSProperties } from "react";
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
} from "./api/quotes";
import { saveState, loadState } from "./utils/storage";
import { shuffle } from "./utils/shuffle";
import { CATEGORY_META, DIR_TO_CATEGORY, USER_LANG } from "./constants";
import { t } from "./i18n";
import { exportQuoteImage } from "./utils/exportImage";
import Settings      from "./components/Settings";
import DonationPanel from "./components/DonationPanel";
import PhilosophyMap from "./components/PhilosophyMap";
import DailyChallenge from "./components/DailyChallenge";
import type {
  CategoryKey,
  ChallengeData,
  ChallengeProgress,
  Direction,
  Lang,
  MapData,
  PersistedState,
  Profile,
  Quote,
  Toast,
} from "./types";

interface IconProps {
  size?: number;
}
interface ToggleIconProps extends IconProps {
  filled: boolean;
}

/* ─── ICONS ──────────────────────────────────────────────────────────────────── */
const HeartIcon = ({ filled, size = 20 }: ToggleIconProps) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={filled ? "#F97316" : "none"} stroke={filled ? "#F97316" : "currentColor"} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
    <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
  </svg>
);
const BookmarkIcon = ({ filled, size = 20 }: ToggleIconProps) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={filled ? "#14B8A6" : "none"} stroke={filled ? "#14B8A6" : "currentColor"} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
    <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>
  </svg>
);
const FireIcon = ({ size = 18 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="#F59E0B" stroke="none">
    <path d="M12 2C9 7 6 9 6 14a6 6 0 0 0 12 0c0-5-3-7-6-12zm0 18a4 4 0 0 1-4-4c0-3 2-5 4-9 2 4 4 6 4 9a4 4 0 0 1-4 4z"/>
    <ellipse cx="12" cy="17" rx="2" ry="2.5" fill="#FDE68A" opacity="0.8"/>
  </svg>
);
const XIcon = ({ size = 18 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
    <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
  </svg>
);
const ShareIcon = ({ size = 18 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
    <circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/>
    <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>
  </svg>
);
const GearIcon = ({ size = 18 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
    <circle cx="12" cy="12" r="3"/>
    <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>
  </svg>
);
const ImageIcon = ({ size = 18 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
    <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
    <circle cx="8.5" cy="8.5" r="1.5"/>
    <polyline points="21 15 16 10 5 21"/>
  </svg>
);
const LockIcon = ({ size = 18 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
    <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
  </svg>
);

// Shape-only utility for icon buttons inside QuoteCard / VaultSheet.
// Caller still drives the icon `color` inline because it's stateful
// (liked / saved / premium-gated) and the palette comes from runtime
// CATEGORY_META.
const ACTION_BTN = "bg-transparent border-0 cursor-pointer p-2 rounded-xl flex items-center justify-center transition-[transform,opacity] duration-150";

/* ─── PARTICLE BURST ─────────────────────────────────────────────────────────── */
interface ParticleBurstProps {
  x: number;
  y: number;
  onDone: () => void;
}

function ParticleBurst({ x, y, onDone }: ParticleBurstProps) {
  const particles = useMemo(() => Array.from({ length: 10 }, (_, i) => ({
    id: i, angle: (i / 10) * 360,
    dist: 30 + Math.random() * 25, size: 4 + Math.random() * 4,
    color: ["#F97316","#F59E0B","#EF4444","#EC4899","#FBBF24"][i % 5],
  })), []);

  useEffect(() => { const tm = setTimeout(onDone, 700); return () => clearTimeout(tm); }, [onDone]);

  return (
    <div className="fixed pointer-events-none z-[9999]" style={{ left: x, top: y }}>
      {particles.map(p => {
        const rad = (p.angle * Math.PI) / 180;
        return (
          <div
            key={p.id}
            className="absolute rounded-full -translate-x-1/2 -translate-y-1/2 animate-particle-burst"
            style={{
              width: p.size,
              height: p.size,
              background: p.color,
              ["--tx" as string]: `${Math.cos(rad) * p.dist}px`,
              ["--ty" as string]: `${Math.sin(rad) * p.dist}px`,
            } as CSSProperties}
          />
        );
      })}
    </div>
  );
}

/* ─── SWIPE HINTS ────────────────────────────────────────────────────────────── */
function SwipeHints() {
  const HINTS = [
    { label: "Philosophy", color: "#F59E0B", className: "top-4 left-1/2 -translate-x-1/2" },
    { label: "Reflection", color: "#A78BFA", className: "bottom-[100px] left-1/2 -translate-x-1/2" },
    { label: "Stoicism",   color: "#14B8A6", className: "left-3 top-1/2 -translate-y-1/2" },
    { label: "Discipline", color: "#F97316", className: "right-3 top-1/2 -translate-y-1/2" },
  ];
  return (
    <>
      {HINTS.map(h => (
        <div
          key={h.label}
          className={`absolute font-sans text-[10px] font-semibold tracking-[0.12em] uppercase opacity-35 pointer-events-none z-[5] animate-hint-pulse ${h.className}`}
          style={{ color: h.color }}
        >
          {h.label}
        </div>
      ))}
    </>
  );
}

/* ─── QUOTE CARD ─────────────────────────────────────────────────────────────── */
interface QuoteCardProps {
  quote: Quote;
  onSwipe: (dir: Direction) => void;
  onLike: (id: string) => void;
  onSave: (q: Quote) => void;
  onShare: (q: Quote) => void;
  onExport: (q: Quote) => void;
  isLiked: boolean;
  isSaved: boolean;
  swipeHint: boolean;
  isPremium: boolean;
  lang: Lang;
}

interface Burst { x: number; y: number; }
interface DragOffset { x: number; y: number; }

function QuoteCard({ quote, onSwipe, onLike, onSave, onShare, onExport, isLiked, isSaved, swipeHint, isPremium, lang }: QuoteCardProps) {
  const cardRef   = useRef<HTMLDivElement | null>(null);
  const dragStart = useRef<DragOffset | null>(null);
  const tapTimer  = useRef<ReturnType<typeof setTimeout> | null>(null);
  const [dragging, setDragging] = useState(false);
  const [offset,   setOffset]   = useState<DragOffset>({ x: 0, y: 0 });
  const [flyDir,   setFlyDir]   = useState<Direction | null>(null);
  const [tapCount, setTapCount] = useState(0);
  const [burst,    setBurst]    = useState<Burst | null>(null);
  const meta = CATEGORY_META[quote.category];

  const getDir = (dx: number, dy: number): Direction =>
    Math.abs(dx) > Math.abs(dy) ? (dx > 0 ? "right" : "left") : (dy > 0 ? "down" : "up");

  const startDrag = (cx: number, cy: number) => { dragStart.current = { x: cx, y: cy }; setDragging(true); };
  const moveDrag  = (cx: number, cy: number) => {
    if (!dragStart.current || flyDir) return;
    setOffset({ x: cx - dragStart.current.x, y: cy - dragStart.current.y });
  };
  const endDrag = (cx: number, cy: number) => {
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
    if (tapTimer.current) clearTimeout(tapTimer.current);
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

  // Dynamic runtime values — Tailwind classes can't express these.
  const cardTransform = flyTransform
    || `translate(-50%, -50%) translate(${offset.x}px, ${offset.y}px) rotate(${offset.x / 20}deg)`;
  const cardTransition = flyDir
    ? "transform 0.35s cubic-bezier(0.4,0,1,1), opacity 0.35s"
    : dragging
      ? "none"
      : "transform 0.4s cubic-bezier(0.34,1.56,0.64,1)";
  const cardOpacity = flyDir ? 0 : Math.max(0.6, 1 - Math.sqrt(offset.x ** 2 + offset.y ** 2) / 400);
  const cardBoxShadow = edgeColor !== "transparent"
    ? `0 0 0 2px ${edgeColor}${Math.round(edgeGlow * 255).toString(16).padStart(2, "0")}, 0 32px 80px rgba(0,0,0,0.6)`
    : "0 32px 80px rgba(0,0,0,0.6), 0 0 0 1px rgba(255,255,255,0.05)";

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
        className={`absolute top-1/2 left-1/2 min-h-[420px] select-none z-10 rounded-[28px] bg-gradient-to-br from-mindscroll-bg-card to-mindscroll-bg-card-end border border-white/[0.07] flex flex-col px-8 pt-9 pb-7 ${dragging ? "cursor-grabbing" : "cursor-grab"}`}
        style={{
          width: "min(380px, 90vw)",
          transform: cardTransform,
          transition: cardTransition,
          opacity: cardOpacity,
          boxShadow: cardBoxShadow,
        }}
      >
        <div className="flex justify-between items-center mb-8">
          <span
            className="text-[11px] font-sans font-semibold tracking-[0.12em] uppercase py-[5px] px-3 rounded-[20px]"
            style={{ color: meta.color, background: meta.bg }}
          >
            {meta.label}
          </span>
          <span className="text-[11px] text-white/25 font-sans">{meta.dir}</span>
        </div>

        <div className="flex-1 flex items-center">
          <blockquote
            className="m-0 p-0 font-serif italic font-normal leading-[1.65] text-mindscroll-cream tracking-[-0.01em]"
            style={{ fontSize: "clamp(18px, 4vw, 24px)" }}
          >
            <span
              className="text-[2em] leading-[0.3] align-[-0.3em] mr-1 not-italic"
              style={{ color: meta.color }}
            >&ldquo;</span>
            {quote.text}
            <span
              className="text-[2em] leading-[0.3] align-[-0.3em] ml-1 not-italic"
              style={{ color: meta.color }}
            >&rdquo;</span>
          </blockquote>
        </div>

        <div className="mt-7 mb-6">
          <div className="w-8 h-px opacity-50 mb-2.5" style={{ background: meta.color }} />
          <p className="m-0 font-sans text-[13px] font-medium text-white/45 tracking-[0.05em]">
            &mdash; {quote.author}
          </p>
        </div>

        <div className="flex justify-between items-center pt-5 border-t border-white/[0.06]">
          <button
            onClick={e => { e.stopPropagation(); onLike(quote.id); }}
            className={ACTION_BTN}
            style={{ color: isLiked ? "#F97316" : "rgba(255,255,255,0.2)" }}
          >
            <HeartIcon filled={isLiked} size={19} />
          </button>
          <p className="m-0 font-sans text-[11px] text-white/[0.18] tracking-[0.08em]">
            {t(lang, "double_tap")}
          </p>
          <div className="flex gap-2">
            {/* Export image — premium gated */}
            <button
              onClick={e => { e.stopPropagation(); onExport(quote); }}
              className={ACTION_BTN}
              style={{ color: isPremium ? "rgba(255,255,255,0.2)" : "rgba(255,255,255,0.1)" }}
              title={isPremium ? t(lang, "export_image") : t(lang, "premium_feature")}
            >
              {isPremium ? <ImageIcon size={19} /> : <LockIcon size={17} />}
            </button>
            <button
              onClick={e => { e.stopPropagation(); onSave(quote); }}
              className={ACTION_BTN}
              style={{ color: isSaved ? "#14B8A6" : "rgba(255,255,255,0.2)" }}
            >
              <BookmarkIcon filled={isSaved} size={19} />
            </button>
            <button
              onClick={e => { e.stopPropagation(); onShare(quote); }}
              className={ACTION_BTN}
              style={{ color: "rgba(255,255,255,0.2)" }}
            >
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
interface VaultSheetProps {
  items: Quote[];
  onClose: () => void;
  onRemove: (id: string) => void;
  lang: Lang;
}

function VaultSheet({ items, onClose, onRemove, lang }: VaultSheetProps) {
  return (
    <div
      onClick={onClose}
      className="fixed inset-0 z-[100] bg-black/70 flex items-end animate-fade-in"
    >
      <div
        onClick={(e) => e.stopPropagation()}
        className="w-full max-h-[78vh] bg-mindscroll-bg-soft rounded-t-[28px] border border-white/[0.07] flex flex-col animate-slide-up overflow-hidden"
      >
        <div className="flex justify-center pt-4">
          <div className="w-10 h-1 rounded-sm bg-white/[0.15]" />
        </div>
        <div className="flex justify-between items-center pt-4 pb-3 px-7">
          <div>
            <h2 className="m-0 font-serif text-[22px] font-semibold text-mindscroll-cream">
              {t(lang, "vault")}
            </h2>
            <p className="mt-0.5 mb-0 font-sans text-xs text-white/30">
              {items.length} saved reflection{items.length !== 1 ? "s" : ""}
            </p>
          </div>
          <button
            onClick={onClose}
            className={`${ACTION_BTN} border border-white/10 rounded-[20px] py-2 px-3.5 text-[13px] font-sans`}
            style={{ color: "rgba(255,255,255,0.3)" }}
          >
            {t(lang, "close")}
          </button>
        </div>
        <div className="overflow-y-auto flex-1 px-5 pb-8">
          {items.length === 0 ? (
            <div className="text-center py-[60px] px-5 text-white/20 font-sans text-sm">
              <div className="text-[32px] mb-3">🔮</div>
              Save quotes to build your vault
            </div>
          ) : items.map(q => {
            const m = CATEGORY_META[q.category];
            return (
              <div
                key={q.id}
                className="bg-[#1e1e27] rounded-2xl py-4 px-5 mb-3 border border-white/[0.05] flex gap-3.5 items-start"
              >
                <div
                  className="w-[3px] min-h-10 rounded-sm shrink-0 mt-0.5"
                  style={{ background: m.color }}
                />
                <div className="flex-1">
                  <p className="mt-0 mb-2 font-serif text-sm italic text-mindscroll-cream-warm leading-[1.6]">
                    &ldquo;{q.text}&rdquo;
                  </p>
                  <div className="flex justify-between items-center">
                    <span className="font-sans text-[11px] text-white/35">
                      — {q.author}
                    </span>
                    <span
                      className="text-[10px] font-sans font-semibold tracking-[0.1em] uppercase"
                      style={{ color: m.color }}
                    >
                      {q.category}
                    </span>
                  </div>
                </div>
                <button
                  onClick={() => onRemove(q.id)}
                  className={`${ACTION_BTN} p-1.5 shrink-0`}
                  style={{ color: "rgba(255,255,255,0.2)" }}
                >
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
type SwipeCounts = Record<CategoryKey, number>;

function CategoryStats({ counts }: { counts: SwipeCounts }) {
  const total = Object.values(counts).reduce((a, b) => a + b, 0) || 1;
  return (
    <div className="flex gap-2 px-5">
      {(Object.entries(CATEGORY_META) as [CategoryKey, typeof CATEGORY_META[CategoryKey]][]).map(([cat, meta]) => {
        const pct = Math.round(((counts[cat] || 0) / total) * 100);
        return (
          <div key={cat} className="flex-1 text-center">
            <div className="h-[3px] rounded-sm bg-white/[0.06] mb-1.5 overflow-hidden">
              <div
                className="h-full rounded-sm transition-[width] duration-500 ease-out"
                style={{ width: `${pct}%`, background: meta.color }}
              />
            </div>
            <span className="text-[9px] font-sans font-semibold tracking-[0.1em] uppercase text-white/25">
              {cat.slice(0, 4)}
            </span>
          </div>
        );
      })}
    </div>
  );
}

/* ─── localStorage helpers ───────────────────────────────────────────────────── */
function loadLang(): Lang {
  try {
    const raw = localStorage.getItem("mindscroll_lang");
    if (raw === "en" || raw === "es") return raw;
    return USER_LANG || "en";
  } catch { return "en"; }
}
function saveLang(lang: Lang): void {
  try { localStorage.setItem("mindscroll_lang", lang); } catch { /* noop */ }
}
function loadIsPremium(): boolean {
  try { return localStorage.getItem("mindscroll_premium") === "true"; } catch { return false; }
}
function saveIsPremium(val: boolean): void {
  try { localStorage.setItem("mindscroll_premium", val ? "true" : "false"); } catch { /* noop */ }
}
function loadProfile(): Profile | null {
  try {
    const raw = localStorage.getItem("mindscroll_profile");
    return raw ? (JSON.parse(raw) as Profile) : null;
  } catch { return null; }
}

/* ─── MAIN APP ───────────────────────────────────────────────────────────────── */
export default function App() {
  const [deck,        setDeck]        = useState<Quote[]>([]);
  const [loading,     setLoading]     = useState(true);
  const [current,     setCurrent]     = useState(0);
  const [liked,       setLiked]       = useState<Set<string>>(() => new Set(loadState()?.liked ?? []));
  const [vault,       setVault]       = useState<Quote[]>(() => loadState()?.vault ?? []);
  const [showVault,   setShowVault]   = useState(false);
  const [streak,      setStreak]      = useState<number>(() => loadState()?.streak ?? 0);
  const [reflections, setReflections] = useState<number>(() => loadState()?.reflections ?? 0);
  const [showHints,   setShowHints]   = useState(true);
  const [swipeCounts, setSwipeCounts] = useState<SwipeCounts>({ philosophy: 0, stoicism: 0, discipline: 0, reflection: 0 });
  const [toastMsg,    setToastMsg]    = useState<Toast | null>(null);
  const [streakPulse, setStreakPulse] = useState(false);

  // New Sprint 4 state — onboarding gating now lives in app/page.tsx
  const [showSettings,   setShowSettings]   = useState(false);
  const [showDonation,   setShowDonation]   = useState(false);
  const [showMap,        setShowMap]        = useState(false);
  const [showChallenge,  setShowChallenge]  = useState(false);
  const [mapData,        setMapData]        = useState<MapData | null>(null);
  const [challengeData,  setChallengeData]  = useState<ChallengeData | null>(null);
  const [challengeProgress, setChallengeProgress] = useState<ChallengeProgress>({ progress: 0, completed: false });
  const [isPremium,      setIsPremium]      = useState<boolean>(() => loadIsPremium());
  const [lang,           setLang]           = useState<Lang>(() => loadLang());
  const [profile,        setProfile]        = useState<Profile | null>(() => loadProfile());

  const toastTimer      = useRef<ReturnType<typeof setTimeout> | null>(null);
  const pageRef         = useRef<number | null>(1);
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

  // Load challenge from API on mount (fire-and-forget). Onboarding gate
  // upstream guarantees this only runs after the user has a profile.
  useEffect(() => {
    apiGetTodayChallenge().then(ch => {
      if (ch) setChallengeData(ch);
    }).catch(() => {});
  }, []);

  // Load philosophy map from API (fire-and-forget)
  useEffect(() => {
    apiGetMap().then(data => {
      if (data) setMapData(data);
    }).catch(() => {});
  }, []);

  // Load premium status from API; always respect cached value as optimistic state
  useEffect(() => {
    apiGetPremiumStatus().then(data => {
      if (data?.is_premium) {
        setIsPremium(true);
        saveIsPremium(true);
      }
    }).catch(() => {});
  }, []);

  // Track swipe start time for dwell measurement
  useEffect(() => {
    swipeStartTime.current = Date.now();
  }, [current]);

  const showToast = useCallback((msg: string, color: string = "#14B8A6") => {
    if (toastTimer.current) clearTimeout(toastTimer.current);
    setToastMsg({ msg, color });
    toastTimer.current = setTimeout(() => setToastMsg(null), 2200);
  }, []);

  const handleLangChange = useCallback((newLang: Lang) => {
    setLang(newLang);
    saveLang(newLang);
  }, []);

  const handleSwipe = useCallback((dir: Direction) => {
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

  const handleLike = useCallback((id: string) => {
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

  const handleSave = useCallback((q: Quote) => {
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

  const handleRemove = useCallback((id: string) => {
    setVault(prev => prev.filter(v => v.id !== id));
    apiRemoveVault(id).catch(() => {});
  }, []);

  const handleExport = useCallback((quote: Quote) => {
    if (!isPremium) {
      showToast(t(lang, "premium_feature"), "#F97316");
      return;
    }
    exportQuoteImage(quote)
      .then(() => showToast(t(lang, "export_image"), "#14B8A6"))
      .catch(() => showToast("Export failed", "#EF4444"));
  }, [isPremium, showToast, lang]);

  const handleShare = useCallback((quote: Quote) => {
    shareQuote(quote, showToast, lang);
  }, [showToast, lang]);

  const quote = deck[current % Math.max(1, deck.length)];
  const meta  = CATEGORY_META[quote?.category] || CATEGORY_META.reflection;

  // Loading screen
  if (loading) return (
    <div className="w-full min-h-screen bg-mindscroll-bg flex flex-col items-center justify-center gap-4">
      <p className="font-serif italic text-[22px] text-mindscroll-cream m-0">
        Mind<span className="text-mindscroll-teal">Scroll</span>
      </p>
      <p className="font-sans text-xs text-white/25 m-0 tracking-[0.1em] uppercase">
        {t(lang, "loading")}
      </p>
    </div>
  );

  return (
    <div className="w-full min-h-screen bg-mindscroll-bg relative overflow-hidden font-sans">
      {/* Ambient background glow — gradient color drives off the active category */}
      <div
        className="fixed inset-0 pointer-events-none z-0 transition-[background] duration-700 ease-out"
        style={{ background: `radial-gradient(ellipse 60% 50% at 50% 100%, ${meta.color}18 0%, transparent 70%)` }}
      />

      {/* Header */}
      <header className="relative z-20 flex justify-between items-center px-6 pt-5">
        <h1 className="m-0 text-[18px] font-semibold font-serif text-mindscroll-cream tracking-[-0.02em]">
          Mind<span className="transition-colors duration-300" style={{ color: meta.color }}>Scroll</span>
        </h1>
        <div className="flex gap-2.5 items-center">
          <div
            className={`flex items-center gap-1.5 bg-mindscroll-amber/10 border border-mindscroll-amber/20 rounded-[20px] py-1.5 px-3 ${streakPulse ? "animate-streak-pulse" : ""}`}
          >
            <FireIcon size={15} />
            <span className="text-[13px] font-semibold text-mindscroll-amber">{streak}</span>
          </div>
          <div className="flex items-center gap-1.5 bg-white/[0.05] border border-white/[0.08] rounded-[20px] py-1.5 px-3">
            <span className="text-[13px] text-white/50">✦</span>
            <span className="text-[13px] font-semibold text-white/70">{reflections}</span>
          </div>
          {/* Settings gear button */}
          <button
            onClick={() => setShowSettings(true)}
            className="bg-white/[0.05] border border-white/[0.08] rounded-[20px] p-2 cursor-pointer text-white/40 flex items-center justify-center transition-all duration-200"
            title={t(lang, "settings")}
          >
            <GearIcon size={16} />
          </button>
        </div>
      </header>

      {/* Category stats bar */}
      <div className="relative z-20 pt-4">
        <CategoryStats counts={swipeCounts} />
      </div>

      {/* Card area */}
      <div className="relative z-10 min-h-[480px]" style={{ height: "calc(100vh - 200px)" }}>
        {deck[(current + 1) % Math.max(1, deck.length)] && (
          <div
            className="absolute top-1/2 left-1/2 h-[420px] rounded-[28px] bg-[#1a1a21] border border-white/[0.04] z-[9]"
            style={{
              width: "min(380px, 90vw)",
              transform: "translate(-50%, calc(-50% + 12px)) scale(0.94)",
            }}
          />
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
      <nav className="fixed bottom-0 inset-x-0 z-30 flex justify-around items-center pt-3.5 pb-6 px-8 bg-gradient-to-t from-mindscroll-bg from-60% to-transparent">
        <div className="flex gap-1.5">
          {(Object.entries(CATEGORY_META) as [CategoryKey, typeof CATEGORY_META[CategoryKey]][]).map(([cat, m]) => (
            <div
              key={cat}
              title={m.label}
              className="w-2 h-2 rounded-full transition-colors duration-300"
              style={{ background: swipeCounts[cat] > 0 ? m.color : "rgba(255,255,255,0.12)" }}
            />
          ))}
        </div>
        <button
          onClick={() => setShowVault(true)}
          className={`rounded-[22px] py-2.5 px-5 flex items-center gap-2 cursor-pointer font-sans text-[13px] font-medium transition-all duration-200 border ${
            vault.length > 0
              ? "bg-mindscroll-teal/10 border-mindscroll-teal/30 text-mindscroll-teal"
              : "bg-white/[0.05] border-white/[0.08] text-white/40"
          }`}
        >
          <BookmarkIcon size={16} filled={vault.length > 0} />
          {t(lang, "vault")} {vault.length > 0 && (
            <span className="bg-mindscroll-teal text-mindscroll-bg rounded-[10px] py-px px-1.5 text-[11px] font-bold">
              {vault.length}
            </span>
          )}
        </button>
        <span className="text-[11px] text-white/20 font-sans">
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
        <div
          className="fixed bottom-[100px] left-1/2 -translate-x-1/2 bg-[#1e1e27] rounded-3xl py-2.5 px-5 font-sans text-[13px] font-medium z-[200] whitespace-nowrap animate-toast-in shadow-[0_8px_32px_rgba(0,0,0,0.4)] border"
          style={{ color: toastMsg.color, borderColor: `${toastMsg.color}40` }}
        >
          {toastMsg.msg}
        </div>
      )}
    </div>
  );
}
