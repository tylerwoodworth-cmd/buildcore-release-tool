import { Construction } from "lucide-react";

type Props = {
  title: string;
  sub: string;
  next?: string;
};

/** Stand-in for a route until we port the real screen from the prototype.
    Keeps the layout chrome (sidebar + topbar) wired and visible. */
export function PagePlaceholder({ title, sub, next }: Props) {
  return (
    <div>
      <div className="mb-6 flex items-end justify-between gap-4">
        <div>
          <h1>{title}</h1>
          <p className="mt-1.5 text-sm text-slate-600">{sub}</p>
        </div>
      </div>

      <div
        className="rounded-[var(--bc-radius)] border border-dashed bg-white p-12 text-center"
        style={{ borderColor: "var(--bc-border)" }}
      >
        <div
          className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-xl"
          style={{ background: "var(--bc-brand-50)", color: "var(--bc-brand-600)" }}
        >
          <Construction size={22} />
        </div>
        <h3 className="mb-1.5">Page under construction</h3>
        <p className="mx-auto max-w-md text-[13px] text-slate-500">
          {next ?? "This screen will be ported from the prototype in a follow-up commit."}
        </p>
      </div>
    </div>
  );
}
