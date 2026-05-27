import { Lock } from "lucide-react";

type Props = {
  searchParams: Promise<{ next?: string; error?: string }>;
};

export default async function UnlockPage({ searchParams }: Props) {
  const { next = "/", error } = await searchParams;
  return (
    <div
      className="-m-8 flex min-h-screen items-center justify-center bg-slate-50 p-8"
      style={{ minHeight: "calc(100vh - 0px)" }}
    >
      <form
        action="/api/unlock"
        method="POST"
        className="w-[400px] max-w-full rounded-2xl border bg-white p-8 shadow-md"
        style={{ borderColor: "var(--bc-border)" }}
      >
        <div className="mb-6 flex items-center gap-3">
          <div
            className="flex h-10 w-10 items-center justify-center rounded-xl"
            style={{ background: "var(--bc-brand-50)", color: "var(--bc-brand-700)" }}
          >
            <Lock size={18} />
          </div>
          <div>
            <h3 className="m-0 text-base font-bold">BuildCore Release Tool</h3>
            <p className="text-xs text-slate-500">Enter the shared password to continue.</p>
          </div>
        </div>

        <input type="hidden" name="next" value={next} />

        <label className="mb-1.5 block text-[12px] font-semibold uppercase tracking-wider text-slate-400">
          Password
        </label>
        <input
          type="password"
          name="password"
          required
          autoFocus
          autoComplete="current-password"
          className="w-full rounded-lg border bg-slate-50 px-3 py-2.5 text-sm outline-none focus:bg-white"
          style={{ borderColor: "var(--bc-border)" }}
        />

        {error && (
          <p className="mt-3 text-[12px] font-medium text-red-700">
            Incorrect password. Try again.
          </p>
        )}

        <button
          type="submit"
          className="mt-5 w-full rounded-lg py-2.5 text-sm font-semibold text-white"
          style={{ background: "var(--bc-brand-600)" }}
        >
          Unlock
        </button>

        <p className="mt-6 text-center text-[11px] text-slate-400">
          This tool is sandboxed. It does not touch the bid-sheet-v2 production database.
        </p>
      </form>
    </div>
  );
}
