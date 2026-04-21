import { ImageResponse } from "next/og";
import { CATEGORY_META } from "@/constants";
import type { CategoryKey } from "@/types";
import { getQuotesByCategory } from "@/lib/quotes-catalog";

export const runtime = "edge";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";
export const alt = "Category on MindScrolling";

interface Props {
  params: Promise<{ cat: string }>;
}

function resolve(cat: string): CategoryKey | null {
  return (cat in CATEGORY_META) ? (cat as CategoryKey) : null;
}

export default async function OGImage({ params }: Props) {
  const { cat } = await params;
  const key = resolve(cat);
  const meta = key ? CATEGORY_META[key] : CATEGORY_META.reflection;
  const count = key ? getQuotesByCategory(key).length : 0;
  const label = meta.label;

  return new ImageResponse(
    (
      <div
        style={{
          width:  "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          padding: "72px 80px",
          background:
            "radial-gradient(ellipse 60% 50% at 50% 100%, " + meta.color + "26 0%, #0f0f13 70%)",
          color: "#F5F0E8",
          fontFamily: "Georgia, serif",
        }}
      >
        <div style={{ display: "flex", alignItems: "center", gap: 18, marginBottom: 24 }}>
          <div style={{ width: 6, height: 52, borderRadius: 3, background: meta.color }} />
          <div
            style={{
              display: "flex",
              fontFamily: "system-ui, sans-serif",
              fontSize: 22,
              letterSpacing: 4,
              textTransform: "uppercase",
              color: meta.color,
              fontWeight: 700,
            }}
          >
            Category
          </div>
        </div>

        <div
          style={{
            display: "flex",
            fontSize: 112,
            lineHeight: 1.05,
            fontStyle: "italic",
            letterSpacing: "-0.02em",
            color: "#F5F0E8",
            marginBottom: 32,
          }}
        >
          {label}
        </div>

        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            marginTop: 48,
          }}
        >
          <div
            style={{
              display: "flex",
              fontFamily: "system-ui, sans-serif",
              fontSize: 28,
              color: "rgba(245,240,232,0.6)",
            }}
          >
            {`${count} curated ${count === 1 ? "quote" : "quotes"}`}
          </div>
          <div
            style={{
              display: "flex",
              fontFamily: "Georgia, serif",
              fontSize: 28,
              fontStyle: "italic",
              color: "rgba(245,240,232,0.8)",
            }}
          >
            <span>Mind</span>
            <span style={{ color: meta.color }}>Scroll</span>
          </div>
        </div>
      </div>
    ),
    size,
  );
}
