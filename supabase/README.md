# Supabase setup

This directory contains the **schema migration** and a **seed file** for the BuildCore Release Tool's database.

> ⚠️ **Separate from bid-sheet-v2.** Apply these to the *Release Tool's* Supabase project, not the bid-sheet-v2 production project. Confirm the project URL before running anything.

## Contents

- `migrations/0001_initial_schema.sql` — full schema: tables, enums, indexes, triggers, RLS policies, realtime publication.
- `seed.sql` — realistic demo data that mirrors the prototype (3 projects, full feature lists, tickets, test cases, ideas, etc.). Re-runnable: it truncates first.

## How to apply

### Option A — Supabase Studio (web UI), easiest

1. Open your Release Tool project in [supabase.com](https://supabase.com).
2. Sidebar → **SQL Editor** → **New query**.
3. Paste the contents of `migrations/0001_initial_schema.sql` → **Run**.
4. New query → paste `seed.sql` → **Run**.

That's it. The schema is in and the seed data is loaded.

### Option B — Supabase CLI, local + remote

```bash
brew install supabase/tap/supabase

# One-time link to your remote project
supabase login
supabase link --project-ref <YOUR_PROJECT_REF>

# Apply the migration
supabase db push

# Apply the seed (raw psql)
supabase db reset --linked        # ⚠️ wipes the linked DB — only if you're certain
# OR run seed manually:
psql "<connection string>" -f supabase/seed.sql
```

## After applying

1. Copy the **anon public key** and **service role key** from Supabase Project → Settings → API.
2. Paste into `.env.local`:

```
NEXT_PUBLIC_SUPABASE_URL=https://<your-ref>.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...
```

3. Restart `npm run dev`.

## What the schema looks like (high level)

```
projects                  – top-level project entity
  └ lifecycle_phases       – Planning, Development, Preparation, Go-live, Feedback (+ custom)
     └ phase_items          – checklist items
  └ features                – product features list (drives the Roadmap)
     └ feature_tickets       – many-to-many with tickets
  └ tickets                 – synced from GitHub
     ├ ticket_acceptance    – acceptance criteria checkboxes
     ├ ticket_files         – files likely to touch
     └ ticket_activity      – activity log
  └ feedback_items
  └ test_cases              – feature-scoped
  └ pending_updates         – handoff outbox

ideas                     – the 3-kind backlog (new_project/new_feature/enhancement)
tasks                     – personal to-do list
activity_events           – cross-project feed
```

## Security model

- **Service role key (server-only)** writes everything. Used by Next.js API routes (webhooks, server actions).
- **Anon key (browser)** has SELECT-only via RLS policies. Subscribes to Supabase Realtime channels.
- **Password gate middleware** is the actual access control — RLS is defense in depth.

Nothing in the browser ever holds the service role key. It only lives in environment variables on the server.
