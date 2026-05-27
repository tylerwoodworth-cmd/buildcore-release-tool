-- BuildCore Release Tool v2 — initial schema
--
-- Single-tenant tool gated by a shared password. All writes go through
-- Next.js API routes using the service role key. The browser reads via the
-- anon key with read-only RLS policies; Supabase Realtime pushes row changes
-- on the listed tables.
--
-- This database is the new Release Tool's database. It is intentionally
-- separate from bid-sheet-v2. Webhooks bring data IN (one-way). Nothing
-- in this schema is ever written back to bid-sheet-v2.

-- ---------------------------------------------------------------------------
-- Extensions
-- ---------------------------------------------------------------------------
create extension if not exists "pgcrypto";  -- gen_random_uuid()

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
create type project_status_kind as enum ('success', 'warning', 'danger', 'info', 'neutral');
create type phase_type          as enum ('planning', 'development', 'preparation', 'golive', 'feedback', 'custom');
create type item_status         as enum ('not_started', 'in_progress', 'complete', 'na');
create type feature_status      as enum ('planned', 'in_design', 'in_dev', 'in_testing', 'ready', 'live');
create type ticket_stage        as enum ('created', 'in_dev', 'on_stage', 'ready', 'live');
create type ticket_priority     as enum ('low', 'medium', 'high', 'critical');
create type feedback_priority   as enum ('low', 'medium', 'high', 'critical');
create type feedback_status     as enum ('open', 'in_progress', 'resolved');
create type test_status         as enum ('not_started', 'in_progress', 'passed', 'failed', 'blocked');
create type idea_kind           as enum ('new_project', 'new_feature', 'enhancement');
create type idea_status         as enum ('captured', 'triaging', 'approved', 'in_project', 'rejected');
create type pending_type        as enum ('test_failure', 'feedback', 'manual');
create type task_link_type      as enum ('ticket', 'feedback', 'phase');

-- ---------------------------------------------------------------------------
-- Trigger function: touch updated_at on every UPDATE
-- ---------------------------------------------------------------------------
create or replace function touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Projects
-- ---------------------------------------------------------------------------
create table projects (
  id                  uuid primary key default gen_random_uuid(),
  name                text not null,
  description         text,
  color               text not null default '#008C95',
  status              text,                                          -- "On track", "At risk", "Delayed"
  status_kind         project_status_kind default 'success',
  completion          smallint default 0 check (completion between 0 and 100),
  target_release_date date,
  owner               text,
  objective           text,
  audience            text,
  success_metrics     text[],
  external_repo       text,                                          -- evanedgeworth/Bid-Sheet-v2
  sort_order          int default 0,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);
create index projects_sort_idx on projects(sort_order);
create trigger projects_touch before update on projects
  for each row execute function touch_updated_at();

