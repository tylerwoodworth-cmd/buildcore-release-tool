"use client";

import { useEffect, useState } from "react";

/** Connection status indicator. In production this is wired to Supabase
    Realtime channel state. Right now it's a static placeholder so the design
    is preserved end-to-end while we connect the backend in a later phase. */
export function SyncIndicator() {
  const [, force] = useState(0);
  const [mountedAt] = useState(() => Date.now());

  // Re-render every second so the "Ns ago" label stays current
  useEffect(() => {
    const t = setInterval(() => force((n) => n + 1), 1000);
    return () => clearInterval(t);
  }, []);

  const secondsAgo = Math.max(0, Math.floor((Date.now() - mountedAt) / 1000));
  const label =
    secondsAgo < 5
      ? "just now"
      : secondsAgo < 60
        ? `${secondsAgo}s ago`
        : `${Math.floor(secondsAgo / 60)}m ago`;

  return (
    <div
      className="inline-flex items-center gap-2 rounded-full border px-3 py-1 text-xs font-semibold"
      style={{
        background: "var(--bc-success-50)",
        borderColor: "var(--bc-success-100)",
        color: "var(--bc-success-700)",
      }}
      title={`Realtime channel · synced ${label}`}
    >
      <span
        className="relative inline-block h-2 w-2 rounded-full"
        style={{ background: "var(--bc-success-600)" }}
      >
        <span
          className="absolute inset-[-2px] animate-[syncPulse_2.4s_ease-out_infinite] rounded-full opacity-0"
          style={{ background: "var(--bc-success-600)" }}
        />
      </span>
      <span>Live</span>
      <span className="font-medium opacity-75">· {label}</span>
    </div>
  );
}
