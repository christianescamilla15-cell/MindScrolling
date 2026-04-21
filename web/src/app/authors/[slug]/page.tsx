import { notFound } from "next/navigation";
import Link from "next/link";
import type { Metadata } from "next";
import { CATEGORY_META } from "@/constants";
import {
  getAuthorBySlug,
  getAuthorSlugs,
  getQuotesByAuthor,
} from "@/lib/quotes-catalog";

interface Params {
  slug: string;
}

interface PageProps {
  params: Promise<Params>;
}

export const dynamicParams = false;

export function generateStaticParams(): Params[] {
  return getAuthorSlugs().map(slug => ({ slug }));
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params;
  const author = getAuthorBySlug(slug);
  if (!author) return { title: "Author not found" };

  const title = `${author.name} — quotes & reflections`;
  const description = `${author.quoteCount} curated quotes by ${author.name} on MindScrolling. Swipe through philosophy, stoicism, and reflection.`;

  return {
    title,
    description,
    openGraph: {
      type: "profile",
      title,
      description,
    },
    twitter: {
      card: "summary",
      title,
      description,
    },
  };
}

export default async function AuthorPage({ params }: PageProps) {
  const { slug } = await params;
  const author = getAuthorBySlug(slug);
  if (!author) notFound();

  const quotes = getQuotesByAuthor(slug);

  return (
    <main className="w-full min-h-screen bg-mindscroll-bg flex flex-col items-center px-6 py-16">
      {/* Wordmark crumb */}
      <Link
        href="/"
        className="mb-12 font-serif italic text-[18px] text-mindscroll-cream/70 hover:text-mindscroll-cream transition-colors"
      >
        Mind<span className="text-mindscroll-teal">Scroll</span>
      </Link>

      {/* Author header */}
      <header className="max-w-[640px] w-full mb-12">
        <p className="m-0 mb-3 font-sans text-[11px] font-semibold tracking-[0.18em] uppercase text-white/40">
          Author
        </p>
        <h1
          className="m-0 mb-2 font-serif italic text-mindscroll-cream tracking-[-0.01em]"
          style={{ fontSize: "clamp(36px, 6vw, 56px)" }}
        >
          {author.name}
        </h1>
        <p className="m-0 font-sans text-sm text-white/50">
          {author.quoteCount} curated {author.quoteCount === 1 ? "quote" : "quotes"}
        </p>
      </header>

      {/* Quote list */}
      <section className="max-w-[640px] w-full flex flex-col gap-4">
        {quotes.map(q => {
          const meta = CATEGORY_META[q.category];
          return (
            <Link
              key={q.id}
              href={`/quotes/${q.id}`}
              className="bg-mindscroll-bg-soft rounded-2xl py-5 px-6 border border-white/[0.05] hover:border-white/[0.15] transition-colors flex gap-4 items-start"
            >
              <div className="w-[3px] min-h-12 rounded-sm shrink-0 mt-1" style={{ background: meta.color }} />
              <div className="flex-1 min-w-0">
                <p
                  className="m-0 mb-3 font-sans text-[10px] font-semibold tracking-[0.12em] uppercase"
                  style={{ color: meta.color }}
                >
                  {meta.label}
                </p>
                <blockquote className="m-0 font-serif italic text-[17px] leading-[1.55] text-mindscroll-cream">
                  &ldquo;{q.text}&rdquo;
                </blockquote>
              </div>
            </Link>
          );
        })}
      </section>

      <Link
        href="/"
        className="mt-16 rounded-[22px] py-3 px-8 font-sans text-[14px] font-semibold tracking-[0.04em] border bg-white/[0.05] border-white/10 text-white/60 hover:bg-white/[0.08] hover:text-mindscroll-cream transition-all"
      >
        Swipe the full feed →
      </Link>
    </main>
  );
}
