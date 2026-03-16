import { useState, useEffect, useRef, useCallback } from "react";

/* ─── DATA ─────────────────────────────────────────────────────────────────── */
const QUOTES = [
  { id: 1, text: "The happiness of your life depends upon the quality of your thoughts.", author: "Marcus Aurelius", category: "stoicism", dir: "left" },
  { id: 2, text: "We suffer more in imagination than in reality.", author: "Seneca", category: "stoicism", dir: "left" },
  { id: 3, text: "He who has a why to live can bear almost any how.", author: "Friedrich Nietzsche", category: "philosophy", dir: "up" },
  { id: 4, text: "Discipline is the bridge between goals and accomplishment.", author: "Jim Rohn", category: "discipline", dir: "right" },
  { id: 5, text: "Know thyself.", author: "Socrates", category: "philosophy", dir: "up" },
  { id: 6, text: "We are what we repeatedly do. Excellence, then, is not an act but a habit.", author: "Aristotle", category: "discipline", dir: "right" },
  { id: 7, text: "The unexamined life is not worth living.", author: "Socrates", category: "reflection", dir: "down" },
  { id: 8, text: "You have power over your mind — not outside events. Realize this, and you will find strength.", author: "Marcus Aurelius", category: "stoicism", dir: "left" },
  { id: 9, text: "In the middle of difficulty lies opportunity.", author: "Albert Einstein", category: "discipline", dir: "right" },
  { id: 10, text: "What we think, we become.", author: "Buddha", category: "reflection", dir: "down" },
  { id: 11, text: "The cave you fear to enter holds the treasure you seek.", author: "Joseph Campbell", category: "reflection", dir: "down" },
  { id: 12, text: "Waste no more time arguing what a good man should be. Be one.", author: "Marcus Aurelius", category: "stoicism", dir: "left" },
  { id: 13, text: "The impediment to action advances action. What stands in the way becomes the way.", author: "Marcus Aurelius", category: "philosophy", dir: "up" },
  { id: 14, text: "Do not go where the path may lead. Go instead where there is no path and leave a trail.", author: "Emerson", category: "philosophy", dir: "up" },
  { id: 15, text: "Suffer the pain of discipline or suffer the pain of regret.", author: "Jim Rohn", category: "discipline", dir: "right" },
];

const CATEGORY_META = {
  philosophy: { label: "Classical Philosophy", color: "#F59E0B", bg: "rgba(245,158,11,0.12)", dir: "↑ Up" },
  stoicism:   { label: "Stoicism",             color: "#14B8A6", bg: "rgba(20,184,166,0.12)", dir: "← Left" },
  discipline: { label: "Discipline",           color: "#F97316", bg: "rgba(249,115,22,0.12)", dir: "→ Right" },
  reflection: { label: "Reflection",           color: "#A78BFA", bg: "rgba(167,139,250,0.12)", dir: "↓ Down" },
};

const DIR_TO_CATEGORY = { up: "philosophy", left: "stoicism", right: "discipline", down: "reflection" };
const CATEGORY_TO_DIR = { philosophy: "up", stoicism: "left", discipline: "right", reflection: "down" };

