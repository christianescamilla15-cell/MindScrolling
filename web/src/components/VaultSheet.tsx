import { CATEGORY_META } from "../constants";
import { t } from "../i18n";
import type { Lang, Quote } from "../types";

const ACTION_BTN = "bg-transparent border-0 cursor-pointer p-2 rounded-xl flex items-center justify-center transition-[transform,opacity] duration-150";

function XIcon({ size = 18 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
      <line x1="18" y1="6" x2="6" y2="18" />
      <line x1="6" y1="6" x2="18" y2="18" />
    </svg>
  );
}

interface Props {
  items: Quote[];
  onClose: () => void;
  onRemove: (id: string) => void;
  lang: Lang;
}

/**
 * Bottom-sheet listing the user's saved quotes. Used both as the in-app
 * overlay (clicking the backdrop dismisses) and as the body of /vault
 * (where onClose maps to router.back()). The sheet visual stays the same
 * either way — feels native on both contexts.
 */
export default function VaultSheet({ items, onClose, onRemove, lang }: Props) {
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
