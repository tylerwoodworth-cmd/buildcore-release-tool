import { createClient } from "@supabase/supabase-js";

/** Server-side Supabase client.
 *
 * Uses the anon key. Reads are gated by RLS (anon has SELECT on every table
 * in this app's schema). Writes go through API routes that construct a
 * service-role client instead — never from here. */
export function supabaseServer() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !anonKey) {
    throw new Error(
      "Supabase env vars not set. Add NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY to .env.local.",
    );
  }
  return createClient(url, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

/** Service-role Supabase client. SERVER-ONLY. Bypasses RLS. Use in API
 *  routes / server actions for writes. */
export function supabaseService() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !serviceKey) {
    throw new Error(
      "Service-role env vars missing. Add SUPABASE_SERVICE_ROLE_KEY to .env.local.",
    );
  }
  return createClient(url, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}
