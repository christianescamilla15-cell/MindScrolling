import Link from "next/link";

/**
 * Stripe cancel_url lands here when the user backs out of Checkout. No state
 * change to verify — just a friendly "no harm done" page with one route back
 * into the app. Server-rendered because there's no per-user data to fetch.
 */
export default function PaymentCancelPage() {
  return (
    <div className="w-full min-h-screen bg-mindscroll-bg flex flex-col items-center justify-center px-8 text-center">
      <div className="text-[64px] mb-6">·</div>

      <h1 className="m-0 mb-3 font-serif text-[28px] font-semibold text-mindscroll-cream">
        Payment cancelled
      </h1>

      <p className="m-0 mb-10 font-sans text-[15px] text-white/70 leading-[1.6] max-w-[360px]">
        No charge was made. You can pick up where you left off — premium is still one tap away from Settings.
      </p>

      <Link
        href="/"
        className="rounded-2xl py-3 px-8 font-sans text-[15px] font-semibold tracking-[0.04em] text-mindscroll-cream bg-white/[0.05] border border-white/10"
      >
        Back to MindScroll →
      </Link>
    </div>
  );
}
