import { t } from "../i18n";
import type { Lang } from "../types";

const FALLBACK_URL = "#";

interface Props {
  lang?: Lang;
  onClose: () => void;
}

export default function DonationPanel({ lang = "en", onClose }: Props) {
  const donationUrl = process.env.NEXT_PUBLIC_DONATION_LINK || FALLBACK_URL;

  const handleCoffee = () => {
    if (donationUrl !== "#") {
      window.open(donationUrl, "_blank", "noopener,noreferrer");
    }
  };

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

        <div className="pt-6 pb-12 px-8 flex flex-col items-center text-center">
          {/* Amber accent icon */}
          <div className="w-[72px] h-[72px] bg-gradient-to-br from-mindscroll-amber/[0.15] to-mindscroll-orange/[0.15] border border-mindscroll-amber/25 rounded-3xl flex items-center justify-center text-[32px] mb-5">
            &#x2615;
          </div>

          <h2 className="mt-0 mb-3 font-serif text-[22px] font-semibold text-mindscroll-cream">
            {t(lang, "donate_title")}
          </h2>

          <p className="mt-0 mb-8 font-sans text-sm text-white/50 leading-[1.7] max-w-[300px]">
            {t(lang, "donate_body")}
          </p>

          {/* Coffee button */}
          <button
            onClick={handleCoffee}
            className="w-full max-w-[320px] p-4 bg-gradient-to-br from-mindscroll-amber/[0.18] to-mindscroll-orange/[0.18] border border-mindscroll-amber/40 rounded-2xl text-mindscroll-amber font-sans text-[15px] font-semibold cursor-pointer tracking-[0.03em] transition-all duration-200 mb-4"
          >
            {t(lang, "donate_btn")}
          </button>

          {/* Close button */}
          <button
            onClick={onClose}
            className="bg-transparent border border-white/10 rounded-xl py-2.5 px-6 text-[13px] font-sans text-white/30 cursor-pointer"
          >
            {t(lang, "close")}
          </button>
        </div>
      </div>
    </div>
  );
}
