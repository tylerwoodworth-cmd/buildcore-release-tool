import { NextResponse, type NextRequest } from "next/server";

const COOKIE = "bc_release_gate";
const COOKIE_VALUE_VERSION = "v1";
const THIRTY_DAYS = 60 * 60 * 24 * 30;

export async function POST(request: NextRequest) {
  const form = await request.formData();
  const password = String(form.get("password") ?? "");
  const next = String(form.get("next") ?? "/");
  const expected = process.env.GATE_PASSWORD ?? "";

  if (!expected || password !== expected) {
    const url = request.nextUrl.clone();
    url.pathname = "/unlock";
    url.searchParams.set("next", next);
    url.searchParams.set("error", "1");
    return NextResponse.redirect(url, { status: 303 });
  }

  // Avoid open-redirect: only honor relative paths within this app.
  const safeNext = next.startsWith("/") && !next.startsWith("//") ? next : "/";

  const url = request.nextUrl.clone();
  url.pathname = safeNext;
  url.search = "";
  const response = NextResponse.redirect(url, { status: 303 });
  response.cookies.set(COOKIE, `${COOKIE_VALUE_VERSION}:${expected}`, {
    httpOnly: true,
    sameSite: "lax",
    secure: process.env.NODE_ENV === "production",
    path: "/",
    maxAge: THIRTY_DAYS,
  });
  return response;
}