/* ─── SPANISH QUOTES (static fallback when USER_LANG === "es") ───────────────── */
const QUOTES_ES = [
  // stoicism
  { id: "es-s1", text: "La felicidad de tu vida depende de la calidad de tus pensamientos.", author: "Marco Aurelio", category: "stoicism", dir: "left", lang: "es" },
  { id: "es-s2", text: "Sufrimos más en la imaginación que en la realidad.", author: "Séneca", category: "stoicism", dir: "left", lang: "es" },
  { id: "es-s3", text: "No busques que los acontecimientos sucedan como quieres; desea que sucedan como son, y serás feliz.", author: "Epicteto", category: "stoicism", dir: "left", lang: "es" },
  { id: "es-s4", text: "No son las cosas las que perturban a los hombres, sino las opiniones sobre las cosas.", author: "Epicteto", category: "stoicism", dir: "left", lang: "es" },
  { id: "es-s5", text: "Pierde el menor tiempo posible en las cosas de menor importancia.", author: "Marco Aurelio", category: "stoicism", dir: "left", lang: "es" },
  { id: "es-s6", text: "El hombre más poderoso es aquel que es dueño de sí mismo.", author: "Séneca", category: "stoicism", dir: "left", lang: "es" },
  { id: "es-s7", text: "Nunca desperdicies el sufrimiento.", author: "Marco Aurelio", category: "stoicism", dir: "left", lang: "es" },
  { id: "es-s8", text: "Ocupa tu mente con grandes pensamientos para que nunca carezca de espacio para los pequeños.", author: "Marco Aurelio", category: "stoicism", dir: "left", lang: "es" },
  // philosophy
  { id: "es-p1", text: "Solo sé que no sé nada.", author: "Sócrates", category: "philosophy", dir: "up", lang: "es" },
  { id: "es-p2", text: "La duda es el origen de la sabiduría.", author: "René Descartes", category: "philosophy", dir: "up", lang: "es" },
  { id: "es-p3", text: "La vida sin examen no merece ser vivida.", author: "Sócrates", category: "philosophy", dir: "up", lang: "es" },
  { id: "es-p4", text: "Todo fluye, nada permanece.", author: "Heráclito", category: "philosophy", dir: "up", lang: "es" },
  { id: "es-p5", text: "Pienso, luego existo.", author: "René Descartes", category: "philosophy", dir: "up", lang: "es" },
  { id: "es-p6", text: "El ser humano es un ser social por naturaleza.", author: "Aristóteles", category: "philosophy", dir: "up", lang: "es" },
  { id: "es-p7", text: "La filosofía comienza en el asombro.", author: "Aristóteles", category: "philosophy", dir: "up", lang: "es" },
  { id: "es-p8", text: "No temas a la muerte; teme no haber vivido.", author: "Epicuro", category: "philosophy", dir: "up", lang: "es" },
  // discipline
  { id: "es-d1", text: "La disciplina es el puente entre las metas y los logros.", author: "Jim Rohn", category: "discipline", dir: "right", lang: "es" },
  { id: "es-d2", text: "Somos lo que hacemos repetidamente. La excelencia no es un acto sino un hábito.", author: "Aristóteles", category: "discipline", dir: "right", lang: "es" },
  { id: "es-d3", text: "El éxito es la suma de pequeños esfuerzos repetidos día tras día.", author: "Robert Collier", category: "discipline", dir: "right", lang: "es" },
  { id: "es-d4", text: "El obstáculo en el camino se convierte en el camino.", author: "Marco Aurelio", category: "discipline", dir: "right", lang: "es" },
  { id: "es-d5", text: "Cae siete veces, levántate ocho.", author: "Proverbio japonés", category: "discipline", dir: "right", lang: "es" },
  { id: "es-d6", text: "Un río corta la roca no por su fuerza, sino por su perseverancia.", author: "Ovidio", category: "discipline", dir: "right", lang: "es" },
  { id: "es-d7", text: "La preparación es la clave del éxito.", author: "Alexander Graham Bell", category: "discipline", dir: "right", lang: "es" },
  { id: "es-d8", text: "No cuentes los días, haz que los días cuenten.", author: "Muhammad Ali", category: "discipline", dir: "right", lang: "es" },
  // reflection
  { id: "es-r1", text: "Lo que pensamos, en eso nos convertimos.", author: "Buda", category: "reflection", dir: "down", lang: "es" },
  { id: "es-r2", text: "Conócete a ti mismo.", author: "Sócrates", category: "reflection", dir: "down", lang: "es" },
  { id: "es-r3", text: "En el medio de la dificultad reside la oportunidad.", author: "Albert Einstein", category: "reflection", dir: "down", lang: "es" },
  { id: "es-r4", text: "La vida no es lo que uno vivió, sino lo que uno recuerda y cómo lo recuerda.", author: "Gabriel García Márquez", category: "reflection", dir: "down", lang: "es" },
  { id: "es-r5", text: "Conocerse a sí mismo es el principio de toda sabiduría.", author: "Aristóteles", category: "reflection", dir: "down", lang: "es" },
  { id: "es-r6", text: "La paz interior comienza en el momento en que eliges no permitir que otra persona o evento controle tus emociones.", author: "Pema Chödrön", category: "reflection", dir: "down", lang: "es" },
  { id: "es-r7", text: "No mires atrás con ira, ni adelante con temor, sino a tu alrededor con conciencia.", author: "James Thurber", category: "reflection", dir: "down", lang: "es" },
  { id: "es-r8", text: "El silencio es la lengua de los sabios.", author: "Pitágoras", category: "reflection", dir: "down", lang: "es" },
];

/* Quotable.io tags mapped to our 4 categories */
const CATEGORY_TAGS = {
  stoicism:   "wisdom",
  philosophy: "philosophy",
  discipline: "success|motivational",
  reflection: "inspirational|life",
};

/* ─── ICONS ─────────────────────────────────────────────────────────────────── */
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

