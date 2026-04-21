import type { Metadata, Viewport } from "next";
import { Playfair_Display, DM_Sans } from "next/font/google";
import "./globals.css";
import { ServiceWorkerRegister } from "./sw-register";

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
  maximumScale: 1,
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
