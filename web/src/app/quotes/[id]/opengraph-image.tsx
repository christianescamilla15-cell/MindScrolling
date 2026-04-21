import { ImageResponse } from "next/og";
import { CATEGORY_META } from "@/constants";
import { getQuoteById } from "@/lib/quotes-catalog";

export const runtime = "edge";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";
export const alt = "Quote from MindScrolling";

interface Props {
  params: Promise<{ id: string }>;
}

export default async function OGImage({ params }: Props) {
  const { id } = await params;
  const quote = getQuoteById(id);
  const meta = quote ? CATEGORY_META[quote.category] : CATEGORY_META.reflection;

  // Keep the quote short enough to read at 630px. Satori doesn't line-break
  // the same way the browser does, so we truncate preemptively.
  const text = quote?.text
    ? quote.text.length > 200
      ? `${quote.text.slice(0, 197)}…`
      : quote.text
    : "Philosophical wisdom for your daily mind.";
  const author = quote?.author ?? "MindScroll";

  return new ImageResponse(
    (
      <div
        style={{
          width:  "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          padding: "72px 80px",
          background:
            "radial-gradient(ellipse 60% 50% at 50% 100%, " + meta.color + "26 0%, #0f0f13 70%)",
          color: "#F5F0E8",
          fontFamily: "Georgia, serif",
        }}
      >
        {/* Category + left accent bar */}
        <div style={{ display: "flex", alignItems: "center", gap: 18 }}>
          <div
            style={{
              width: 6,
              height: 52,
              borderRadius: 3,
              background: meta.color,
            }}
          />
          <div
            style={{
              fontFamily: "system-ui, sans-serif",
              fontSize: 20,
              letterSpacing: 4,
              textTransform: "uppercase",
              color: meta.color,
              fontWeight: 700,
            }}
          >
            {meta.label}
          </div>
        </div>

        {/* Quote body */}
        <div
          style={{
            display: "flex",
            fontSize: 56,
            lineHeight: 1.25,
            fontStyle: "italic",
            letterSpacing: "-0.01em",
            color: "#F5F0E8",
          }}
        >
          <span style={{ color: meta.color, marginRight: 12, fontSize: 80, fontStyle: "normal", lineHeight: 0.5 }}>
            &ldquo;
          </span>
          <span>{text}</span>
        </div>

        {/* Author + brand */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div
            style={{
              display: "flex",
              fontFamily: "system-ui, sans-serif",
              fontSize: 26,
              color: "rgba(245,240,232,0.6)",
              letterSpacing: 1,
            }}
          >
            {`\u2014 ${author}`}
          </div>
          <div
            style={{
              display: "flex",
              fontFamily: "Georgia, serif",
              fontSize: 26,
              fontStyle: "italic",
              color: "rgba(245,240,232,0.8)",
            }}
          >
            <span>Mind</span>
            <span style={{ color: "#14B8A6" }}>Scroll</span>
          </div>
        </div>
      </div>
    ),
    size,
  );
}
