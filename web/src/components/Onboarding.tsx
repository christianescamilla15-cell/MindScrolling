import { useState } from "react";
import { apiSaveProfile } from "../api/quotes";
import { t } from "../i18n";
import type { Lang, Profile } from "../types";

const ONBOARDING_KEY = "mindscroll_onboarding";
const PROFILE_KEY    = "mindscroll_profile";

const SELECT = "w-full bg-[#1e1e27] border border-white/[0.12] rounded-xl text-mindscroll-cream font-sans text-sm py-3 px-4 appearance-none cursor-pointer outline-none";
const LABEL  = "block font-sans text-xs font-semibold tracking-[0.08em] uppercase text-white/60 mb-1.5";

interface PrimaryButtonProps {
  children: React.ReactNode;
  onClick: () => void;
  color?: string;
  className?: string;
}

function PrimaryButton({ children, onClick, color = "#14B8A6", className = "" }: PrimaryButtonProps) {
  return (
    <button
      onClick={onClick}
      className={`w-full p-4 rounded-2xl font-sans text-[15px] font-semibold cursor-pointer tracking-[0.04em] transition-all duration-200 border ${className}`}
      style={{
        background: `linear-gradient(135deg, ${color}22, ${color}44)`,
        borderColor: `${color}66`,
        color,
      }}
    >
      {children}
    </button>
  );
}

function ChevronDown() {
  return (
    <span className="absolute right-3.5 top-1/2 -translate-y-1/2 text-white/30 pointer-events-none">▾</span>
  );
}

/* ─── Screen 1: Swipe explanation ─────────────────────────────────────────── */
function ScreenSwipes({ lang, onNext }: { lang: Lang; onNext: () => void }) {
  const directions = [
    { key: "onboarding_swipe_up",    color: "#F59E0B", icon: "↑", label: t(lang, "philosophy") },
    { key: "onboarding_swipe_right", color: "#F97316", icon: "→", label: t(lang, "discipline") },
    { key: "onboarding_swipe_left",  color: "#14B8A6", icon: "←", label: t(lang, "stoicism")   },
    { key: "onboarding_swipe_down",  color: "#A78BFA", icon: "↓", label: t(lang, "reflection") },
  ];

  return (
    <div className="flex flex-col items-center flex-1 px-8 pt-12 pb-8">
      {/* Logo */}
      <h1 className="mt-0 mb-2 font-serif text-[32px] font-semibold text-mindscroll-cream tracking-[-0.02em]">
        Mind<span className="text-mindscroll-teal">Scroll</span>
      </h1>
      <p className="mt-0 mb-12 font-sans text-sm text-white/60 text-center">
        {t(lang, "onboarding_subtitle")}
      </p>

      {/* Direction grid */}
      <div className="w-full max-w-[320px] grid grid-cols-2 gap-3 mb-10">
        {directions.map(d => (
          <div
            key={d.key}
            className="rounded-2xl py-5 px-4 flex flex-col items-center gap-2 animate-hint-pulse border"
            style={{ background: `${d.color}11`, borderColor: `${d.color}33` }}
          >
            <span className="text-[28px] leading-none" style={{ color: d.color }}>{d.icon}</span>
            <span
              className="font-sans text-[11px] font-semibold tracking-[0.1em] uppercase"
              style={{ color: d.color }}
            >
              {d.label}
            </span>
            <span className="font-sans text-xs text-white/70 text-center">
              {t(lang, d.key)}
            </span>
          </div>
        ))}
      </div>

      {/* Swipe graphic hint */}
      <div className="mb-10 flex flex-col items-center gap-1.5">
        <div className="w-15 h-15 bg-gradient-to-br from-mindscroll-bg-card to-mindscroll-bg-card-end border border-white/[0.08] rounded-[18px] flex items-center justify-center text-2xl" style={{ width: 60, height: 60 }}>
          ✦
        </div>
        <p className="m-0 font-sans text-[11px] text-white/55 tracking-[0.08em] uppercase">
          swipe the card
        </p>
      </div>

      <PrimaryButton onClick={onNext}>
        {t(lang, "onboarding_next")} →
      </PrimaryButton>
    </div>
  );
}

