"use client";

import { Search, Plus } from "lucide-react";
import { SyncIndicator } from "./SyncIndicator";

export function Topbar() {
  return (
    <div
      className="sticky top-0 z-10 flex items-center gap-4 border-b border-[var(--bc-border)] bg-white px-8"
      style={{ height: "var(--bc-navbar-height)" }}
    >
      {/* Breadcrumbs slot — pages can render their own crumbs via a future provider */}
      <div className="text-sm font-semibold text-slate-900">BuildCore Release Tool</div>
      <div className="flex-1" />

      <SyncIndicator />

      <div className="flex w-[280px] items-center gap-2 rounded-[10px] border border-[var(--bc-border)] bg-slate-50 px-3 py-1.5 text-sm text-slate-500">
        <Search size={14} className="text-slate-400" />
        <input
          className="flex-1 bg-transparent outline-none placeholder:text-slate-400"
          placeholder="Search projects, tickets, feedback..."
        />
      </div>

      <button
        className="inline-flex items-center gap-2 rounded-[10px] px-3.5 py-2 text-[13.5px] font-medium text-white"
        style={{ background: "var(--bc-brand-600)" }}
      >
        <Plus size={14} />
        New
      </button>
    </div>
  );
}
