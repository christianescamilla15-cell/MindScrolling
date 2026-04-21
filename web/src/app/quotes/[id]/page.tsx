import { notFound } from "next/navigation";
import Link from "next/link";
import type { Metadata } from "next";
import { CATEGORY_META } from "@/constants";
import {
  getQuoteById,
  getQuoteSlugs,
  getRelatedQuotes,
  slugify,
} from "@/lib/quotes-catalog";
import { absUrl } from "@/lib/site";

interface Params {
  id: string;
}

interface PageProps {
  params: Promise<Params>;
}

/** Pre-render every bundled quote at build time (47 pages today). New
 *  backend-sourced quotes can be served via ISR once we have a public
 *  by-slug endpoint — set `dynamicParams = true` then. */
export const dynamicParams = false;

export function generateStaticParams(): Params[] {
  return getQuoteSlugs().map(id => ({ id }));
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { id } = await params;
  const quote = getQuoteById(id);
  if (!quote) return { title: "Quote not found" };

  const title = `"${quote.text.slice(0, 80)}${quote.text.length > 80 ? "…" : ""}" — ${quote.author}`;
  const description = `${quote.author} · ${CATEGORY_META[quote.category]?.label ?? "Reflection"} · MindScrolling.`;
  const url = absUrl(`/quotes/${quote.id}`);

  return {
    title,
    description,
    alternates: { canonical: url },
    openGraph: {
      type: "article",
      title,
      description,
      url,
      locale: quote.lang === "es" ? "es_ES" : "en_US",
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
    },
  };
}

export default async function QuotePage({ params }: PageProps) {
  const { id } = await params;
  const quote = getQuoteById(id);
  if (!quote) notFound();

  const meta = CATEGORY_META[quote.category];
  const authorSlug = slugify(quote.author);
  const related = getRelatedQuotes(id, 3);
  const canonical = absUrl(`/quotes/${quote.id}`);

  // Schema.org Quotation — rich snippet candidate. Inlined as JSON-LD
  // because Next.js metadata API doesn't have a structured-data slot.
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Quotation",
    "@id": canonical,
    text: quote.text,
    creator: {
      "@type": "Person",
      name: quote.author,
      url: absUrl(`/authors/${authorSlug}`),
    },
    inLanguage: quote.lang ?? "en",
    isFamilyFriendly: true,
    url: canonical,
    about: meta?.label,
    publisher: {
      "@type": "Organization",
      name: "MindScrolling",
      url: absUrl("/"),
    },
  };

  return (
    <main className="w-full min-h-screen bg-mindscroll-bg flex flex-col items-center px-6 py-16">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      {/* Wordmark crumb back to / */}
      <Link
        href="/"
        className="mb-12 font-serif italic text-[18px] text-mindscroll-cream/70 hover:text-mindscroll-cream transition-colors"
      >
        Mind<span style={{ color: meta.color }}>Scroll</span>
      </Link>

      {/* Hero quote */}
      <article className="max-w-[640px] w-full">
        <p
          className="m-0 mb-4 font-sans text-[11px] font-semibold tracking-[0.18em] uppercase"
          style={{ color: meta.color }}
        >
          {meta.label}
        </p>

        <blockquote
          className="m-0 mb-8 font-serif italic text-mindscroll-cream leading-[1.5] tracking-[-0.01em]"
          style={{ fontSize: "clamp(28px, 5vw, 44px)" }}
        >
          <span className="text-[1.6em] leading-[0.3] align-[-0.3em] mr-1 not-italic" style={{ color: meta.color }}>&ldquo;</span>
          {quote.text}
          <span className="text-[1.6em] leading-[0.3] align-[-0.3em] ml-1 not-italic" style={{ color: meta.color }}>&rdquo;</span>
        </blockquote>

        <div className="flex items-center gap-3">
          <div className="w-8 h-px opacity-50" style={{ background: meta.color }} />
          <Link
            href={`/authors/${authorSlug}`}
            className="font-sans text-sm font-medium text-white/60 hover:text-mindscroll-cream transition-colors tracking-[0.05em]"
          >
            {quote.author}
          </Link>
        </div>
      </article>

      {/* Related quotes */}
      {related.length > 0 && (
        <section className="max-w-[640px] w-full mt-20">
          <h2 className="m-0 mb-6 font-sans text-[11px] font-semibold tracking-[0.12em] uppercase text-white/30">
            More like this
          </h2>
          <div className="flex flex-col gap-3">
            {related.map(r => {
              const m = CATEGORY_META[r.category];
              return (
                <Link
                  key={r.id}
                  href={`/quotes/${r.id}`}
                  className="bg-mindscroll-bg-soft rounded-2xl py-4 px-5 border border-white/[0.05] flex gap-3.5 items-start hover:border-white/[0.15] transition-colors"
                >
                  <div className="w-[3px] min-h-10 rounded-sm shrink-0 mt-0.5" style={{ background: m.color }} />
                  <div className="flex-1 min-w-0">
                    <p className="m-0 mb-1.5 font-serif italic text-[15px] text-mindscroll-cream-warm leading-[1.5] line-clamp-2">
                      &ldquo;{r.text}&rdquo;
                    </p>
                    <span className="font-sans text-[12px] text-white/40">— {r.author}</span>
                  </div>
                </Link>
              );
            })}
          </div>
        </section>
      )}

      {/* CTA back to feed */}
      <Link
        href="/"
        className="mt-16 rounded-[22px] py-3 px-8 font-sans text-[14px] font-semibold tracking-[0.04em] border bg-white/[0.05] border-white/10 text-white/60 hover:bg-white/[0.08] hover:text-mindscroll-cream transition-all"
      >
        Swipe more reflections →
      </Link>
    </main>
  );
}
