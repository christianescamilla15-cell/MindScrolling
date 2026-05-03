import { notFound } from "next/navigation";
import Link from "next/link";
import type { Metadata } from "next";
import { CATEGORY_META } from "@/constants";
import type { CategoryKey } from "@/types";
import {
  getAllCategoryKeys,
  getQuotesByCategory,
} from "@/lib/quotes-catalog";
import { absUrl } from "@/lib/site";

interface Params {
  cat: string;
}

interface PageProps {
  params: Promise<Params>;
}

export const dynamicParams = false;

export function generateStaticParams(): Params[] {
  return getAllCategoryKeys().map(cat => ({ cat }));
}

function resolveCategory(cat: string): CategoryKey | null {
  return (cat in CATEGORY_META) ? (cat as CategoryKey) : null;
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { cat } = await params;
  const key = resolveCategory(cat);
  if (!key) return { title: "Category not found" };

  const meta = CATEGORY_META[key];
  const count = getQuotesByCategory(key).length;
  const title = `${meta.label} — curated quotes`;
  const description = `${count} hand-picked ${meta.label} quotes on MindScrolling. Swipe, save, and reflect.`;
  const url = absUrl(`/categories/${cat}`);

  return {
    title,
    description,
    alternates: { canonical: url },
    openGraph: {
      type: "website",
      title,
      description,
      url,
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
    },
  };
}

export default async function CategoryPage({ params }: PageProps) {
  const { cat } = await params;
  const key = resolveCategory(cat);
  if (!key) notFound();

  const meta = CATEGORY_META[key];
  const quotes = getQuotesByCategory(key);
  const canonical = absUrl(`/categories/${cat}`);

  // Schema.org CollectionPage + ItemList of Quotations. ItemList gives
  // Google an ordered set to render as a "More results" cluster under
  // the category query; CollectionPage is the canonical container.
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    "@id": canonical,
    url: canonical,
    name: `${meta.label} quotes`,
    about: meta.label,
    mainEntity: {
      "@type": "ItemList",
      numberOfItems: quotes.length,
      itemListElement: quotes.map((q, i) => ({
        "@type": "ListItem",
        position: i + 1,
        url: absUrl(`/quotes/${q.id}`),
        item: {
          "@type": "Quotation",
          "@id": absUrl(`/quotes/${q.id}`),
          text: q.text,
          creator: { "@type": "Person", name: q.author },
          inLanguage: q.lang ?? "en",
        },
      })),
    },
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

      <Link
        href="/"
        className="mb-12 font-serif italic text-[18px] text-mindscroll-cream/70 hover:text-mindscroll-cream transition-colors"
      >
        Mind<span style={{ color: meta.color }}>Scroll</span>
      </Link>

      <header className="max-w-[640px] w-full mb-12">
        <div className="flex items-center gap-3 mb-4">
          <div className="w-1.5 h-10 rounded-sm" style={{ background: meta.color }} />
          <p
            className="m-0 font-sans text-[11px] font-semibold tracking-[0.18em] uppercase"
            style={{ color: meta.color }}
          >
            Category
          </p>
        </div>
        <h1
          className="m-0 mb-2 font-serif italic text-mindscroll-cream tracking-[-0.01em]"
          style={{ fontSize: "clamp(36px, 6vw, 56px)" }}
        >
          {meta.label}
        </h1>
        <p className="m-0 font-sans text-sm text-white/70">
          {quotes.length} curated {quotes.length === 1 ? "quote" : "quotes"}
        </p>
      </header>

      <section className="max-w-[640px] w-full flex flex-col gap-4">
        {quotes.map(q => (
          <Link
            key={q.id}
            href={`/quotes/${q.id}`}
            className="bg-mindscroll-bg-soft rounded-2xl py-5 px-6 border border-white/[0.05] hover:border-white/[0.15] transition-colors flex gap-4 items-start"
          >
            <div className="w-[3px] min-h-12 rounded-sm shrink-0 mt-1" style={{ background: meta.color }} />
            <div className="flex-1 min-w-0">
              <blockquote className="m-0 mb-2 font-serif italic text-[17px] leading-[1.55] text-mindscroll-cream">
                &ldquo;{q.text}&rdquo;
              </blockquote>
              <span className="font-sans text-[12px] text-white/60">— {q.author}</span>
            </div>
          </Link>
        ))}
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
