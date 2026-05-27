import { NextResponse, type NextRequest } from "next/server";

/** Password gate. The whole app is locked behind a single shared password
    until real auth is added in a later phase. Set GATE_PASSWORD in the
    environment; users enter it once at /unlock and a signed cookie keeps
    them in for 30 days. */
const COOKIE = "bc_release_gate";
const PASSWORD = process.env.GATE_PASSWORD ?? "";
const COOKIE_VALUE_VERSION = "v1"; // bump to force everyone to re-enter

export function middleware(request: NextRequest) {
  // Always allow the unlock page and its API, plus static assets and Next internals.
  const { pathname } = request.nextUrl;
  if (
    pathname.startsWith("/unlock") ||
    pathname.startsWith("/api/unlock") ||
    pathname.startsWith("/_next") ||
    pathname.startsWith("/favicon") ||
    pathname === "/robots.txt" ||
    pathname === "/sitemap.xml"
  ) {
    return NextResponse.next();
  }

  // Allow webhook endpoints (they authenticate via their own secrets).
  if (pathname.startsWith("/api/webhooks/")) {
    return NextResponse.next();
  }

  // If no password is configured, fail closed for safety.
  if (!PASSWORD) {
    if (process.env.NODE_ENV !== "production") {
      // In dev, allow through so the gate doesn't block local work before .env is set.
      return NextResponse.next();
    }
    const url = request.nextUrl.clone();
    url.pathname = "/unlock";
    return NextResponse.redirect(url);
  }

  const cookie = request.cookies.get(COOKIE)?.value;
  if (cookie === `${COOKIE_VALUE_VERSION}:${PASSWORD}`) {
    return NextResponse.next();
  }

  const url = request.nextUrl.clone();
  url.pathname = "/unlock";
  url.searchParams.set("next", pathname);
  return NextResponse.redirect(url);
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico).*)"],
};
