"use client";

import { useState } from "react";
import { Lightbulb, Pencil } from "lucide-react";

type Props = {
  placeholder: string;
  primaryLabel: string;
};

/** Quick-capture bar at the top of the Ideas page. For now it just resets
    on submit — capture writes will be wired when Supabase is connected. */
export function QuickCapture({ placeholder, primaryLabel }: Props) {
  const [val, setVal] = useState("");

  const submit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!val.trim()) return;
    alert(
      `(Demo) Would capture: "${val.trim()}". Wiring to Supabase lands when the project is connected.`,
    );
    setVal("");
  };

  return (
    <form
      onSubmit={submit}
      className="mb-5 flex items-center gap-3 rounded-[var(--bc-radius)] border px-4 py-3"
      style={{
        background: "linear-gradient(180deg, #fff 0%, var(--bc-brand-50) 200%)",
        borderColor: "var(--bc-brand-100)",
      }}
    >
      <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-brand-50 text-brand-700">
        <Lightbulb size={18} />
      </span>
      <input
        type="text"
        value={val}
        onChange={(e) => setVal(e.target.value)}
        placeholder={placeholder}
        className="flex-1 rounded-lg border border-[var(--bc-border)] bg-white px-3.5 py-2 text-[14px] outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20"
      />
      {val.trim() && (
        <button
          type="submit"
          className="rounded-md px-3 py-2 text-[12.5px] font-semibold text-white"
          style={{ background: "var(--bc-brand-600)" }}
        >
          {primaryLabel}
        </button>
      )}
      <button
        type="button"
        onClick={() => alert("(Demo) Full capture modal lands next.")}
        className="inline-flex items-center gap-1.5 rounded-md border border-[var(--bc-border)] bg-white px-2.5 py-2 text-[12.5px] font-medium hover:bg-slate-50"
        title="Open full capture form"
      >
        <Pencil size={12} />
        Details
      </button>
    </form>
  );
}
