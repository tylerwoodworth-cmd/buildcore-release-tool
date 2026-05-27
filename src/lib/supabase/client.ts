"use client";

import { createClient, type SupabaseClient } from "@supabase/supabase-js";

/** Browser-side Supabase client. Singleton (instantiate once per tab).
 *  Used for Realtime channel subscriptions. Anon key only. */
let _client: SupabaseClient | null = null;

export function supabaseBrowser(): SupabaseClient {
  if (_client) return _client;
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !anonKey) {
    throw new Error("Supabase env vars not set.");
  }
  _client = createClient(url, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  return _client;
}
