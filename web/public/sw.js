// MindScrolling service worker — install lifecycle, network-first fetch,
// and Web Push handlers (Fase 2c). Keep this file vanilla JS — it ships
// to the browser unprocessed by Next/Turbopack.

const CACHE = "mindscrolling-shell-v0";

self.addEventListener("install", (event) => {
  event.waitUntil(self.skipWaiting());
});

self.addEventListener("activate", (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener("fetch", (event) => {
  // Network-first with cache fallback. Real offline strategy still TBD.
  event.respondWith(
    fetch(event.request).catch(() => caches.match(event.request))
  );
});

/* ─── Web Push ──────────────────────────────────────────────────────────── */

// The server sends a JSON payload like:
//   { title, body, url?, tag? }
// We render the notification with sane defaults if any field is missing.
self.addEventListener("push", (event) => {
  let payload = {};
  try {
    payload = event.data ? event.data.json() : {};
  } catch {
    payload = { body: event.data ? event.data.text() : "" };
  }

  const title = payload.title || "MindScroll";
  const options = {
    body:    payload.body || "A new reflection is waiting.",
    icon:    "/icons/icon-192.png",
    badge:   "/icons/icon-192.png",
    tag:     payload.tag || "mindscroll",
    data:    { url: payload.url || "/" },
    // Deduplicate if the same tag fires twice in quick succession.
    renotify: false,
  };

  event.waitUntil(self.registration.showNotification(title, options));
});

// Clicking the notification: focus an existing tab on the target URL if
// possible, otherwise open a new one.
self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const targetUrl = (event.notification.data && event.notification.data.url) || "/";

  event.waitUntil((async () => {
    const allClients = await self.clients.matchAll({
      type: "window",
      includeUncontrolled: true,
    });
    for (const client of allClients) {
      try {
        const url = new URL(client.url);
        if (url.pathname === targetUrl || url.href.endsWith(targetUrl)) {
          return client.focus();
        }
      } catch { /* skip malformed */ }
    }
    if (self.clients.openWindow) {
      return self.clients.openWindow(targetUrl);
    }
  })());
});