/* ─── Screen 2: Profile collection ───────────────────────────────────────── */
function ScreenProfile({ lang, onComplete }: { lang: Lang; onComplete: (p: Profile) => void }) {
  const [profile, setProfile] = useState<Profile>({
    age_range:          "",
    interest:           "",
    goal:               "",
    preferred_language: lang || "en",
  });

  const set = <K extends keyof Profile>(key: K, val: Profile[K]) =>
    setProfile(prev => ({ ...prev, [key]: val }));

  const handleSubmit = () => {
    // Fill defaults if empty
    const finalProfile: Profile = {
      age_range:          profile.age_range          || "25-34",
      interest:           profile.interest           || "philosophy",
      goal:               profile.goal               || "meaning",
      preferred_language: profile.preferred_language || "en",
    };
    onComplete(finalProfile);
  };

  return (
    <div className="flex flex-col flex-1 px-8 pt-12 pb-8">
      <h2 className="mt-0 mb-2 font-serif text-[26px] font-semibold text-mindscroll-cream">
        {t(lang, "onboarding_profile")}
      </h2>
      <p className="mt-0 mb-9 font-sans text-sm text-white/60">
        {t(lang, "onboarding_subtitle")}
      </p>

      <div className="flex flex-col gap-5 flex-1">
        {/* Age range */}
        <div>
          <label className={LABEL}>{t(lang, "age_range")}</label>
          <div className="relative">
            <select value={profile.age_range} onChange={e => set("age_range", e.target.value)} className={SELECT}>
              <option value="">—</option>
              <option value="18-24">18–24</option>
              <option value="25-34">25–34</option>
              <option value="35-44">35–44</option>
              <option value="45+">45+</option>
            </select>
            <ChevronDown />
          </div>
        </div>

        {/* Interest */}
        <div>
          <label className={LABEL}>{t(lang, "interest")}</label>
          <div className="relative">
            <select value={profile.interest} onChange={e => set("interest", e.target.value)} className={SELECT}>
              <option value="">—</option>
              <option value="philosophy">Philosophy</option>
              <option value="stoicism">Stoicism</option>
              <option value="personal_growth">Personal Growth</option>
              <option value="mindfulness">Mindfulness</option>
              <option value="curiosity">Curiosity</option>
            </select>
            <ChevronDown />
          </div>
        </div>

        {/* Goal */}
        <div>
          <label className={LABEL}>{t(lang, "goal")}</label>
          <div className="relative">
            <select value={profile.goal} onChange={e => set("goal", e.target.value)} className={SELECT}>
              <option value="">—</option>
              <option value="calm_mind">Calm Mind</option>
              <option value="discipline">Discipline</option>
              <option value="meaning">Meaning</option>
              <option value="emotional_clarity">Emotional Clarity</option>
            </select>
            <ChevronDown />
          </div>
        </div>

        {/* Language */}
        <div>
          <label className={LABEL}>{t(lang, "language")}</label>
          <div className="relative">
            <select value={profile.preferred_language} onChange={e => set("preferred_language", e.target.value as Lang)} className={SELECT}>
              <option value="en">English</option>
              <option value="es">Espa&ntilde;ol</option>
            </select>
            <ChevronDown />
          </div>
        </div>
      </div>

      <div className="mt-8">
        <PrimaryButton onClick={handleSubmit}>
          {t(lang, "onboarding_start")} ✦
        </PrimaryButton>
      </div>
    </div>
  );
}

/* ─── Screen 3: All set ───────────────────────────────────────────────────── */
function ScreenReady({ onGo }: { lang?: Lang; onGo: () => void }) {
  return (
    <div className="flex flex-col items-center justify-center flex-1 px-8 pt-12 pb-8 text-center">
      <div className="text-[64px] mb-6">✦</div>
      <h2 className="mt-0 mb-3 font-serif text-[28px] font-semibold text-mindscroll-cream">
        You&apos;re all set.
      </h2>
      <p className="mt-0 mb-12 font-sans text-[15px] text-white/70 leading-[1.6]">
        Start scrolling through wisdom.
      </p>
      <PrimaryButton onClick={onGo} className="!max-w-[280px]">
        Let&apos;s go →
      </PrimaryButton>
    </div>
  );
}

/* ─── Main Onboarding component ───────────────────────────────────────────── */
interface OnboardingProps {
  onComplete: (profile: Profile) => void;
  lang?: Lang;
}

export default function Onboarding({ onComplete, lang = "en" }: OnboardingProps) {
  const [screen, setScreen] = useState(0);
  const [profile, setProfile] = useState<Profile | null>(null);

  const handleProfileComplete = (prof: Profile) => {
    setProfile(prof);
    setScreen(2);
  };

  const handleGo = () => {
    const finalProfile: Profile = profile || {
      age_range: "25-34",
      interest: "philosophy",
      goal: "meaning",
      preferred_language: lang,
    };
    // Persist onboarding completion
    try {
      localStorage.setItem(ONBOARDING_KEY, "true");
      localStorage.setItem(PROFILE_KEY, JSON.stringify(finalProfile));
    } catch {
      /* noop */
    }
    // Fire-and-forget API save
    apiSaveProfile(finalProfile).catch(() => {});
    onComplete(finalProfile);
  };

  return (
    <div className="fixed inset-0 z-[500] bg-mindscroll-bg flex flex-col animate-fade-in">
      {/* Progress dots */}
      <div className="flex justify-center gap-2 pt-5">
        {[0, 1, 2].map(i => (
          <div
            key={i}
            className={`h-2 rounded transition-all duration-300 ${
              i === screen ? "w-5 bg-mindscroll-teal" : "w-2 bg-white/[0.12]"
            }`}
          />
        ))}
      </div>

      {screen === 0 && <ScreenSwipes lang={lang} onNext={() => setScreen(1)} />}
      {screen === 1 && <ScreenProfile lang={lang} onComplete={handleProfileComplete} />}
      {screen === 2 && <ScreenReady lang={lang} onGo={handleGo} />}
    </div>
  );
}
