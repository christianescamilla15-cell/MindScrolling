import { ImageResponse } from "next/og";
import { getAuthorBySlug } from "@/lib/quotes-catalog";

export const runtime = "edge";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";
export const alt = "Author on MindScrolling";

interface Props {
  params: Promise<{ slug: string }>;
}

export default async function OGImage({ params }: Props) {
  const { slug } = await params;
  const author = getAuthorBySlug(slug);
  const name = author?.name ?? "Author";
  const count = author?.quoteCount ?? 0;

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
            "radial-gradient(ellipse 60% 50% at 50% 100%, #14B8A626 0%, #0f0f13 70%)",
          color: "#F5F0E8",
          fontFamily: "Georgia, serif",
        }}
      >
        <div
          style={{
            fontFamily: "system-ui, sans-serif",
            fontSize: 20,
            letterSpacing: 4,
            textTransform: "uppercase",
            color: "rgba(245,240,232,0.5)",
            fontWeight: 700,
            marginBottom: 24,
          }}
        >
          Author
        </div>

        <div
          style={{
            display: "flex",
            fontSize: 104,
            lineHeight: 1.05,
            fontStyle: "italic",
            letterSpacing: "-0.02em",
            color: "#F5F0E8",
            marginBottom: 32,
          }}
        >
          {name}
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
            <span style={{ color: "#14B8A6" }}>Scroll</span>
          </div>
        </div>
      </div>
    ),
    size,
  );
}
