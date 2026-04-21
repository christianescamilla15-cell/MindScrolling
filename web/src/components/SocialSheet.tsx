import { CATEGORY_META } from "../constants";
import type { CategoryKey, QuoteOfDay, SocialFeedItem, SocialStreak } from "../types";

const ACTION_LABEL: Record<SocialFeedItem["action"], string> = {
  like:  "liked",
  save:  "saved to vault",
  share: "shared",
};

interface Props {
  streak: SocialStreak | null;
  qotd: QuoteOfDay | null;
  feed: SocialFeedItem[];
  /** Backend returns this when the user follows nobody — we surface it as
   *  the empty-state CTA. */
  emptyMessage?: string;
  onClose: () => void;
}

function formatTime(iso: string): string {
  try {
    const d = new Date(iso);
    const now = Date.now();
    const diffMin = Math.floor((now - d.getTime()) / 60000);
    if (diffMin < 1)   return "just now";
    if (diffMin < 60)  return `${diffMin}m ago`;
    if (diffMin < 1440) return `${Math.floor(diffMin / 60)}h ago`;
    return d.toLocaleDateString(undefined, { month: "short", day: "numeric" });
  } catch {
    return "";
  }
}

/**
 * Bottom-sheet body for /social. Stays in /components/ rather than inline so
 * it can be re-mounted as an in-page overlay later if we want the same
 * "tap-to-dismiss-on-feed" UX as Settings.
 */
export default function SocialSheet({ streak, qotd, feed, emptyMessage, onClose }: Props) {
  const qotdMeta = qotd?.quote?.category
    ? CATEGORY_META[qotd.quote.category as CategoryKey]
    : CATEGORY_META.reflection;

  return (
    <div
      onClick={onClose}
      className="fixed inset-0 z-[100] bg-black/70 flex items-end animate-fade-in"
    >
      <div
        onClick={(e) => e.stopPropagation()}
        className="w-full max-h-[88vh] bg-mindscroll-bg-soft rounded-t-[28px] border border-white/[0.07] flex flex-col animate-slide-up overflow-hidden"
      >
        <div className="flex justify-center pt-4">
          <div className="w-10 h-1 rounded-sm bg-white/[0.15]" />
        </div>

        {/* Header */}
        <div className="flex justify-between items-center pt-4 pb-3 px-7">
          <div>
            <h2 className="m-0 font-serif text-[22px] font-semibold text-mindscroll-cream">
              Social
            </h2>
            <p className="mt-0.5 mb-0 font-sans text-xs text-white/30">
              {feed.length} recent {feed.length === 1 ? "moment" : "moments"} from people you follow
            </p>
          </div>
          <button
            onClick={onClose}
            className="bg-transparent border border-white/10 rounded-[20px] py-2 px-3.5 text-[13px] font-sans text-white/30 cursor-pointer"
          >
            Close
          </button>
        </div>

        <div className="overflow-y-auto flex-1 px-5 pb-8">
          {/* Streak card */}
          {streak && (
            <div className="mt-2 mb-5 bg-mindscroll-amber/10 border border-mindscroll-amber/25 rounded-2xl py-4 px-5 flex items-center justify-between">
              <div>
                <p className="m-0 font-sans text-[11px] font-semibold tracking-[0.12em] uppercase text-mindscroll-amber">
                  Streak
                </p>
                <p className="mt-1 mb-0 font-serif text-[26px] font-semibold text-mindscroll-cream">
                  {streak.streak} day{streak.streak === 1 ? "" : "s"}
                </p>
                <p className="mt-1 mb-0 font-sans text-xs text-white/40">
                  Longest: {streak.longest} · {streak.active_today ? "Active today ✓" : "Open the app daily to keep it"}
                </p>
              </div>
              <div className="text-[40px] leading-none">
                {streak.active_today ? "🔥" : "·"}
              </div>
            </div>
          )}

          {/* Quote of the day */}
          {qotd?.quote && (
            <>
              <p className="m-0 mb-2 font-sans text-[11px] font-semibold tracking-[0.12em] uppercase text-white/40">
                Quote of the day
              </p>
              <div
                className="mb-6 rounded-2xl py-5 px-5 border bg-gradient-to-br from-mindscroll-bg-card to-mindscroll-bg-card-end"
                style={{ borderColor: `${qotdMeta.color}33` }}
              >
                <blockquote className="m-0 font-serif italic text-[17px] leading-[1.55] text-mindscroll-cream">
                  <span className="text-[2em] leading-[0.3] align-[-0.3em] mr-1 not-italic" style={{ color: qotdMeta.color }}>&ldquo;</span>
                  {qotd.quote.text}
                  <span className="text-[2em] leading-[0.3] align-[-0.3em] ml-1 not-italic" style={{ color: qotdMeta.color }}>&rdquo;</span>
                </blockquote>
                <p className="mt-3 mb-0 font-sans text-[12px] text-white/45 tracking-[0.05em]">
                  — {qotd.quote.author}
                </p>
              </div>
            </>
          )}

          {/* Feed */}
          <p className="m-0 mb-2 font-sans text-[11px] font-semibold tracking-[0.12em] uppercase text-white/40">
            Activity
          </p>
          {feed.length === 0 ? (
            <div className="text-center py-[60px] px-5 text-white/20 font-sans text-sm">
              <div className="text-[32px] mb-3">·</div>
              {emptyMessage ?? "When friends like or save quotes, you'll see it here."}
            </div>
          ) : (
            feed.map(item => {
              const cat = item.quote.category as CategoryKey | undefined;
              const meta = cat ? CATEGORY_META[cat] : null;
              return (
                <div
                  key={item.id}
                  className="bg-[#1e1e27] rounded-2xl py-4 px-5 mb-3 border border-white/[0.05] flex gap-3.5 items-start"
                >
                  {meta && (
                    <div
                      className="w-[3px] min-h-10 rounded-sm shrink-0 mt-0.5"
                      style={{ background: meta.color }}
                    />
                  )}
                  <div className="flex-1 min-w-0">
                    <p className="m-0 mb-1.5 font-sans text-[12px] text-white/50">
                      <span className="text-mindscroll-cream font-semibold">{item.user}</span>{" "}
                      {ACTION_LABEL[item.action]} a quote
                    </p>
                    {item.quote.text && (
                      <p className="m-0 mb-1.5 font-serif italic text-sm text-mindscroll-cream-warm leading-[1.5] line-clamp-3">
                        &ldquo;{item.quote.text}&rdquo;
                      </p>
                    )}
                    <div className="flex justify-between items-center">
                      {item.quote.author && (
                        <span className="font-sans text-[11px] text-white/35">— {item.quote.author}</span>
                      )}
                      <span className="font-sans text-[10px] text-white/30">
                        {formatTime(item.at)}
                      </span>
                    </div>
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>
    </div>
  );
}