/* ─── PARTICLE BURST ─────────────────────────────────────────────────────────── */
function ParticleBurst({ x, y, onDone }) {
  const particles = useMemo(() => Array.from({ length: 10 }, (_, i) => ({
    id: i,
    angle: (i / 10) * 360,
    dist: 30 + Math.random() * 25,
    size: 4 + Math.random() * 4,
    color: ["#F97316","#F59E0B","#EF4444","#EC4899","#FBBF24"][i % 5],
  })), []);

  useEffect(() => { const t = setTimeout(onDone, 700); return () => clearTimeout(t); }, [onDone]);

  return (
    <div style={{ position: "fixed", left: x, top: y, pointerEvents: "none", zIndex: 9999 }}>
      {particles.map(p => {
        const rad = (p.angle * Math.PI) / 180;
        const tx = Math.cos(rad) * p.dist;
        const ty = Math.sin(rad) * p.dist;
        return (
          <div key={p.id} style={{
            position: "absolute", width: p.size, height: p.size,
            borderRadius: "50%", background: p.color,
            transform: "translate(-50%,-50%)",
            animation: `particle-burst 0.6s ease-out forwards`,
            "--tx": `${tx}px`, "--ty": `${ty}px`,
          }}/>
        );
      })}
    </div>
  );
}

