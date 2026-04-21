import { t } from "../i18n";
import type { Lang, Toast } from "../types";

const APP_VERSION = "1.0.0";

const ROW = "flex justify-between items-center py-4 border-b border-white/[0.06] cursor-pointer";
const ROW_LABEL = "m-0 font-sans text-[15px] font-medium text-mindscroll-cream";
const ROW_SUB = "mt-0.5 mb-0 font-sans text-xs text-white/30";

function Chevron({ color = "rgba(255,255,255,0.25)" }: { color?: string }) {
  return <span className="text-base leading-none" style={{ color }}>›</span>;
}

function SectionHeader({ children }: { children: React.ReactNode }) {
  return (
    <p className="mt-6 mb-1 font-sans text-[11px] font-semibold tracking-[0.12em] uppercase text-white/25">
      {children}
    </p>
  );
}

interface Props {
  lang: Lang;
  onLangChange: (lang: Lang) => void;
  isPremium: boolean;
  onClose: () => void;
  showToast?: (msg: string, color?: Toast["color"]) => void;
  onShowMap: () => void;
  onShowChallenge: () => void;
  onShowDonation: () => void;
}

export default function Settings({ lang, onLangChange, isPremium, onClose, showToast, onShowMap, onShowChallenge, onShowDonation }: Props) {
  return (
    <div
      onClick={onClose}
      className="fixed inset-0 z-[200] bg-black/70 flex items-end animate-fade-in"
    >
      <div
        onClick={(e) => e.stopPropagation()}
        className="w-full max-h-[86vh] bg-mindscroll-bg-soft rounded-t-[28px] border border-white/[0.07] flex flex-col animate-slide-up overflow-hidden"
      >
        {/* Handle */}
        <div className="flex justify-center pt-4">
          <div className="w-10 h-1 rounded-sm bg-white/[0.15]" />
        </div>

        {/* Header */}
        <div className="flex justify-between items-center pt-4 px-7">
          <h2 className="m-0 font-serif text-[22px] font-semibold text-mindscroll-cream">
            {t(lang, "settings")}
          </h2>
          <button
            onClick={onClose}
            className="bg-transparent border border-white/10 rounded-[20px] py-2 px-3.5 text-[13px] font-sans text-white/30 cursor-pointer"
          >
            {t(lang, "close")}
          </button>
        </div>

        {/* Scrollable body */}
        <div className="overflow-y-auto flex-1 px-7 pb-10">

          {/* Language */}
          <SectionHeader>Preferences</SectionHeader>
          <div className={ROW}>
            <div>
              <p className={ROW_LABEL}>{t(lang, "language")}</p>
              <p className={ROW_SUB}>{lang === "es" ? "Espa\u00F1ol" : "English"}</p>
            </div>
            <div className="flex gap-2">
              {(["en", "es"] as const).map(code => (
                <button
                  key={code}
                  onClick={() => onLangChange(code)}
                  className={`rounded-[10px] py-1.5 px-3 text-[13px] font-sans font-semibold cursor-pointer transition-all duration-150 border ${
                    lang === code
                      ? "bg-mindscroll-teal/15 border-mindscroll-teal/40 text-mindscroll-teal"
                      : "bg-white/[0.05] border-white/10 text-white/40"
                  }`}
                >
                  {code.toUpperCase()}
                </button>
              ))}
            </div>
          </div>

          {/* Explore */}
          <SectionHeader>Explore</SectionHeader>

          <div className={ROW} onClick={onShowMap}>
            <div>
              <p className={ROW_LABEL}>{t(lang, "map_title")}</p>
              <p className={ROW_SUB}>Visualize your thinking style</p>
            </div>
            <Chevron color="#A78BFA" />
          </div>

          <div className={ROW} onClick={onShowChallenge}>
            <div>
              <p className={ROW_LABEL}>{t(lang, "challenge_title")}</p>
              <p className={ROW_SUB}>Today&apos;s reflection challenge</p>
            </div>
            <Chevron color="#F59E0B" />
          </div>

          {/* Premium */}
          <SectionHeader>Premium</SectionHeader>

          {!isPremium ? (
            <div
              onClick={() => showToast && showToast("Premium coming soon!", "#F97316")}
              className="flex justify-between items-center py-4 px-4 mb-3 rounded-2xl cursor-pointer bg-gradient-to-br from-mindscroll-orange/[0.08] to-mindscroll-amber/[0.08] border border-mindscroll-orange/20"
            >
              <div>
                <p className="m-0 font-sans text-[15px] font-medium text-mindscroll-orange">
                  {t(lang, "premium_unlock")}
                </p>
                <p className={ROW_SUB}>Export images, unlock all packs</p>
              </div>
              <span className="font-sans text-[15px] font-bold text-mindscroll-amber">
                {t(lang, "premium_price")}
              </span>
            </div>
          ) : (
            <div className="flex justify-between items-center py-4 border-b border-white/[0.06]">
              <div>
                <p className="m-0 font-sans text-[15px] font-medium text-mindscroll-teal">Premium Active</p>
                <p className={ROW_SUB}>All features unlocked</p>
              </div>
              <span className="text-lg">✦</span>
            </div>
          )}

          {/* Donation */}
          <div className={ROW} onClick={onShowDonation}>
            <div>
              <p className={ROW_LABEL}>{t(lang, "donate_title")}</p>
              <p className={ROW_SUB}>Support the project</p>
            </div>
            <Chevron color="#F59E0B" />
          </div>

          {/* About */}
          <SectionHeader>About</SectionHeader>
          <div className="py-4">
            <p className="mt-0 mb-1 font-serif text-base text-mindscroll-cream">
              Mind<span className="text-mindscroll-teal">Scroll</span>
            </p>
            <p className="mt-0 mb-2 font-sans text-xs text-white/30">
              Version {APP_VERSION}
            </p>
            <p className="m-0 font-sans text-[13px] text-white/35 leading-[1.6]">
              Philosophical wisdom for your daily mind. Swipe, reflect, grow.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
