"use client";

import { useState } from "react";
import Link from "next/link";
import { ChevronRight, PlusCircle } from "lucide-react";
import { Badge } from "@/components/ui/Badge";
import { FEATURE_STATUS_LABEL, PHASE_COLOR_VAR } from "@/lib/mock";
import type { Feature, Phase, Project } from "@/lib/types";

type ProjectRow = {
  project: Project;
  phases: Phase[];
  features: Feature[];
};

type Props = { rows: ProjectRow[] };

const MONTHS = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
const TODAY_PCT = 41;

export function Roadmap({ rows }: Props) {
  const [expanded, setExpanded] = useState<Set<string>>(new Set());
  const allExpanded = expanded.size === rows.length;

  const toggle = (id: string) =>
    setExpanded((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });

  return (
    <div>
      <div className="mb-6 flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1>BuildCore roadmap</h1>
          <p className="mt-1.5 text-sm text-slate-600">
            2026 release plans across all projects · click any project to see its features
          </p>
        </div>
        <div className="flex gap-2">
          <button
            type="button"
            onClick={() =>
              setExpanded(allExpanded ? new Set() : new Set(rows.map((r) => r.project.id)))
            }
            className="rounded-[10px] border border-[var(--bc-border)] bg-white px-3.5 py-2 text-[13.5px] font-medium hover:bg-slate-50"
          >
            {allExpanded ? "Collapse all" : "Expand all features"}
          </button>
        </div>
      </div>

      {/* Legends */}
      <div className="mb-3 flex flex-wrap items-center gap-3 text-[12px]">
        <span className="text-[11px] font-semibold uppercase tracking-wider text-slate-400">Phases:</span>
        <Badge kind="purple">Planning</Badge>
        <Badge kind="brand">Development</Badge>
        <Badge kind="info">Preparation</Badge>
        <Badge kind="success">Go-live</Badge>
        <Badge kind="warning">Feedback</Badge>
        <span className="mx-1 h-4 w-px bg-slate-200" />
        <span className="text-[11px] font-semibold uppercase tracking-wider text-slate-400">Features:</span>
        <Badge kind="neutral">Planned</Badge>
        <Badge kind="info">In dev</Badge>
        <Badge kind="warning">In testing</Badge>
        <Badge kind="brand">Ready</Badge>
        <Badge kind="success">Live</Badge>
      </div>

      <div className="overflow-hidden rounded-[var(--bc-radius)] border border-[var(--bc-border)] bg-white">
        {/* Months header */}
        <div className="grid border-b border-[var(--bc-border)] bg-slate-50" style={{ gridTemplateColumns: "260px 1fr" }}>
          <div className="px-4 py-2.5 text-[11px] font-semibold uppercase tracking-wider text-slate-400">
            Project / Feature
          </div>
          <div className="grid" style={{ gridTemplateColumns: "repeat(12, 1fr)" }}>
            {MONTHS.map((m) => (
              <div
                key={m}
                className="border-l border-[var(--bc-border)] py-2.5 text-center text-[11px] font-semibold uppercase tracking-wider text-slate-400"
              >
                {m}
              </div>
            ))}
          </div>
        </div>

        {rows.map((row) => {
          const isOpen = expanded.has(row.project.id);
          return (
            <div key={row.project.id}>
              {/* Project row */}
              <div className="grid border-b border-[var(--bc-border)]" style={{ gridTemplateColumns: "260px 1fr" }}>
                <button
                  type="button"
                  onClick={() => toggle(row.project.id)}
                  className="flex items-center gap-2.5 border-r border-[var(--bc-border)] bg-white px-4 py-3 text-left"
                >
                  <ChevronRight
                    size={16}
                    className={"text-slate-400 transition-transform " + (isOpen ? "rotate-90" : "")}
                  />
                  <span
                    className="h-2 w-2 flex-shrink-0 rounded-full"
                    style={{ background: row.project.color }}
                  />
                  <div>
                    <div className="text-[13px] font-semibold">{row.project.name}</div>
                    <div className="mt-0.5 text-[11px] text-slate-400">
                      {row.project.completion}% · {row.features.length} features
                    </div>
                  </div>
                </button>
                <div
                  className="relative min-h-[48px]"
                  style={{
                    backgroundImage:
                      "repeating-linear-gradient(to right, var(--bc-slate-100) 0 1px, transparent 1px calc(100%/12))",
                  }}
                >
                  {row.phases.map((p, i) => {
                    const left = (p.startMonth / 12) * 100;
                    const width = ((p.endMonth - p.startMonth) / 12) * 100;
                    return (
                      <div
                        key={i}
                        className="absolute top-3 flex h-[22px] items-center gap-1.5 overflow-hidden whitespace-nowrap rounded-md px-2 text-[11.5px] font-semibold text-white shadow-[0_1px_0_rgba(15,23,42,0.05)]"
                        style={{
                          left: `${left}%`,
                          width: `${width}%`,
                          background: PHASE_COLOR_VAR[p.color],
                        }}
                        title={p.name}
                      >
                        {p.name}
                      </div>
                    );
                  })}
                  <TodayLine />
                </div>
              </div>

              {/* Feature sub-rows */}
              {isOpen &&
                row.features.map((f) => {
                  const status = FEATURE_STATUS_LABEL[f.status];
                  const color = PHASE_COLOR_VAR[status.kind];
                  const left = ((f.timelineStart ?? 0) / 12) * 100;
                  const width = (((f.timelineEnd ?? 0) - (f.timelineStart ?? 0)) / 12) * 100;
                  const isPlanned = f.status === "planned";
                  return (
                    <div
                      key={f.id}
                      className="grid border-b border-[var(--bc-border)] bg-slate-50"
                      style={{ gridTemplateColumns: "260px 1fr" }}
                    >
                      <Link
                        href={`/projects/${row.project.id}`}
                        className="flex items-center gap-2.5 border-r border-[var(--bc-border)] bg-slate-50 px-4 py-3 pl-10 text-[12px] font-medium text-slate-500"
                      >
                        <PlusCircle size={12} style={{ color }} />
                        <div>
                          <div className="leading-tight">{f.name}</div>
                          <div className="mt-0.5 text-[10.5px] text-slate-400">{status.label}</div>
                        </div>
                      </Link>
                      <div
                        className="relative min-h-[36px]"
                        style={{
                          backgroundImage:
                            "repeating-linear-gradient(to right, var(--bc-slate-200) 0 1px, transparent 1px calc(100%/12))",
                        }}
                      >
                        <div
                          className="absolute top-[10px] flex h-[16px] items-center gap-1 overflow-hidden whitespace-nowrap rounded px-1.5 text-[10.5px] font-semibold shadow-[0_1px_0_rgba(15,23,42,0.05)]"
                          style={{
                            left: `${left}%`,
                            width: `${width}%`,
                            background: isPlanned ? "#fff" : color,
                            color: isPlanned ? "var(--bc-text-secondary)" : "#fff",
                            border: isPlanned ? "1.5px dashed var(--bc-slate-400)" : "none",
                          }}
                          title={`${f.name} · ${status.label}`}
                        >
                          {f.name}
                        </div>
                        <TodayLine sub />
                      </div>
                    </div>
                  );
                })}
            </div>
          );
        })}
      </div>
    </div>
  );
}

function TodayLine({ sub = false }: { sub?: boolean }) {
  return (
    <div
      className="pointer-events-none absolute inset-y-0"
      style={{
        left: `${TODAY_PCT}%`,
        borderLeft: sub
          ? "2px dashed rgba(225, 29, 72, 0.4)"
          : "2px dashed var(--bc-danger-600)",
      }}
    >
      {!sub && (
        <span
          className="absolute -left-[22px] -top-[22px] rounded px-1.5 py-px text-[10px] font-bold text-white"
          style={{ background: "var(--bc-danger-600)" }}
        >
          Today
        </span>
      )}
    </div>
  );
}
