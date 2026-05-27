import Link from "next/link";
import { Check, User, Link as LinkIcon } from "lucide-react";
import { Badge } from "@/components/ui/Badge";
import { IDEA_KIND_INFO, IDEA_STATUS_LABEL, PHASE_COLOR_VAR } from "@/lib/mock";
import type { Idea } from "@/lib/types";

export function IdeaCard({ idea }: { idea: Idea }) {
  const status = IDEA_STATUS_LABEL[idea.status];
  const kind = IDEA_KIND_INFO[idea.kind];
  const accent = PHASE_COLOR_VAR[kind.accent];

  return (
    <div
      className="relative flex flex-col gap-2.5 overflow-hidden rounded-[var(--bc-radius)] border border-[var(--bc-border)] bg-white p-4 shadow-[var(--bc-shadow-xs)] transition-shadow hover:shadow-[var(--bc-shadow-md)]"
    >
      <span
        className="absolute left-0 top-0 h-full w-[3px]"
        style={{ background: accent }}
      />
      <div className="flex items-start justify-between gap-2.5">
        <h4 className="text-[15px] font-semibold leading-snug">{idea.title}</h4>
        <Badge kind={status.kind}>{status.label}</Badge>
      </div>
      {idea.description && (
        <p className="text-[13px] leading-snug text-slate-500">{idea.description}</p>
      )}
      {idea.tags.length > 0 && (
        <div className="flex flex-wrap gap-1">
          {idea.tags.map((t) => (
            <span
              key={t}
              className="rounded-full bg-slate-100 px-2 py-px text-[10.5px] font-semibold text-slate-600"
            >
              {t}
            </span>
          ))}
        </div>
      )}
      <div className="mt-auto flex items-center justify-between gap-2 border-t border-slate-100 pt-2.5 text-[11.5px] text-slate-400">
        <span className="inline-flex items-center gap-1 font-semibold" style={{ color: accent }}>
          {kind.label}
        </span>
        {idea.targetProjectId && (
          <Link
            href={`/projects/${idea.targetProjectId}`}
            className="inline-flex items-center gap-1 rounded-full bg-brand-50 px-2 py-px font-semibold text-brand-700 hover:bg-brand-100"
            title={`Jump to ${idea.targetProjectName}`}
          >
            <LinkIcon size={10} />
            {idea.targetFeatureName
              ? `${idea.targetProjectName} · ${idea.targetFeatureName}`
              : idea.targetProjectName}
          </Link>
        )}
        <span className="ml-auto inline-flex items-center gap-1.5">
          <User size={11} className="text-slate-400" />
          {idea.owner}
          <span className="ml-1 inline-flex items-center gap-0.5">
            <Check size={10} />
            {idea.votes}
          </span>
        </span>
      </div>
    </div>
  );
}
