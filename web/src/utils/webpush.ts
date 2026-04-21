// Web Push subscription helpers — wraps the Notifications API + PushManager.
// The backend's `/push/subscribe` endpoint doesn't exist yet, so the
// subscription gets cached in localStorage; once the backend lands we can
// flush the cached subscription on next mount.

const SUBSCRIPTION_KEY = "mindscroll_push_subscription";

export type PushPermission = "default" | "granted" | "denied" | "unsupported";

export function pushSupported(): boolean {
  if (typeof window === "undefined") return false;
  return (
    "serviceWorker" in navigator &&
    "PushManager" in window &&
    "Notification" in window
  );
}

export function pushPermission(): PushPermission {
  if (!pushSupported()) return "unsupported";
  return Notification.permission;
}

/** Convert the URL-safe base64 VAPID key into a BufferSource PushManager
 *  accepts. We allocate an ArrayBuffer explicitly so the result stays a
 *  `Uint8Array<ArrayBuffer>` and not a `Uint8Array<SharedArrayBuffer>` —
 *  TS strict rejects the latter for applicationServerKey. */
function urlBase64ToUint8Array(base64: string): Uint8Array<ArrayBuffer> {
  const padding = "=".repeat((4 - (base64.length % 4)) % 4);
  const padded = (base64 + padding).replace(/-/g, "+").replace(/_/g, "/");
  const raw = atob(padded);
  const buf = new ArrayBuffer(raw.length);
  const out = new Uint8Array(buf);
  for (let i = 0; i < raw.length; i++) out[i] = raw.charCodeAt(i);
  return out;
}

/**
 * Asks the user for notification permission and subscribes to push.
 * Returns the PushSubscription on success, or throws with a human-readable
 * message that the caller can stick in a toast.
 */
export async function subscribeToPush(): Promise<PushSubscription> {
  if (!pushSupported()) {
    throw new Error("Push notifications aren't supported on this browser.");
  }

  const vapidKey = process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY;
  if (!vapidKey) {
    throw new Error("Push not configured — VAPID key missing.");
  }

  const permission = await Notification.requestPermission();
  if (permission !== "granted") {
    throw new Error("Notification permission was not granted.");
  }

  const reg = await navigator.serviceWorker.ready;
  const existing = await reg.pushManager.getSubscription();
  if (existing) {
    cacheSubscription(existing);
    return existing;
  }

  const sub = await reg.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: urlBase64ToUint8Array(vapidKey),
  });

  cacheSubscription(sub);
  return sub;
}

export async function unsubscribeFromPush(): Promise<void> {
  if (!pushSupported()) return;
  const reg = await navigator.serviceWorker.ready;
  const sub = await reg.pushManager.getSubscription();
  if (sub) await sub.unsubscribe();
  try { localStorage.removeItem(SUBSCRIPTION_KEY); } catch { /* noop */ }
}

/** True if the device has an active push subscription (synced via cache). */
export async function hasPushSubscription(): Promise<boolean> {
  if (!pushSupported()) return false;
  try {
    const reg = await navigator.serviceWorker.ready;
    const sub = await reg.pushManager.getSubscription();
    return sub !== null;
  } catch {
    return false;
  }
}

function cacheSubscription(sub: PushSubscription): void {
  try {
    localStorage.setItem(SUBSCRIPTION_KEY, JSON.stringify(sub.toJSON()));
  } catch { /* noop */ }
}