-- ---------------------------------------------------------------------------
-- Lifecycle phases (per project)
-- ---------------------------------------------------------------------------
create table lifecycle_phases (
  id           uuid primary key default gen_random_uuid(),
  project_id   uuid not null references projects(id) on delete cascade,
  type         phase_type not null,
  name         text not null,
  color        text not null,                                        -- token id: purple|brand|info|success|warning|...
  sort_order   int  not null,
  start_month  numeric(4,2),                                         -- 0-12 month index for the demo gantt
  end_month    numeric(4,2),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create index lifecycle_phases_project_idx on lifecycle_phases(project_id, sort_order);
create trigger lifecycle_phases_touch before update on lifecycle_phases
  for each row execute function touch_updated_at();

-- ---------------------------------------------------------------------------
-- Phase items (checklist items inside a phase)
-- ---------------------------------------------------------------------------
create table phase_items (
  id            uuid primary key default gen_random_uuid(),
  phase_id      uuid not null references lifecycle_phases(id) on delete cascade,
  name          text not null,
  owner         text,
  status        item_status default 'not_started',
  sort_order    int not null,
  notes         text,
  target_start  date,
  target_end    date,
  actual_start  date,
  actual_end    date,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create index phase_items_phase_idx on phase_items(phase_id, sort_order);
create trigger phase_items_touch before update on phase_items
  for each row execute function touch_updated_at();

-- ---------------------------------------------------------------------------
-- Features (per project — the master list driving the roadmap)
-- ---------------------------------------------------------------------------
create table features (
  id              uuid primary key default gen_random_uuid(),
  project_id      uuid not null references projects(id) on delete cascade,
  name            text not null,
  description     text,
  status          feature_status default 'planned',
  sort_order      int default 0,
  timeline_start  numeric(4,2),                                      -- 0-12 month index
  timeline_end    numeric(4,2),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index features_project_idx on features(project_id, sort_order);
create index features_status_idx  on features(status);
create trigger features_touch before update on features
  for each row execute function touch_updated_at();

-- ---------------------------------------------------------------------------
-- Tickets (synced from GitHub via webhook)
-- ---------------------------------------------------------------------------
create table tickets (
  id                       uuid primary key default gen_random_uuid(),
  project_id               uuid references projects(id) on delete set null,
  ref                      text not null unique,                     -- BC-7544
  title                    text not null,
  stage                    ticket_stage default 'created',
  priority                 ticket_priority default 'medium',
  repo                     text,
  branch                   text,
  pr_number                int,
  summary                  text,
  background               text,
  user_story               text,
  engineering_notes        text,
  role_permission_impact   text,
  handoff_file             text,
  handoff_date             date,
  last_synced_at           timestamptz,
  created_at               timestamptz not null default now(),
  updated_at               timestamptz not null default now()
);
create index tickets_project_idx on tickets(project_id);
create index tickets_stage_idx   on tickets(stage);
create trigger tickets_touch before update on tickets
  for each row execute function touch_updated_at();

-- ---------------------------------------------------------------------------
-- Feature ↔ ticket many-to-many
-- ---------------------------------------------------------------------------
create table feature_tickets (
  feature_id  uuid not null references features(id) on delete cascade,
  ticket_id   uuid not null references tickets(id)  on delete cascade,
  sort_order  int default 0,
  primary key (feature_id, ticket_id)
);
create index feature_tickets_ticket_idx on feature_tickets(ticket_id);

-- ---------------------------------------------------------------------------
-- Ticket acceptance criteria
-- ---------------------------------------------------------------------------
create table ticket_acceptance (
  id          uuid primary key default gen_random_uuid(),
  ticket_id   uuid not null references tickets(id) on delete cascade,
  text        text not null,
  checked     boolean default false,
  sort_order  int not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create index ticket_acceptance_ticket_idx on ticket_acceptance(ticket_id, sort_order);
create trigger ticket_acceptance_touch before update on ticket_acceptance
  for each row execute function touch_updated_at();

-- ---------------------------------------------------------------------------
-- Ticket files-likely-to-touch
-- ---------------------------------------------------------------------------
create table ticket_files (
  id          uuid primary key default gen_random_uuid(),
  ticket_id   uuid not null references tickets(id) on delete cascade,
  path        text not null,
  note        text,
  sort_order  int not null,
  created_at  timestamptz not null default now()
);
create index ticket_files_ticket_idx on ticket_files(ticket_id, sort_order);

-- ---------------------------------------------------------------------------
-- Ticket activity log (from the agent's webhook updates)
-- ---------------------------------------------------------------------------
create table ticket_activity (
  id           uuid primary key default gen_random_uuid(),
  ticket_id    uuid not null references tickets(id) on delete cascade,
  who          text not null,                                        -- "Evan agent" | "Tyler" | ...
  what         text not null,                                        -- "moved", "opened PR", ...
  meta         text,                                                 -- "In dev → On stage"
  source       text,                                                 -- "github" | "agent" | "manual"
  occurred_at  timestamptz not null default now()
);
create index ticket_activity_ticket_idx   on ticket_activity(ticket_id, occurred_at desc);
create index ticket_activity_occurred_idx on ticket_activity(occurred_at desc);

-- ---------------------------------------------------------------------------
-- Feedback items
-- ---------------------------------------------------------------------------
create table feedback_items (
  id                    uuid primary key default gen_random_uuid(),
  project_id            uuid not null references projects(id) on delete cascade,
  title                 text not null,
  body                  text,
  priority              feedback_priority default 'medium',
  status                feedback_status default 'open',
  source                text,                                        -- "BuildCore portal" | "Field team" | "Tyler"
  linked_test_case_id   uuid,                                        -- soft link (FK added after test_cases below)
  reported_by           text,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);
create index feedback_items_project_idx on feedback_items(project_id, created_at desc);
create index feedback_items_status_idx  on feedback_items(status);
create trigger feedback_items_touch before update on feedback_items
  for each row execute function touch_updated_at();

-- ---------------------------------------------------------------------------
-- Test cases (per project, optionally scoped to a feature)
-- ---------------------------------------------------------------------------
create table test_cases (
  id            uuid primary key default gen_random_uuid(),
  project_id    uuid not null references projects(id) on delete cascade,
  feature_id    uuid references features(id) on delete set null,
  name          text not null,
  description   text,
  steps         text[],
  expected      text,
  status        test_status default 'not_started',
  owner         text,
  last_run_at   timestamptz,
  failure_note  text,
  sort_order    int default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create index test_cases_project_idx on test_cases(project_id, sort_order);
create index test_cases_feature_idx on test_cases(feature_id);
create index test_cases_status_idx  on test_cases(status);
create trigger test_cases_touch before update on test_cases
  for each row execute function touch_updated_at();

-- Add the deferred soft-link FK on feedback_items now that test_cases exists
alter table feedback_items
  add constraint feedback_items_linked_test_case_fkey
  foreign key (linked_test_case_id) references test_cases(id) on delete set null;

-- ---------------------------------------------------------------------------
-- Pending updates (engineering handoff outbox)
-- ---------------------------------------------------------------------------
create table pending_updates (
  id                  uuid primary key default gen_random_uuid(),
  project_id          uuid not null references projects(id) on delete cascade,
  type                pending_type not null,
  title               text not null,
  description         text,
  feature_id          uuid references features(id) on delete set null,
  source_case_id      uuid references test_cases(id) on delete set null,
  source_feedback_id  uuid references feedback_items(id) on delete set null,
  linked_ticket_refs  text[],
  steps               text[],
  expected            text,
  sent_at             timestamptz,                                   -- null until "Mark all sent"
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);
create index pending_updates_project_idx on pending_updates(project_id, created_at desc);
create index pending_updates_type_idx    on pending_updates(type);
create trigger pending_updates_touch before update on pending_updates
  for each row execute function touch_updated_at();

-- ---------------------------------------------------------------------------
-- Ideas (3 kinds — new_project, new_feature, enhancement)
-- ---------------------------------------------------------------------------
create table ideas (
  id                 uuid primary key default gen_random_uuid(),
  kind               idea_kind not null default 'new_project',
  status             idea_status default 'captured',
  title              text not null,
  description        text,
  value              text,
  audience           text,
  tags               text[],
  owner              text,
  votes              int default 0,
  target_project_id  uuid references projects(id) on delete set null,
  target_feature_id  uuid references features(id) on delete set null,
  linked_project_id  uuid references projects(id) on delete set null,  -- populated when promoted
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);
create index ideas_kind_idx       on ideas(kind);
create index ideas_status_idx     on ideas(status);
create index ideas_target_proj_idx on ideas(target_project_id);
create index ideas_target_feat_idx on ideas(target_feature_id);
create trigger ideas_touch before update on ideas
  for each row execute function touch_updated_at();

-- ---------------------------------------------------------------------------
-- Tasks (personal to-do list for the current user — Tyler for now)
-- ---------------------------------------------------------------------------
create table tasks (
  id                 uuid primary key default gen_random_uuid(),
  owner              text not null default 'Tyler',
  title              text not null,
  done               boolean default false,
  link_type          task_link_type,
  link_ref           text,                                           -- ticket ref / feedback id / phase item id
  link_project_id    uuid references projects(id) on delete set null,
  link_project_name  text,                                           -- snapshot for display when project is gone
  due                text,                                           -- 'today' | 'this_week' | null (loose for now)
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);
create index tasks_owner_idx on tasks(owner, done, created_at desc);
create trigger tasks_touch before update on tasks
  for each row execute function touch_updated_at();

-- ---------------------------------------------------------------------------
-- Activity events (cross-project feed)
-- ---------------------------------------------------------------------------
create table activity_events (
  id           uuid primary key default gen_random_uuid(),
  project_id   uuid references projects(id) on delete set null,
  who          text not null,                                        -- "Evan agent" | "Tyler" | "BuildCore portal"
  what         text not null,                                        -- "moved" | "created feedback" | ...
  target       text,
  meta         text,
  source       text,                                                 -- "github" | "portal" | "manual" | "agent"
  occurred_at  timestamptz not null default now()
);
create index activity_events_occurred_idx on activity_events(occurred_at desc);
create index activity_events_project_idx  on activity_events(project_id, occurred_at desc);

-- ---------------------------------------------------------------------------
-- Row Level Security
--
-- Single-tenant tool gated by a shared password. All writes use the service
-- role key from server-side code (which bypasses RLS). The browser uses the
-- anon key and gets SELECT-only access. The password gate is the actual
-- access control; RLS is defense-in-depth.
-- ---------------------------------------------------------------------------
do $$
declare
  t text;
begin
  for t in select tablename from pg_tables where schemaname = 'public'
  loop
    execute format('alter table %I enable row level security', t);
    execute format(
      'create policy "anon read %I" on %I for select to anon using (true)',
      t, t
    );
    execute format(
      'create policy "auth read %I" on %I for select to authenticated using (true)',
      t, t
    );
  end loop;
end $$;

-- ---------------------------------------------------------------------------
-- Realtime publication
-- ---------------------------------------------------------------------------
alter publication supabase_realtime add table
  projects,
  lifecycle_phases,
  phase_items,
  features,
  tickets,
  feature_tickets,
  ticket_acceptance,
  ticket_files,
  ticket_activity,
  feedback_items,
  test_cases,
  pending_updates,
  ideas,
  tasks,
  activity_events;
