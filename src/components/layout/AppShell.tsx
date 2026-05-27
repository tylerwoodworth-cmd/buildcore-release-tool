import { Sidebar } from "./Sidebar";
import { Topbar } from "./Topbar";

/** App-wide shell. Provides the persistent sidebar + topbar layout that every
    page renders inside of. Pages render into the main content area. */
export function AppShell({ children }: { children: React.ReactNode }) {
  return (
    <div
      className="grid min-h-screen"
      style={{ gridTemplateColumns: "var(--bc-sidebar-width) 1fr" }}
    >
      <Sidebar />
      <div className="flex min-w-0 flex-col">
        <Topbar />
        <div className="w-full max-w-[1440px] p-8">{children}</div>
      </div>
    </div>
  );
}
