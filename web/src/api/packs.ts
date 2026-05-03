import { getDeviceId } from "../utils/storage";
import { USER_LANG } from "../constants";

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "";

export type PackAccessStatus = "unlocked" | "preview_only" | "purchasable";

export interface Pack {
  id:                 string;
  name:               string;
  description:        string;
  icon:               string;
  color:              string;
  quote_count:        number;
  is_active:          boolean;
  is_premium:         boolean;
  released_at:        string;
  is_grandfathered:   boolean;
  access_status:      PackAccessStatus;
  price: {
    usd:                string;
    product_id_ios:     string | null;
    product_id_android: string | null;
  };
}

export interface PacksCatalog {
  packs:      Pack[];
  user_state: string;
}

export async function apiGetPacks(lang: string = USER_LANG): Promise<PacksCatalog> {
  const r = await fetch(`${API_BASE}/packs?lang=${encodeURIComponent(lang)}`, {
    headers: { "X-Device-ID": getDeviceId() },
  });
  if (!r.ok) {
    throw new Error(`packs catalog ${r.status}`);
  }
  return r.json();
}
