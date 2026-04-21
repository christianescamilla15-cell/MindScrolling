import { t } from "../i18n";
import type { ChallengeData, ChallengeProgress, Lang } from "../types";

const DEFAULT_CHALLENGE: ChallengeData = {
  id:          "offline_default",
  code:        "complete_eight_swipes",
  title:       "Daily Reflection",
  description: "Swipe 8 quotes with intention today.",
  target:      8,
};

interface ProgressRingProps {
  value: number;
  target: number;
  color?: string;
}

function ProgressRing({ value, target, color = "#14B8A6" }: ProgressRingProps) {
  const pct       = Math.min(1, value / Math.max(1, target));
  const radius    = 28;
  const stroke    = 4;
  const normalizedR = radius - stroke / 2;
  const circ      = 2 * Math.PI * normalizedR;
  const dash      = circ * pct;

  return (
    <svg width={radius * 2} height={radius * 2} className="-rotate-90">
      <circle cx={radius} cy={radius} r={normalizedR} fill="none" stroke="rgba(255,255,255,0.06)" strokeWidth={stroke} />
      <circle
        cx={radius} cy={radius} r={normalizedR}
        fill="none" stroke={color} strokeWidth={stroke} strokeLinecap="round"
        strokeDasharray={`${dash} ${circ}`}
        style={{ transition: "stroke-dasharray 0.5s ease" }}
      />
    </svg>
  );
}

interface Props {
  challenge: ChallengeData | null | undefined;
  progress: ChallengeProgress | null | undefined;
  lang?: Lang;
  onClose: () => void;
}

export default function DailyChallenge({ challenge, progress, lang = "en", onClose }: Props) {
  const ch       = challenge || DEFAULT_CHALLENGE;
  const target   = ch.target ?? 8;
  const current  = progress?.progress ?? 0;
  const done     = progress?.completed ?? false;
  const pct      = Math.min(100, Math.round((current / Math.max(1, target)) * 100));

  const accentColor = done ? "#14B8A6" : "#F59E0B";

  return (
    <div
      onClick={onClose}
      className="fixed inset-0 z-[300] bg-black/75 flex items-end animate-fade-in"
    >
      <div
        onClick={(e) => e.stopPropagation()}
        className="w-full bg-mindscroll-bg-soft rounded-t-[28px] border border-white/[0.07] animate-slide-up overflow-hidden"
      >
        {/* Handle */}
        <div className="flex justify-center pt-4">
          <div className="w-10 h-1 rounded-sm bg-white/[0.15]" />
        </div>

        <div className="pt-5 pb-12 px-7">
          {/* Header row */}
          <div className="flex justify-between items-start mb-7">
            <div className="flex-1">
              <p
                className="mt-0 mb-1 font-sans text-[11px] font-semibold tracking-[0.12em] uppercase"
                style={{ color: accentColor }}
              >
                {t(lang, "challenge_title")}
              </p>
              <h2 className="m-0 font-serif text-[22px] font-semibold text-mindscroll-cream">
                {ch.title}
              </h2>
            </div>

            {/* Progress ring or checkmark */}
            <div className="shrink-0 ml-4 flex items-center justify-center">
              {done ? (
                <div className="w-14 h-14 bg-mindscroll-teal/15 border-2 border-mindscroll-teal/50 rounded-full flex items-center justify-center text-[22px]">
                  ✓
                </div>
              ) : (
                <div className="relative w-14 h-14 flex items-center justify-center">
                  <ProgressRing value={current} target={target} color={accentColor} />
                  <span
                    className="absolute font-sans text-xs font-bold"
                    style={{ color: accentColor }}
                  >
                    {pct}%
                  </span>
                </div>
              )}
            </div>
          </div>

          {/* Description */}
          <p className="mt-0 mb-6 font-sans text-[15px] text-white/55 leading-[1.65]">
            {ch.description}
          </p>

          {/* Progress bar */}
          <div className="mb-7">
            <div className="flex justify-between mb-2">
              <span className="font-sans text-xs text-white/30">Progress</span>
              <span
                className="font-sans text-xs font-semibold"
                style={{ color: accentColor }}
              >
                {current} / {target}
              </span>
            </div>
            <div className="h-1.5 rounded-[3px] bg-white/[0.06] overflow-hidden">
              <div
                className="h-full rounded-[3px] transition-[width] duration-700 ease-out"
                style={{
                  width: `${pct}%`,
                  background: `linear-gradient(90deg, ${accentColor}cc, ${accentColor})`,
                }}
              />
            </div>
          </div>

          {/* Done message */}
          {done && (
            <div className="bg-mindscroll-teal/10 border border-mindscroll-teal/25 rounded-xl py-3 px-4 mb-5 font-sans text-[13px] text-mindscroll-teal text-center">
              Challenge complete! Come back tomorrow for a new one.
            </div>
          )}

          {/* Close */}
          <button
            onClick={onClose}
            className="w-full py-3.5 bg-white/[0.04] border border-white/[0.08] rounded-2xl text-sm font-sans font-medium text-white/40 cursor-pointer"
          >
            {t(lang, "close")}
          </button>
        </div>
      </div>
    </div>
  );
}
