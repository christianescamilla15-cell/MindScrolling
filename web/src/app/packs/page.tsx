"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { apiGetPacks, type Pack, type PacksCatalog } from "@/api/packs";

export default function PacksPage() {
  const [data,    setData]    = useState<PacksCatalog | null>(null);
  const [loading, setLoading] = useState(true);
  const [error,   setError]   = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    apiGetPacks()
      .then((res) => { if (!cancelled) { setData(res); setLoading(false); } })
      .catch((e)  => { if (!cancelled) { setError(String(e?.message || e)); setLoading(false); } });
    return () => { cancelled = true; };
  }, []);

  return (
    <main className="min-h-full px-6 py-10 max-w-2xl mx-auto">
      <header className="mb-10">
        <Link
          href="/"
          className="font-sans text-sm text-white/70 hover:text-white inline-block mb-4"
        >
          ← Home
        </Link>
        <h1 className="font-display text-4xl text-mindscroll-cream mb-2">Packs</h1>
        <p className="font-sans text-sm text-white/70 max-w-md">
          Curated philosophical collections. Each pack has 500 quotes in your language.
        </p>
        {data?.user_state === "inside" && (
          <p className="font-sans text-xs text-mindscroll-teal mt-3 uppercase tracking-[0.1em] font-semibold">
            All packs included with Inside
          </p>
        )}
      </header>

      {loading && (
        <p className="font-sans text-sm text-white/60 text-center py-12">Loading packs…</p>
      )}

      {error && (
        <div className="rounded-2xl bg-red-500/10 border border-red-500/30 p-6 my-6">
          <p className="font-sans text-sm text-red-300">Couldn&apos;t load packs.</p>
          <p className="font-sans text-xs text-white/70 mt-2">{error}</p>
        </div>
      )}

      {data && (
        <ul className="flex flex-col gap-4">
          {data.packs.map((pack) => (
            <li key={pack.id}>
              <PackCard pack={pack} />
            </li>
          ))}
        </ul>
      )}
    </main>
  );
}

function PackCard({ pack }: { pack: Pack }) {
  const tint = `${pack.color}1F`; // 12% alpha hex suffix on the accent color

  return (
    <article
      className="rounded-2xl border border-white/10 p-5 transition-colors hover:border-white/20"
      style={{ backgroundColor: tint }}
    >
      <header className="flex items-start justify-between gap-3 mb-2">
        <h2 className="font-display text-xl text-mindscroll-cream leading-tight">
          {pack.name}
        </h2>
        <AccessBadge status={pack.access_status} priceUsd={pack.price.usd} />
      </header>
      <p className="font-sans text-sm text-white/70 mb-4 leading-snug">
        {pack.description}
      </p>
      <div className="flex items-center justify-between gap-3">
        <span
          className="font-sans text-[11px] uppercase tracking-[0.1em] font-semibold"
          style={{ color: pack.color }}
        >
          {pack.quote_count} quotes
        </span>
        {pack.access_status === "unlocked" ? (
          <span className="font-sans text-xs text-white/55">Open from feed</span>
        ) : (
          <span className="font-sans text-xs text-white/55">Preview soon</span>
        )}
      </div>
    </article>
  );
}

function AccessBadge({ status, priceUsd }: { status: Pack["access_status"]; priceUsd: string }) {
  const base = "rounded-full px-2.5 py-1 font-sans text-[11px] font-semibold uppercase tracking-[0.08em]";
  if (status === "unlocked") {
    return <span className={`${base} bg-mindscroll-teal/20 text-mindscroll-teal`}>Unlocked</span>;
  }
  if (status === "preview_only") {
    return <span className={`${base} bg-white/10 text-white/70`}>Preview</span>;
  }
  return (
    <span className={`${base} bg-mindscroll-cream/15 text-mindscroll-cream`}>
      ${priceUsd}
    </span>
  );
}
