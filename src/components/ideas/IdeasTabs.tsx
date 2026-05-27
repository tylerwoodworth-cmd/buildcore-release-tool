"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { Folder, PlusCircle, Pencil } from "lucide-react";
import { cn } from "@/lib/cn";
import type { IdeaKind } from "@/lib/types";

const TABS: Array<{ id: IdeaKind; label: string; icon: React.ComponentType<{ size?: number }> }> = [
  { id: "new_project", label: "New projects",  icon: Folder },
  { id: "new_feature", label: "New features",  icon: PlusCircle },
  { id: "enhancement", label: "Enhancements",  icon: Pencil },
];

type Props = {
  active: IdeaKind;
  counts: Record<IdeaKind, number>;
};

/** Three-lane tab strip for Ideas. Selection persists in the URL via ?kind=. */
export function IdeasTabs({ active, counts }: Props) {
  const router = useRouter();
  const searchParams = useSearchParams();

  const switchTo = (kind: IdeaKind) => {
    const p = new URLSearchParams(searchParams);
    p.set("kind", kind);
    p.delete("status"); // reset status filter when switching lanes
    router.push(`/ideas?${p.toString()}`);
  };

  return (
    <div className="mb-3 flex gap-1 border-b border-[var(--bc-border)]">
      {TABS.map((t) => {
        const Icon = t.icon;
        const isActive = active === t.id;
        return (
          <button
            key={t.id}
            type="button"
            onClick={() => switchTo(t.id)}
            className={cn(
              "-mb-px inline-flex items-center gap-2 border-b-2 px-3.5 py-2.5 text-[13.5px] font-medium transition-colors",
              isActive
                ? "border-brand-600 text-brand-700"
                : "border-transparent text-slate-500 hover:text-slate-900",
            )}
          >
            <Icon size={14} />
            {t.label}
            <span
              className={cn(
                "rounded-full px-1.5 py-px text-[11px] font-semibold",
                isActive ? "bg-brand-50 text-brand-700" : "bg-slate-100 text-slate-500",
              )}
            >
              {counts[t.id]}
            </span>
          </button>
        );
      })}
    </div>
  );
}
