"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { cn } from "@/lib/cn";
import { IDEA_STATUS_LABEL } from "@/lib/mock";
import type { IdeaStatus } from "@/lib/types";

type Props = {
  active: IdeaStatus | "all";
  inKindCounts: Partial<Record<IdeaStatus, number>>;
  totalInKind: number;
};

export function StatusFilter({ active, inKindCounts, totalInKind }: Props) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const setStatus = (s: IdeaStatus | "all") => {
    const p = new URLSearchParams(searchParams);
    if (s === "all") p.delete("status");
    else p.set("status", s);
    router.push(`/ideas?${p.toString()}`);
  };

  const statuses = (Object.keys(IDEA_STATUS_LABEL) as IdeaStatus[]).filter(
    (k) => (inKindCounts[k] ?? 0) > 0,
  );

  return (
    <div className="mb-5 flex flex-wrap gap-1.5">
      <Pill active={active === "all"} onClick={() => setStatus("all")} count={totalInKind}>
        Any status
      </Pill>
      {statuses.map((s) => {
        const info = IDEA_STATUS_LABEL[s];
        return (
          <Pill
            key={s}
            active={active === s}
            onClick={() => setStatus(s)}
            count={inKindCounts[s] ?? 0}
          >
            {info.label}
          </Pill>
        );
      })}
    </div>
  );
}

function Pill({
  active,
  onClick,
  count,
  children,
}: {
  active: boolean;
  onClick: () => void;
  count: number;
  children: React.ReactNode;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        "inline-flex items-center gap-1.5 rounded-full border px-3 py-1 text-[12.5px] font-medium transition-colors",
        active
          ? "border-slate-700 bg-slate-700 text-white"
          : "border-[var(--bc-border)] bg-white text-slate-500 hover:border-brand-500 hover:text-brand-700",
      )}
    >
      {children}
      <span
        className={cn(
          "rounded-full px-1.5 py-px text-[10.5px] font-bold",
          active ? "bg-white/20" : "bg-slate-100 text-slate-500",
        )}
      >
        {count}
      </span>
    </button>
  );
}