/* ─── QUOTE CARD ─────────────────────────────────────────────────────────────── */
function QuoteCard({ quote, onSwipe, onLike, onSave, onShare, isLiked, isSaved, swipeHint }) {
  const cardRef = useRef(null);
  const dragStart = useRef(null);
  const [dragging, setDragging] = useState(false);
  const [offset, setOffset] = useState({ x: 0, y: 0 });
  const [flyDir, setFlyDir] = useState(null);
  const [tapCount, setTapCount] = useState(0);
  const [burst, setBurst] = useState(null);
  const tapTimer = useRef(null);
  const meta = CATEGORY_META[quote.category];

  // Determine dominant swipe direction
  const getDir = (dx, dy) => {
    if (Math.abs(dx) > Math.abs(dy)) return dx > 0 ? "right" : "left";
    return dy > 0 ? "down" : "up";
  };

  const startDrag = (clientX, clientY) => {
    dragStart.current = { x: clientX, y: clientY };
    setDragging(true);
  };

  const moveDrag = (clientX, clientY) => {
    if (!dragStart.current || flyDir) return;
    const dx = clientX - dragStart.current.x;
    const dy = clientY - dragStart.current.y;
    setOffset({ x: dx, y: dy });
  };

  const endDrag = (clientX, clientY) => {
    if (!dragStart.current) return;
    const dx = clientX - dragStart.current.x;
    const dy = clientY - dragStart.current.y;
    const dist = Math.sqrt(dx * dx + dy * dy);
    dragStart.current = null;
    setDragging(false);

    if (dist > 80) {
      const dir = getDir(dx, dy);
      setFlyDir(dir);
      setTimeout(() => { setFlyDir(null); setOffset({ x: 0, y: 0 }); onSwipe(dir); }, 350);
    } else {
      setOffset({ x: 0, y: 0 });
    }
  };

  const handleTap = (e) => {
    const newCount = tapCount + 1;
    setTapCount(newCount);
    clearTimeout(tapTimer.current);
    if (newCount >= 2) {
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

  const dragRotate = offset.x / 20;
  const dragOpacity = Math.max(0.6, 1 - Math.sqrt(offset.x ** 2 + offset.y ** 2) / 400);

  // Edge glow based on drag direction
  const edgeColor = offset.x > 40 ? "#F97316" : offset.x < -40 ? "#14B8A6" : offset.y < -40 ? "#F59E0B" : offset.y > 40 ? "#A78BFA" : "transparent";
  const edgeGlow = Math.min(1, Math.sqrt(offset.x ** 2 + offset.y ** 2) / 120);

  return (
    <>
      {burst && <ParticleBurst x={burst.x} y={burst.y} onDone={() => setBurst(null)} />}
      <div
        ref={cardRef}
        onMouseDown={e => startDrag(e.clientX, e.clientY)}
        onMouseMove={e => dragging && moveDrag(e.clientX, e.clientY)}
        onMouseUp={e => { endDrag(e.clientX, e.clientY); }}
        onMouseLeave={e => { if (dragging) endDrag(e.clientX, e.clientY); }}
        onTouchStart={e => startDrag(e.touches[0].clientX, e.touches[0].clientY)}
        onTouchMove={e => moveDrag(e.touches[0].clientX, e.touches[0].clientY)}
        onTouchEnd={e => endDrag(e.changedTouches[0].clientX, e.changedTouches[0].clientY)}
        onClick={handleTap}
        style={{
          position: "absolute", top: "50%", left: "50%",
          width: "min(380px, 90vw)", minHeight: 420,
          transform: flyTransform || `translate(-50%, -50%) translate(${offset.x}px, ${offset.y}px) rotate(${dragRotate}deg)`,
          transition: flyDir ? "transform 0.35s cubic-bezier(0.4,0,1,1), opacity 0.35s" : dragging ? "none" : "transform 0.4s cubic-bezier(0.34,1.56,0.64,1)",
          opacity: flyDir ? 0 : dragOpacity,
          cursor: dragging ? "grabbing" : "grab",
          userSelect: "none", zIndex: 10,
          borderRadius: 28,
          background: "linear-gradient(145deg, #1c1c22, #161618)",
          border: `1px solid rgba(255,255,255,0.07)`,
          boxShadow: edgeColor !== "transparent"
            ? `0 0 0 2px ${edgeColor}${Math.round(edgeGlow * 255).toString(16).padStart(2,'0')}, 0 32px 80px rgba(0,0,0,0.6)`
            : "0 32px 80px rgba(0,0,0,0.6), 0 0 0 1px rgba(255,255,255,0.05)",
          display: "flex", flexDirection: "column", padding: "36px 32px 28px",
          boxSizing: "border-box",
        }}
      >
        {/* Category badge */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 32 }}>
          <span style={{
            fontSize: 11, fontFamily: "'DM Sans', sans-serif", fontWeight: 600,
            letterSpacing: "0.12em", textTransform: "uppercase",
            color: meta.color, background: meta.bg,
            padding: "5px 12px", borderRadius: 20,
          }}>
            {meta.label}
          </span>
          <span style={{ fontSize: 11, color: "rgba(255,255,255,0.25)", fontFamily: "'DM Sans', sans-serif" }}>
            {meta.dir}
          </span>
        </div>

        {/* Quote text */}
        <div style={{ flex: 1, display: "flex", alignItems: "center" }}>
          <blockquote style={{
            margin: 0, padding: 0,
            fontFamily: "'Playfair Display', Georgia, serif",
            fontSize: "clamp(18px, 4vw, 24px)",
            fontWeight: 400, fontStyle: "italic",
            lineHeight: 1.65,
            color: "#F5F0E8",
            letterSpacing: "-0.01em",
          }}>
            <span style={{ color: meta.color, fontSize: "2em", lineHeight: 0.3, verticalAlign: "-0.3em", marginRight: 4, fontStyle: "normal" }}>"</span>
            {quote.text}
            <span style={{ color: meta.color, fontSize: "2em", lineHeight: 0.3, verticalAlign: "-0.3em", marginLeft: 4, fontStyle: "normal" }}>"</span>
          </blockquote>
        </div>

        {/* Author */}
        <div style={{ marginTop: 28, marginBottom: 24 }}>
          <div style={{ width: 32, height: 1, background: meta.color, opacity: 0.5, marginBottom: 10 }} />
          <p style={{
            margin: 0, fontFamily: "'DM Sans', sans-serif",
            fontSize: 13, fontWeight: 500,
            color: "rgba(255,255,255,0.45)", letterSpacing: "0.05em",
          }}>
            — {quote.author}
          </p>
        </div>

        {/* Actions */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", paddingTop: 20, borderTop: "1px solid rgba(255,255,255,0.06)" }}>
          <button onClick={e => { e.stopPropagation(); onLike(quote.id); }} style={actionBtn(isLiked ? "#F97316" : "rgba(255,255,255,0.2)")}>
            <HeartIcon filled={isLiked} size={19} />
          </button>
          <p style={{ margin: 0, fontFamily: "'DM Sans', sans-serif", fontSize: 11, color: "rgba(255,255,255,0.18)", letterSpacing: "0.08em" }}>
            DOUBLE TAP TO LIKE
          </p>
          <div style={{ display: "flex", gap: 8 }}>
            <button onClick={e => { e.stopPropagation(); onSave(quote); }} style={actionBtn(isSaved ? "#14B8A6" : "rgba(255,255,255,0.2)")}>
              <BookmarkIcon filled={isSaved} size={19} />
            </button>
            <button onClick={e => { e.stopPropagation(); onShare(quote); }} style={actionBtn("rgba(255,255,255,0.2)")}>
              <ShareIcon size={19} />
            </button>
          </div>
        </div>
      </div>

      {/* Swipe direction labels */}
      {swipeHint && !dragging && !flyDir && <SwipeHints />}
    </>
  );
}

function SwipeHints() {
  return (
    <>
      {[
        { dir: "up",    label: "Philosophy", color: "#F59E0B", style: { top: 16, left: "50%", transform: "translateX(-50%)" } },
        { dir: "down",  label: "Reflection", color: "#A78BFA", style: { bottom: 100, left: "50%", transform: "translateX(-50%)" } },
        { dir: "left",  label: "Stoicism",   color: "#14B8A6", style: { left: 12, top: "50%", transform: "translateY(-50%)" } },
        { dir: "right", label: "Discipline", color: "#F97316", style: { right: 12, top: "50%", transform: "translateY(-50%)" } },
      ].map(h => (
        <div key={h.dir} style={{
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

const actionBtn = (color) => ({
  background: "none", border: "none", cursor: "pointer",
  color, padding: 8, borderRadius: 12,
  display: "flex", alignItems: "center", justifyContent: "center",
  transition: "transform 0.15s, opacity 0.15s",
});

/* ─── VAULT SHEET ────────────────────────────────────────────────────────────── */
function VaultSheet({ items, onClose, onRemove }) {
  return (
    <div style={{
      position: "fixed", inset: 0, zIndex: 100,
      background: "rgba(0,0,0,0.7)",
      display: "flex", alignItems: "flex-end",
      animation: "fade-in 0.2s ease",
    }} onClick={onClose}>
      <div onClick={e => e.stopPropagation()} style={{
        width: "100%", maxHeight: "78vh",
        background: "#18181f",
        borderRadius: "28px 28px 0 0",
        border: "1px solid rgba(255,255,255,0.07)",
        display: "flex", flexDirection: "column",
        animation: "slide-up 0.3s cubic-bezier(0.34,1.56,0.64,1)",
        overflow: "hidden",
      }}>
        {/* Handle */}
        <div style={{ display: "flex", justifyContent: "center", padding: "16px 0 0" }}>
          <div style={{ width: 40, height: 4, borderRadius: 2, background: "rgba(255,255,255,0.15)" }} />
        </div>

        {/* Header */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "16px 28px 12px" }}>
          <div>
            <h2 style={{ margin: 0, fontFamily: "'Playfair Display', serif", fontSize: 22, fontWeight: 600, color: "#F5F0E8" }}>
              Vault
            </h2>
            <p style={{ margin: "2px 0 0", fontFamily: "'DM Sans', sans-serif", fontSize: 12, color: "rgba(255,255,255,0.3)" }}>
              {items.length} saved reflection{items.length !== 1 ? "s" : ""}
            </p>
          </div>
          <button onClick={onClose} style={{ ...actionBtn("rgba(255,255,255,0.3)"), border: "1px solid rgba(255,255,255,0.1)", borderRadius: 20, padding: "8px 14px", fontSize: 13, fontFamily: "'DM Sans', sans-serif" }}>
            Close
          </button>
        </div>

        {/* List */}
        <div style={{ overflowY: "auto", flex: 1, padding: "0 20px 32px" }}>
          {items.length === 0 ? (
            <div style={{ textAlign: "center", padding: "60px 20px", color: "rgba(255,255,255,0.2)", fontFamily: "'DM Sans', sans-serif", fontSize: 14 }}>
              <div style={{ fontSize: 32, marginBottom: 12 }}>🔮</div>
              Save quotes to build your vault
            </div>
          ) : items.map(q => {
            const meta = CATEGORY_META[q.category];
            return (
              <div key={q.id} style={{
                background: "#1e1e27", borderRadius: 16,
                padding: "18px 20px", marginBottom: 12,
                border: "1px solid rgba(255,255,255,0.05)",
                display: "flex", gap: 14, alignItems: "flex-start",
              }}>
                <div style={{ width: 3, minHeight: 40, borderRadius: 2, background: meta.color, flexShrink: 0, marginTop: 2 }} />
                <div style={{ flex: 1 }}>
                  <p style={{ margin: "0 0 8px", fontFamily: "'Playfair Display', serif", fontSize: 14, fontStyle: "italic", color: "#E8E3D8", lineHeight: 1.6 }}>
                    "{q.text}"
                  </p>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                    <span style={{ fontFamily: "'DM Sans', sans-serif", fontSize: 11, color: "rgba(255,255,255,0.35)" }}>
                      — {q.author}
                    </span>
                    <span style={{ fontSize: 10, color: meta.color, fontFamily: "'DM Sans', sans-serif", fontWeight: 600, letterSpacing: "0.1em", textTransform: "uppercase" }}>
                      {q.category}
                    </span>
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

/* ─── PERSISTENCE ────────────────────────────────────────────────────────────── */
const STORAGE_KEY = "mindscroll_state";

function saveState(state) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch (_) {}
}

function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch (_) {
    return null;
  }
}

/* ─── LANGUAGE DETECTION ─────────────────────────────────────────────────────── */
const USER_LANG = (typeof navigator !== "undefined"
  ? navigator.language.slice(0, 2)
  : "en") || "en";

/* ─── API LAYER — Quotable.io ────────────────────────────────────────────────── */
const QUOTABLE_BASE = "https://api.quotable.io";
const PER_CATEGORY  = 8; // quotes per category per page = 32 total per fetch

async function fetchQuotes(page = 1, lang = USER_LANG) {
  // Spanish: use static curated dataset (no external API needed)
  if (lang === "es") {
    return { quotes: shuffle([...QUOTES_ES]), nextPage: null };
  }

  // English (and any other lang): fetch from Quotable.io
  const categories = Object.keys(CATEGORY_TAGS);
  try {
    const results = await Promise.all(
      categories.map(cat =>
        fetch(`${QUOTABLE_BASE}/quotes?tags=${CATEGORY_TAGS[cat]}&page=${page}&limit=${PER_CATEGORY}`)
          .then(r => { if (!r.ok) throw new Error(r.status); return r.json(); })
      )
    );

    const quotes = results.flatMap((result, i) =>
      (result.results ?? []).map(q => ({
        id:       q._id,
        text:     q.content,
        author:   q.author,
        category: categories[i],
        dir:      CATEGORY_TO_DIR[categories[i]],
        lang:     "en",
      }))
    );

    const hasMore = results.some(r => r.page < r.totalPages);
    return { quotes: shuffle(quotes), nextPage: hasMore ? page + 1 : null };
  } catch {
    // Offline / API down — fall back to bundled EN quotes
    return { quotes: shuffle(QUOTES.map(q => ({ ...q, lang: "en" }))), nextPage: null };
  }
}

/* ─── SHARE ──────────────────────────────────────────────────────────────────── */
async function shareQuote(quote, showToast) {
  const text = `"${quote.text}" — ${quote.author}`;
  if (navigator.share) {
    try {
      await navigator.share({ title: "MindScroll", text });
    } catch (err) {
      if (err.name !== "AbortError") showToast("Share failed", "#EF4444");
    }
  } else {
    try {
      await navigator.clipboard.writeText(text);
      showToast("Copied to clipboard", "#14B8A6");
    } catch (_) {
      showToast("Could not copy", "#EF4444");
    }
  }
}

/* ─── MAIN APP ───────────────────────────────────────────────────────────────── */
export default function MindScroll() {
  const [deck, setDeck]       = useState([]);
  const [loading, setLoading] = useState(true);
  const [current, setCurrent] = useState(0);
  const pageRef      = useRef(1);
  const loadingMore  = useRef(false);
  const [liked, setLiked] = useState(() => {
    const saved = loadState();
    return new Set(saved?.liked ?? []);
  });
  const [vault, setVault] = useState(() => loadState()?.vault ?? []);
  const [showVault, setShowVault] = useState(false);
  const [streak, setStreak] = useState(() => loadState()?.streak ?? 0);
  const [reflections, setReflections] = useState(() => loadState()?.reflections ?? 0);
  const [showHints, setShowHints] = useState(true);
  const [swipeCounts, setSwipeCounts] = useState({ philosophy: 0, stoicism: 0, discipline: 0, reflection: 0 });
  const [toastMsg, setToastMsg] = useState(null);
  const toastTimer = useRef(null);
  const [streakPulse, setStreakPulse] = useState(false);
  const [lastSwipeDir, setLastSwipeDir] = useState(null);

  // Initial load from API (or static ES dataset)
  useEffect(() => {
    fetchQuotes(1, USER_LANG).then(({ quotes, nextPage }) => {
      setDeck(quotes);
      pageRef.current = nextPage;
      setLoading(false);
    });
  }, []);

  // Load more when 5 cards from the end (EN only — ES is fully static)
  useEffect(() => {
    if (!loadingMore.current && pageRef.current && deck.length > 0 && current >= deck.length - 5) {
      loadingMore.current = true;
      fetchQuotes(pageRef.current, USER_LANG).then(({ quotes, nextPage }) => {
        setDeck(prev => [...prev, ...quotes]);
        pageRef.current = nextPage;
        loadingMore.current = false;
      });
    }
  }, [current, deck.length]);

  // Persist on every change to the four stateful pieces
  useEffect(() => {
    saveState({
      liked: [...liked],
      vault,
      streak,
      reflections,
    });
  }, [liked, vault, streak, reflections]);

  const showToast = useCallback((msg, color = "#14B8A6") => {
    clearTimeout(toastTimer.current);
    setToastMsg({ msg, color });
    toastTimer.current = setTimeout(() => setToastMsg(null), 2200);
  }, []);

  const handleSwipe = useCallback((dir) => {
    const cat = DIR_TO_CATEGORY[dir];
    setSwipeCounts(prev => ({ ...prev, [cat]: (prev[cat] || 0) + 1 }));
    setLastSwipeDir(dir);
    setShowHints(false);

    // Every 5 reflections = streak
    setReflections(r => {
      const next = r + 1;
      if (next % 5 === 0) {
        setStreak(s => s + 1);
        setStreakPulse(true);
        setTimeout(() => setStreakPulse(false), 1000);
        showToast("🔥 Streak extended!", "#F59E0B");
      }
      return next;
    });

    setCurrent(c => c + 1);
  }, [showToast]);

  const handleLike = useCallback((id) => {
    setLiked(prev => {
      const next = new Set(prev);
      if (next.has(id)) { next.delete(id); showToast("Removed like"); }
      else { next.add(id); showToast("♥ Liked"); }
      return next;
    });
  }, [showToast]);

  const handleSave = useCallback((q) => {
    setVault(prev => {
      if (prev.find(v => v.id === q.id)) {
        showToast("Already in vault", "#F59E0B");
        return prev;
      }
      showToast("✦ Saved to vault", "#14B8A6");
      return [q, ...prev];
    });
  }, [showToast]);

  const handleRemove = useCallback((id) => {
    setVault(prev => prev.filter(v => v.id !== id));
  }, []);

  const quote = deck[current % deck.length];
  const meta  = CATEGORY_META[quote?.category] || CATEGORY_META.reflection;

  if (loading) return (
    <div style={{
      width: "100%", minHeight: "100vh", background: "#0f0f13",
      display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 16,
    }}>
      <style>{`@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:ital@1&display=swap');`}</style>
      <p style={{ fontFamily: "'Playfair Display', serif", fontStyle: "italic", fontSize: 22, color: "#F5F0E8", margin: 0 }}>
        Mind<span style={{ color: "#14B8A6" }}>Scroll</span>
      </p>
      <p style={{ fontFamily: "sans-serif", fontSize: 12, color: "rgba(255,255,255,0.25)", margin: 0, letterSpacing: "0.1em" }}>
        LOADING REFLECTIONS...
      </p>
    </div>
  );

  return (
    <div style={{
      width: "100%", minHeight: "100vh",
      background: "#0f0f13",
      position: "relative", overflow: "hidden",
      fontFamily: "'DM Sans', sans-serif",
    }}>
      {/* Google Fonts */}
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;1,400;1,600&family=DM+Sans:wght@400;500;600&display=swap');
        @keyframes fade-in { from { opacity:0 } to { opacity:1 } }
        @keyframes slide-up { from { transform:translateY(100%) } to { transform:translateY(0) } }
        @keyframes hint-pulse { 0%,100%{opacity:0.25} 50%{opacity:0.5} }
        @keyframes streak-pulse { 0%,100%{transform:scale(1)} 50%{transform:scale(1.25)} }
        @keyframes toast-in { 0%{opacity:0;transform:translateX(-50%) translateY(10px)} 100%{opacity:1;transform:translateX(-50%) translateY(0)} }
        @keyframes particle-burst {
          0%   { transform:translate(-50%,-50%) translate(0,0) scale(1); opacity:1; }
          100% { transform:translate(-50%,-50%) translate(var(--tx),var(--ty)) scale(0); opacity:0; }
        }
        * { box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
        button:hover { opacity: 0.8; }
        ::-webkit-scrollbar { width: 4px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.1); border-radius: 2px; }
      `}</style>

      {/* Ambient background glow — shifts with category */}
      <div style={{
        position: "fixed", inset: 0, pointerEvents: "none", zIndex: 0,
        background: `radial-gradient(ellipse 60% 50% at 50% 100%, ${meta.color}18 0%, transparent 70%)`,
        transition: "background 0.8s ease",
      }} />

      {/* ── HEADER ── */}
      <header style={{
        position: "relative", zIndex: 20,
        display: "flex", justifyContent: "space-between", alignItems: "center",
        padding: "20px 24px 0",
      }}>
        {/* Logo */}
        <div>
          <h1 style={{ margin: 0, fontSize: 18, fontWeight: 600, fontFamily: "'Playfair Display', serif", color: "#F5F0E8", letterSpacing: "-0.02em" }}>
            Mind<span style={{ color: meta.color, transition: "color 0.4s" }}>Scroll</span>
          </h1>
        </div>

        {/* Streak + Reflections */}
        <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
          <div style={{
            display: "flex", alignItems: "center", gap: 6,
            background: "rgba(245,158,11,0.1)", border: "1px solid rgba(245,158,11,0.2)",
            borderRadius: 20, padding: "6px 12px",
            animation: streakPulse ? "streak-pulse 0.4s ease" : "none",
          }}>
            <FireIcon size={15} />
            <span style={{ fontSize: 13, fontWeight: 600, color: "#F59E0B" }}>{streak}</span>
          </div>
          <div style={{
            display: "flex", alignItems: "center", gap: 6,
            background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.08)",
            borderRadius: 20, padding: "6px 12px",
          }}>
            <span style={{ fontSize: 13, color: "rgba(255,255,255,0.5)" }}>✦</span>
            <span style={{ fontSize: 13, fontWeight: 600, color: "rgba(255,255,255,0.7)" }}>{reflections}</span>
          </div>
        </div>
      </header>

      {/* ── CATEGORY STATS BAR ── */}
      <div style={{ position: "relative", zIndex: 20, paddingTop: 16 }}>
        <CategoryStats counts={swipeCounts} />
      </div>

      {/* ── CARD STACK ── */}
      <div style={{ position: "relative", zIndex: 10, height: "calc(100vh - 200px)", minHeight: 480 }}>
        {/* Ghost card behind (next) */}
        {deck[(current + 1) % deck.length] && (
          <div style={{
            position: "absolute", top: "50%", left: "50%",
            transform: "translate(-50%, calc(-50% + 12px)) scale(0.94)",
            width: "min(380px, 90vw)", height: 420,
            background: "#1a1a21", borderRadius: 28,
            border: "1px solid rgba(255,255,255,0.04)",
            zIndex: 9,
          }} />
        )}

        {/* Main card */}
        {quote && (
          <QuoteCard
            key={current}
            quote={quote}
            onSwipe={handleSwipe}
            onLike={handleLike}
            onSave={handleSave}
            onShare={(q) => shareQuote(q, showToast)}
            isLiked={liked.has(quote.id)}
            isSaved={vault.some(v => v.id === quote.id)}
            swipeHint={showHints}
          />
        )}
      </div>

      {/* ── BOTTOM NAV ── */}
      <nav style={{
        position: "fixed", bottom: 0, left: 0, right: 0, zIndex: 30,
        display: "flex", justifyContent: "space-around", alignItems: "center",
        padding: "14px 32px 24px",
        background: "linear-gradient(to top, #0f0f13 60%, transparent)",
      }}>
        {/* Direction legend */}
        <div style={{ display: "flex", gap: 6 }}>
          {Object.entries(CATEGORY_META).map(([cat, m]) => (
            <div key={cat} title={m.label} style={{
              width: 8, height: 8, borderRadius: "50%",
              background: swipeCounts[cat] > 0 ? m.color : "rgba(255,255,255,0.12)",
              transition: "background 0.3s",
            }} />
          ))}
        </div>

        {/* Vault button */}
        <button
          onClick={() => setShowVault(true)}
          style={{
            background: vault.length > 0 ? "rgba(20,184,166,0.12)" : "rgba(255,255,255,0.05)",
            border: `1px solid ${vault.length > 0 ? "rgba(20,184,166,0.3)" : "rgba(255,255,255,0.08)"}`,
            borderRadius: 22, padding: "10px 20px",
            display: "flex", alignItems: "center", gap: 8,
            cursor: "pointer", color: vault.length > 0 ? "#14B8A6" : "rgba(255,255,255,0.4)",
            fontFamily: "'DM Sans', sans-serif", fontSize: 13, fontWeight: 500,
            transition: "all 0.2s",
          }}
        >
          <BookmarkIcon size={16} filled={vault.length > 0} />
          Vault {vault.length > 0 && <span style={{ background: "#14B8A6", color: "#0f0f13", borderRadius: 10, padding: "1px 6px", fontSize: 11, fontWeight: 700 }}>{vault.length}</span>}
        </button>

        {/* Cards count */}
        <span style={{ fontSize: 11, color: "rgba(255,255,255,0.2)", fontFamily: "'DM Sans', sans-serif" }}>
          {(current % deck.length) + 1} / {deck.length}
        </span>
      </nav>

      {/* ── VAULT SHEET ── */}
      {showVault && <VaultSheet items={vault} onClose={() => setShowVault(false)} onRemove={handleRemove} />}

      {/* ── TOAST ── */}
      {toastMsg && (
        <div style={{
          position: "fixed", bottom: 100, left: "50%",
          transform: "translateX(-50%)",
          background: "#1e1e27", border: `1px solid ${toastMsg.color}40`,
          borderRadius: 24, padding: "10px 20px",
          fontFamily: "'DM Sans', sans-serif", fontSize: 13, fontWeight: 500,
          color: toastMsg.color, zIndex: 200, whiteSpace: "nowrap",
          animation: "toast-in 0.25s ease",
          boxShadow: `0 8px 32px rgba(0,0,0,0.4)`,
        }}>
          {toastMsg.msg}
        </div>
      )}
    </div>
  );
}

function shuffle(arr) {
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}
