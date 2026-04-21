// Minimal placeholder service worker — Fase 0.
// Real offline strategy + push handlers land in Fase 2 (web push).
// Keeping this file present lets the manifest resolve and unlocks
// "Install app" prompts in Chrome / Edge while we iterate.

const CACHE = "mindscrolling-shell-v0";

self.addEventListener("install", (event) => {
  event.waitUntil(self.skipWaiting());
});

self.addEventListener("activate", (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener("fetch", (event) => {
  // Network-first; we will refine in Fase 2.
  event.respondWith(
    fetch(event.request).catch(() => caches.match(event.request))
  );
});
