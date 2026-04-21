"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import App from "@/App";

const ONBOARDING_KEY = "mindscroll_onboarding";

/**
 * Root route. Acts as the onboarding gate:
 *   - SSR renders the splash (so first paint is the wordmark, not white)
 *   - On the client, checks localStorage for a completed-onboarding flag
 *   - First-run users get bounced to /onboarding via router.replace
 *   - Returning users see <App /> mount once the check passes
 */
export default function Page() {
  const router = useRouter();
  const [ready, setReady] = useState(false);

  useEffect(() => {
    let onboarded = false;
    try {
      onboarded = localStorage.getItem(ONBOARDING_KEY) === "true";
    } catch { /* SSR / disabled storage */ }

    if (!onboarded) {
      router.replace("/onboarding");
      return;
    }
    setReady(true);
  }, [router]);

  if (!ready) {
    // Splash that matches App's own loading screen so the handoff is invisible.
    return (
      <div className="w-full min-h-screen bg-mindscroll-bg flex flex-col items-center justify-center gap-4">
        <p className="font-serif italic text-[22px] text-mindscroll-cream m-0">
          Mind<span className="text-mindscroll-teal">Scroll</span>
        </p>
      </div>
    );
  }

  return <App />;
}
