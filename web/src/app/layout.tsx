import type { Metadata, Viewport } from "next";
import { Playfair_Display, DM_Sans } from "next/font/google";
import "./globals.css";
import { ServiceWorkerRegister } from "./sw-register";
import { SITE_URL } from "@/lib/site";

const playfair = Playfair_Display({
  variable: "--font-playfair",
  subsets: ["latin"],
  style: ["normal", "italic"],
  weight: ["400", "500", "600"],
  display: "swap",
});

const dmSans = DM_Sans({
  variable: "--font-dm-sans",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
  display: "swap",
});

export const metadata: Metadata = {
  // Resolves relative OG image URLs (including the auto-generated
  // opengraph-image.tsx endpoints) against this base — otherwise Next.js
  // falls back to http://localhost:3000 and crawlers fetch the wrong host.
  metadataBase: new URL(SITE_URL),
  title: {
    default: "MindScrolling",
    template: "%s — MindScrolling",
  },
  description:
    "Anti doom-scrolling: philosophical quotes that slow you down.",
  applicationName: "MindScrolling",
  manifest: "/manifest.webmanifest",
  appleWebApp: {
    capable: true,
    title: "MindScroll",
    statusBarStyle: "black-translucent",
  },
};

export const viewport: Viewport = {
  themeColor: "#0f0f13",
  width: "device-width",
  initialScale: 1,
  // Allow up to 5x zoom for low-vision users (WCAG 1.4.4 / Lighthouse a11y).
  // Earlier maximumScale: 1 was added to prevent gesture conflict with the
  // swipe deck, but it failed the meta-viewport audit. The swipe deck is
  // resilient enough; we accept the zoom interaction.
  maximumScale: 5,
  viewportFit: "cover",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${playfair.variable} ${dmSans.variable} h-full antialiased`}
    >
      <body className="min-h-full flex flex-col bg-mindscroll-bg text-mindscroll-cream">
        {children}
        <ServiceWorkerRegister />
      </body>
    </html>
  );
}
