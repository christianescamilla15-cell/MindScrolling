"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import Onboarding from "@/components/Onboarding";
import type { Lang, Profile } from "@/types";

const ONBOARDING_KEY = "mindscroll_onboarding";
const LANG_KEY = "mindscroll_lang";

function loadLang(): Lang {
  try {
    const raw = localStorage.getItem(LANG_KEY);
    if (raw === "en" || raw === "es") return raw;
  } catch { /* noop */ }
  return "en";
}

export default function OnboardingPage() {
  const router = useRouter();
  const [lang, setLang] = useState<Lang>("en");

  // Hydrate the language from localStorage on the client. If the user has
  // already finished onboarding, bounce them home so this URL doesn't
  // become a backdoor that resets the wizard for repeat visitors.
  useEffect(() => {
    setLang(loadLang());
    try {
      if (localStorage.getItem(ONBOARDING_KEY) === "true") {
        router.replace("/");
      }
    } catch { /* noop */ }
  }, [router]);

  const handleComplete = (_profile: Profile) => {
    // Onboarding component already persisted profile + ONBOARDING_KEY before
    // calling onComplete (see src/components/Onboarding.tsx). Just bounce home.
    router.push("/");
  };

  return <Onboarding lang={lang} onComplete={handleComplete} />;
}
