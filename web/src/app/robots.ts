import type { MetadataRoute } from "next";
import { SITE_URL } from "@/lib/site";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: "*",
        allow: "/",
        // Per-device user surfaces — no Google value, dilute crawl budget.
        disallow: [
          "/onboarding",
          "/vault",
          "/map",
          "/social",
          "/payment/",
        ],
      },
    ],
    sitemap: `${SITE_URL}/sitemap.xml`,
    host: SITE_URL,
  };
}
