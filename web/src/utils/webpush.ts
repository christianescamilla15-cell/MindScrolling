// Web Push subscription helpers — wraps the Notifications API + PushManager.
// After obtaining a PushSubscription locally, sync it with the backend
// via POST /push/subscribe so the server can deliver notifications.

import { getDeviceId } from "./storage";

const SUBSCRIPTION_KEY = "mindscroll_push_subscription";
const API_BASE = process.env.NEXT_PUBLIC_API_URL || "";

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
  await syncSubscriptionToBackend(sub);
  return sub;
}

export async function unsubscribeFromPush(): Promise<void> {
  if (!pushSupported()) return;
  const reg = await navigator.serviceWorker.ready;
  const sub = await reg.pushManager.getSubscription();
  if (sub) await sub.unsubscribe();
  try { localStorage.removeItem(SUBSCRIPTION_KEY); } catch { /* noop */ }
  await removeSubscriptionFromBackend();
}

/** POST PushSubscription to backend so it can deliver notifications.
 *  Failure is logged but not thrown — local subscription still works,
 *  the cache will retry next time the user toggles notifications. */
async function syncSubscriptionToBackend(sub: PushSubscription): Promise<void> {
  if (!API_BASE) return;
  try {
    const json = sub.toJSON();
    await fetch(`${API_BASE}/push/subscribe`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Device-ID": getDeviceId(),
      },
      body: JSON.stringify({
        endpoint: json.endpoint,
        keys: json.keys,
      }),
    });
  } catch (err) {
    console.warn("[webpush] backend sync failed:", err);
  }
}

/** DELETE all subscriptions for this device on the backend. */
async function removeSubscriptionFromBackend(): Promise<void> {
  if (!API_BASE) return;
  try {
    await fetch(`${API_BASE}/push/subscribe`, {
      method: "DELETE",
      headers: { "X-Device-ID": getDeviceId() },
    });
  } catch (err) {
    console.warn("[webpush] backend unsubscribe failed:", err);
  }
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
