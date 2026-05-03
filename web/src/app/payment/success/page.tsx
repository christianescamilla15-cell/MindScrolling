"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { apiGetPremiumStatus } from "@/api/quotes";

const PREMIUM_KEY = "mindscroll_premium";

/**
 * Stripe success_url lands here after a completed Checkout. The webhook
 * (POST /stripe/webhook) is what actually flips is_premium server-side, so
 * we poll apiGetPremiumStatus a couple of times — webhook delivery can lag
 * the redirect by 1–2 seconds. Once we see is_premium=true we mirror it
 * to localStorage so the App's optimistic state picks it up on next mount.
 */
export default function PaymentSuccessPage() {
  const [status, setStatus] = useState<"verifying" | "confirmed" | "pending">("verifying");

  useEffect(() => {
    let cancelled = false;
    let attempts = 0;

    const poll = async () => {
      while (!cancelled && attempts < 6) {
        attempts++;
        try {
          const data = await apiGetPremiumStatus();
          if (data?.is_premium) {
            try { localStorage.setItem(PREMIUM_KEY, "true"); } catch { /* noop */ }
            if (!cancelled) setStatus("confirmed");
            return;
          }
        } catch { /* keep polling */ }
        await new Promise(r => setTimeout(r, 1500));
      }
      if (!cancelled) setStatus("pending");
    };

    void poll();
    return () => { cancelled = true; };
  }, []);

  return (
    <div className="w-full min-h-screen bg-mindscroll-bg flex flex-col items-center justify-center px-8 text-center">
      <div className="text-[64px] mb-6">{status === "confirmed" ? "✦" : "…"}</div>

      <h1 className="m-0 mb-3 font-serif text-[28px] font-semibold text-mindscroll-cream">
        {status === "confirmed" ? "Welcome to Inside" : "Confirming your payment"}
      </h1>

      <p className="m-0 mb-10 font-sans text-[15px] text-white/70 leading-[1.6] max-w-[360px]">
        {status === "verifying" && "Stripe is wrapping up — this usually takes a couple of seconds."}
        {status === "confirmed" && "Premium unlocked. Export images, unlock all packs, support the project."}
        {status === "pending"  && "Payment captured. Premium will activate as soon as the webhook lands. Refresh in a minute if it hasn't already."}
      </p>

      <Link
        href="/"
        className="rounded-2xl py-3 px-8 font-sans text-[15px] font-semibold tracking-[0.04em] text-mindscroll-teal bg-mindscroll-teal/15 border border-mindscroll-teal/40"
      >
        Back to MindScroll →
      </Link>
    </div>
  );
}
