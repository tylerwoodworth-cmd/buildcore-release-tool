-- BuildCore Release Tool v2 — seed data
--
-- Reproduces the same realistic mock data the prototype uses, so the new
-- app feels populated from day one. Re-runnable: deletes all rows first,
-- then re-inserts with stable UUIDs.

-- ---------------------------------------------------------------------------
-- Wipe (in order respecting FKs)
-- ---------------------------------------------------------------------------
truncate table
  activity_events,
  tasks,
  ideas,
  pending_updates,
  test_cases,
  feedback_items,
  ticket_activity,
  ticket_files,
  ticket_acceptance,
  feature_tickets,
  tickets,
  features,
  phase_items,
  lifecycle_phases,
  projects
restart identity cascade;

-- ---------------------------------------------------------------------------
-- Projects
-- ---------------------------------------------------------------------------
insert into projects (id, name, description, color, status, status_kind, completion, target_release_date, owner, objective, audience, success_metrics, external_repo, sort_order)
values
  ('11111111-1111-1111-1111-000000000001',
   'Bid Sheet v2',
   'Full rewrite of the bid sheet experience with vendor sourcing and approval workflow.',
   '#008C95', 'On track', 'success', 64, '2026-07-15', 'Tyler W.',
   'Cut the time from project award to vendor-approved bid from 9 days to 3, and stop the leakage of approved bids that bypass scope sign-off.',
   'Project managers, operations directors, and vendor coordinators who create and approve bids on every BuildCore project.',
   array[
     'Median time-to-approved-bid under 3 business days',
     'Zero approved bids without a corresponding scope sign-off',
     'PM satisfaction score (in-app survey) above 4 of 5'
   ],
   'evanedgeworth/Bid-Sheet-v2', 1),

  ('11111111-1111-1111-1111-000000000002',
   'Client portal migration',
   'Migrate legacy client portal users and orders to the new BuildCore portal.',
   '#D97706', 'At risk', 'warning', 38, '2026-08-30', 'Tyler W.',
   'Move every active client off the legacy portal and on to the new BuildCore portal without losing their order history, saved preferences, or sign-in continuity.',
   'All active BuildCore clients and the support team who fields their tickets.',
   array[
     'Less than 1% of active clients hit a login error in week one',
     'Zero data-loss incidents on order history',
     'Support ticket volume returns to baseline within two weeks'
   ],
   'evanedgeworth/buildcore-client-portal', 2),

  ('11111111-1111-1111-1111-000000000003',
   'BuildCore feedback tracker',
   'In-portal feedback widget that creates tickets and routes to the right project automatically.',
   '#7C3AED', 'On track', 'success', 22, '2026-10-01', 'Tyler W.',
   'Give every user a one-click way to send feedback from anywhere in BuildCore, with the resulting ticket auto-routed to the correct project owner.',
   'All BuildCore portal users plus the product owner who triages incoming feedback.',
   array[
     'Median time from feedback submitted to ticket triaged under 2 hours',
     'Auto-routing accuracy above 80% (correct project on first try)',
     'At least 25% of weekly active users submit feedback in the first month'
   ],
   'evanedgeworth/buildcore-portal', 3);

-- ---------------------------------------------------------------------------
-- Lifecycle phases — Bid Sheet v2
-- ---------------------------------------------------------------------------
insert into lifecycle_phases (id, project_id, type, name, color, sort_order, start_month, end_month)
values
  ('22222222-1111-0001-0001-000000000001', '11111111-1111-1111-1111-000000000001', 'planning',    'Planning',      'purple',  1, 0.0, 1.5),
  ('22222222-1111-0001-0001-000000000002', '11111111-1111-1111-1111-000000000001', 'development', 'Development',   'brand',   2, 1.5, 4.0),
  ('22222222-1111-0001-0001-000000000003', '11111111-1111-1111-1111-000000000001', 'preparation', 'Preparation',   'info',    3, 4.0, 5.5),
  ('22222222-1111-0001-0001-000000000004', '11111111-1111-1111-1111-000000000001', 'golive',      'Go-live Phase 1','success',4, 5.5, 7.0),
  ('22222222-1111-0001-0001-000000000005', '11111111-1111-1111-1111-000000000001', 'feedback',    'Feedback',      'warning', 5, 7.0, 10.0);

-- Client portal migration
insert into lifecycle_phases (id, project_id, type, name, color, sort_order, start_month, end_month)
values
  ('22222222-1111-0002-0001-000000000001', '11111111-1111-1111-1111-000000000002', 'planning',    'Planning',       'purple',  1, 1.0, 2.5),
  ('22222222-1111-0002-0001-000000000002', '11111111-1111-1111-1111-000000000002', 'development', 'Development',    'brand',   2, 2.5, 5.0),
  ('22222222-1111-0002-0001-000000000003', '11111111-1111-1111-1111-000000000002', 'preparation', 'Preparation',    'info',    3, 5.0, 6.5),
  ('22222222-1111-0002-0001-000000000004', '11111111-1111-1111-1111-000000000002', 'golive',      'Go-live Phase 1','success', 4, 6.5, 8.0),
  ('22222222-1111-0002-0001-000000000005', '11111111-1111-1111-1111-000000000002', 'feedback',    'Feedback',       'warning', 5, 8.0, 11.0);

-- BuildCore feedback tracker
insert into lifecycle_phases (id, project_id, type, name, color, sort_order, start_month, end_month)
values
  ('22222222-1111-0003-0001-000000000001', '11111111-1111-1111-1111-000000000003', 'planning',    'Planning',       'purple',  1, 3.0, 4.5),
  ('22222222-1111-0003-0001-000000000002', '11111111-1111-1111-1111-000000000003', 'development', 'Development',    'brand',   2, 4.5, 7.0),
  ('22222222-1111-0003-0001-000000000003', '11111111-1111-1111-1111-000000000003', 'preparation', 'Preparation',    'info',    3, 7.0, 8.5),
  ('22222222-1111-0003-0001-000000000004', '11111111-1111-1111-1111-000000000003', 'golive',      'Go-live Phase 1','success', 4, 8.5, 11.0);

-- ---------------------------------------------------------------------------
-- Phase items — Bid Sheet v2 (Planning, Development, Preparation)
-- ---------------------------------------------------------------------------
insert into phase_items (phase_id, name, owner, status, sort_order)
values
  ('22222222-1111-0001-0001-000000000001', 'MVP approval',                  'Tyler', 'complete',    1),
  ('22222222-1111-0001-0001-000000000001', 'Design approval',               'Tyler', 'complete',    2),
  ('22222222-1111-0001-0001-000000000001', 'Go-live date determined',       'Tyler', 'complete',    3),
  ('22222222-1111-0001-0001-000000000001', 'Business sign-off',             'Tyler', 'in_progress', 4),
  ('22222222-1111-0001-0001-000000000001', 'Marketing alignment',           'Tyler', 'not_started', 5),

  ('22222222-1111-0001-0001-000000000002', 'Development',                   'Evan',  'in_progress', 1),
  ('22222222-1111-0001-0001-000000000002', 'Product / engineering testing', 'Evan',  'in_progress', 2),
  ('22222222-1111-0001-0001-000000000002', 'User testing (UAT)',            'Tyler', 'in_progress', 3),
  ('22222222-1111-0001-0001-000000000002', 'QA sign-off',                   'Tyler', 'not_started', 4),

  ('22222222-1111-0001-0001-000000000003', 'Release phases determined',     'Tyler', 'in_progress', 1),
  ('22222222-1111-0001-0001-000000000003', 'Users determined',              'Tyler', 'in_progress', 2),
  ('22222222-1111-0001-0001-000000000003', 'SOPs created / updated',        'Tyler', 'in_progress', 3),
  ('22222222-1111-0001-0001-000000000003', 'User guides created',           'Tyler', 'not_started', 4),
  ('22222222-1111-0001-0001-000000000003', 'Training plan determined',      'Tyler', 'not_started', 5),
  ('22222222-1111-0001-0001-000000000003', 'User training / provisioning',  'Tyler', 'not_started', 6),
  ('22222222-1111-0001-0001-000000000003', 'Create feedback / support channels', 'Tyler', 'not_started', 7);

-- ---------------------------------------------------------------------------
-- Features — Bid Sheet v2 (driven by FEATURE_TIMELINES in the prototype)
-- ---------------------------------------------------------------------------
insert into features (id, project_id, name, description, status, sort_order, timeline_start, timeline_end)
values
  ('33333333-1111-0001-0001-000000000001', '11111111-1111-1111-1111-000000000001',
   'Vendor sourcing wizard',
   'Step-by-step wizard for finding and inviting vendors to bid, replacing the old one-shot dialog.',
   'live', 1, 1.5, 3.0),

  ('33333333-1111-0001-0001-000000000002', '11111111-1111-1111-1111-000000000001',
   'Drag-and-drop line items',
   'Reorder bid line items by dragging instead of deleting and recreating them. Notes and history are preserved.',
   'ready', 2, 2.0, 4.5),

  ('33333333-1111-0001-0001-000000000003', '11111111-1111-1111-1111-000000000001',
   'Role-based approval permissions',
   'Only users whose role grants scope approval authority can sign off on a bid. Other users see the approve button hidden or disabled.',
   'in_testing', 3, 3.0, 5.0),

  ('33333333-1111-0001-0001-000000000004', '11111111-1111-1111-1111-000000000001',
   'Scope approval gate',
   'Blocks bid approval until the project scope has been formally signed off. Prevents downstream change-order rework.',
   'in_dev', 4, 4.0, 6.0),

  ('33333333-1111-0001-0001-000000000005', '11111111-1111-1111-1111-000000000001',
   'Improved PDF export',
   'Cleaner bid sheet PDFs with better handling of long vendor names and multi-section layouts.',
   'in_dev', 5, 4.0, 6.5),

  ('33333333-1111-0001-0001-000000000006', '11111111-1111-1111-1111-000000000001',
   'Inline vendor approval editing',
   'Edit vendor approval status without leaving the bid page, replacing the slow modal-based flow.',
   'planned', 6, 5.0, 6.5),

  ('33333333-1111-0001-0001-000000000007', '11111111-1111-1111-1111-000000000001',
   'Migration: bids table backfill',
   'Backfills legacy bid data into the new schema with no downtime. Required to ship the rest of v2.',
   'in_dev', 7, 3.0, 5.5);

-- Client portal migration features
insert into features (id, project_id, name, description, status, sort_order, timeline_start, timeline_end)
values
  ('33333333-1111-0002-0001-000000000001', '11111111-1111-1111-1111-000000000002',
   'Portal login DNS cutover',
   'Repoint legacy portal login URL to the new BuildCore portal so existing bookmarks keep working.',
   'live', 1, 1.0, 2.0),

  ('33333333-1111-0002-0001-000000000002', '11111111-1111-1111-1111-000000000002',
   'User mapping import',
   'One-time script that maps every legacy user record to the new identity model, including saved preferences.',
   'in_dev', 2, 3.0, 5.5),

  ('33333333-1111-0002-0001-000000000003', '11111111-1111-1111-1111-000000000002',
   'Order history backfill',
   'Backfills every legacy order so clients see their full history on day one of the new portal.',
   'in_dev', 3, 4.0, 6.0),

  ('33333333-1111-0002-0001-000000000004', '11111111-1111-1111-1111-000000000002',
   'Migration dry-run report',
   'Run the full migration against a copy of production and produce a report showing what would change before we cut over.',
   'planned', 4, 5.0, 7.0);

-- Feedback tracker features
insert into features (id, project_id, name, description, status, sort_order, timeline_start, timeline_end)
values
  ('33333333-1111-0003-0001-000000000001', '11111111-1111-1111-1111-000000000003',
   'Floating feedback widget',
   'A small button anchored to the bottom-right of every portal page that opens a feedback form on click.',
   'in_dev', 1, 4.0, 7.0),

  ('33333333-1111-0003-0001-000000000002', '11111111-1111-1111-1111-000000000003',
   'Automatic project routing',
   'Reads the current portal route to guess which project the feedback belongs to and pre-selects it.',
   'planned', 2, 6.0, 8.0),

  ('33333333-1111-0003-0001-000000000003', '11111111-1111-1111-1111-000000000003',
   'Screenshot attachment',
   'Lets users attach a screenshot of what they were looking at when they submitted the feedback.',
   'planned', 3, 7.0, 9.0);

-- ---------------------------------------------------------------------------
-- Tickets — Bid Sheet v2
-- ---------------------------------------------------------------------------
insert into tickets (id, project_id, ref, title, stage, priority, repo, branch, pr_number, summary, background, user_story, engineering_notes, role_permission_impact, handoff_file, handoff_date)
values
  ('44444444-0001-0001-0001-000000000001', '11111111-1111-1111-1111-000000000001',
   'BC-7544', 'Role permission matrix for bid approvers',
   'on_stage', 'critical',
   'evanedgeworth/Bid-Sheet-v2', 'feat/bid-approver-permissions', 234,
   'Enforce the BuildCore permission matrix on the bid approval flow so only roles with scope_approval authority can sign off on a bid, and only when their portal area permission for projects is at least edit.',
   'The current bid sheet lets any logged-in user complete a bid approval. With nine roles now in production and three approval gates planned, we need a single permission-check layer in front of the approve action.',
   'As a Project Manager, I can only approve a bid when my role grants scope_approval authority AND my projects area is at least "edit", so that bids can''t be approved by users without the proper authority.',
   'Use the canonical permission matrix at ~/buildcore-tyler/handoffs/2026-05-24/2026-05-24-role-permissions-system-handoff.html as the source of truth.',
   'No new portal areas or authorities are introduced. This ticket is the first consumer of scope_approval.',
   '2026-05-24-role-permissions-system-handoff.html', '2026-05-24'),

  ('44444444-0001-0001-0001-000000000002', '11111111-1111-1111-1111-000000000001',
   'BC-7588', 'Add scope approval gate to bid review',
   'in_dev', 'high',
   'evanedgeworth/Bid-Sheet-v2', 'feat/scope-approval-gate', 241,
   'Insert a "Scope approval" step in the bid review flow that blocks the Approve action until the project''s scope has been signed off by a user with scope_approval authority.',
   'Field teams have been approving bids before scope sign-off was complete, creating change-order rework downstream.',
   'As an Operations Director, I can''t finalize a bid approval until the project scope has been signed off, so that we stop approving bids against unfinished scopes.',
   'Reuse the existing scope_approvals Supabase table. Don''t add a new state field — scope status is derived from latest row in scope_approvals for the project.',
   'No new portal areas. Reads scope_approval authority added in BC-7544.',
   '2026-05-25-scope-approval-gate-handoff.html', '2026-05-25'),

  ('44444444-0001-0001-0001-000000000003', '11111111-1111-1111-1111-000000000001',
   'BC-7501', 'Bid line item drag reorder',
   'ready', 'medium',
   'evanedgeworth/Bid-Sheet-v2', 'feat/bid-line-reorder', 218,
   'Let bid editors drag line items up and down within a bid section to reorder them. Order persists to the database.',
   'Currently line items appear in creation order with no way to reorder. Bid editors are deleting and re-creating items to get the right order.',
   'As a Bid Editor, I can drag a line item to a new position within its section, so I don''t have to delete and recreate items to reorder them.',
   'Use @dnd-kit/core (already in deps). Add a sort_order int column to bid_lines via migration 0089.',
   'No role or permission changes.',
   '2026-05-22-bid-line-reorder-handoff.html', '2026-05-22'),

  ('44444444-0001-0001-0001-000000000004', '11111111-1111-1111-1111-000000000001',
   'BC-7480', 'New bid creation wizard',
   'live', 'high',
   'evanedgeworth/Bid-Sheet-v2', 'feat/bid-creation-wizard', 195,
   'Multi-step wizard for creating a new bid sheet, replacing the cramped single-modal flow.',
   null, null, null, 'No role or permission changes.', null, null),

  ('44444444-0001-0001-0001-000000000005', '11111111-1111-1111-1111-000000000001',
   'BC-7472', 'Vendor card redesign',
   'live', 'low',
   'evanedgeworth/Bid-Sheet-v2', 'feat/vendor-card', 188,
   null, null, null, null, 'No role or permission changes.', null, null),

  ('44444444-0001-0001-0001-000000000006', '11111111-1111-1111-1111-000000000001',
   'BC-7591', 'Migration: bids table backfill',
   'in_dev', 'medium', 'evanedgeworth/Bid-Sheet-v2', 'chore/bids-backfill', null,
   null, null, null, null, null, null, null),

  ('44444444-0001-0001-0001-000000000007', '11111111-1111-1111-1111-000000000001',
   'BC-7611', 'Vendor approval inline editing',
   'created', 'high', 'evanedgeworth/Bid-Sheet-v2', null, null,
   null, null, null, null, null, null, null),

  ('44444444-0001-0001-0001-000000000008', '11111111-1111-1111-1111-000000000001',
   'BC-7619', 'Bid sheet PDF export styling fix',
   'created', 'medium', 'evanedgeworth/Bid-Sheet-v2', null, null,
   null, null, null, null, null, null, null);

-- Tickets — Client portal migration
insert into tickets (id, project_id, ref, title, stage, priority, repo, branch)
values
  ('44444444-0002-0001-0001-000000000001', '11111111-1111-1111-1111-000000000002', 'BC-7610', 'Portal login DNS cutover', 'live',   'high',     'evanedgeworth/buildcore-client-portal', null),
  ('44444444-0002-0001-0001-000000000002', '11111111-1111-1111-1111-000000000002', 'BC-7665', 'User mapping import script',  'in_dev', 'critical', 'evanedgeworth/buildcore-client-portal', 'feat/user-mapping'),
  ('44444444-0002-0001-0001-000000000003', '11111111-1111-1111-1111-000000000002', 'BC-7670', 'Legacy order history backfill', 'in_dev', 'high',  'evanedgeworth/buildcore-client-portal', 'feat/order-backfill'),
  ('44444444-0002-0001-0001-000000000004', '11111111-1111-1111-1111-000000000002', 'BC-7700', 'Migration dry-run report',     'created','high',     'evanedgeworth/buildcore-client-portal', null);

-- Tickets — feedback tracker
insert into tickets (id, project_id, ref, title, stage, priority)
values
  ('44444444-0003-0001-0001-000000000001', '11111111-1111-1111-1111-000000000003', 'BC-7750', 'Widget shell + open/close interaction', 'created', 'high');

-- ---------------------------------------------------------------------------
-- Feature ↔ ticket links
-- ---------------------------------------------------------------------------
insert into feature_tickets (feature_id, ticket_id) values
  -- Vendor sourcing wizard
  ('33333333-1111-0001-0001-000000000001', '44444444-0001-0001-0001-000000000004'),
  ('33333333-1111-0001-0001-000000000001', '44444444-0001-0001-0001-000000000005'),
  -- Drag-and-drop line items
  ('33333333-1111-0001-0001-000000000002', '44444444-0001-0001-0001-000000000003'),
  -- Role-based approval permissions
  ('33333333-1111-0001-0001-000000000003', '44444444-0001-0001-0001-000000000001'),
  -- Scope approval gate
  ('33333333-1111-0001-0001-000000000004', '44444444-0001-0001-0001-000000000002'),
  -- Improved PDF export
  ('33333333-1111-0001-0001-000000000005', '44444444-0001-0001-0001-000000000008'),
  -- Inline vendor approval editing
  ('33333333-1111-0001-0001-000000000006', '44444444-0001-0001-0001-000000000007'),
  -- Migration: bids table backfill
  ('33333333-1111-0001-0001-000000000007', '44444444-0001-0001-0001-000000000006'),
  -- Portal DNS cutover
  ('33333333-1111-0002-0001-000000000001', '44444444-0002-0001-0001-000000000001'),
  -- User mapping
  ('33333333-1111-0002-0001-000000000002', '44444444-0002-0001-0001-000000000002'),
  -- Order backfill
  ('33333333-1111-0002-0001-000000000003', '44444444-0002-0001-0001-000000000003'),
  -- Dry-run
  ('33333333-1111-0002-0001-000000000004', '44444444-0002-0001-0001-000000000004'),
  -- Feedback tracker widget
  ('33333333-1111-0003-0001-000000000001', '44444444-0003-0001-0001-000000000001');

-- ---------------------------------------------------------------------------
-- Ticket acceptance criteria (only for tickets with handoffs)
-- ---------------------------------------------------------------------------
insert into ticket_acceptance (ticket_id, text, checked, sort_order) values
  ('44444444-0001-0001-0001-000000000001', 'Approve button hidden when current user lacks scope_approval authority', true,  1),
  ('44444444-0001-0001-0001-000000000001', 'Approve button visible but disabled when authority present but projects area is view-only', true, 2),
  ('44444444-0001-0001-0001-000000000001', 'Server-side check rejects approval POST when caller lacks authority, returns 403', true, 3),
  ('44444444-0001-0001-0001-000000000001', 'Audit row written to bid_approval_audit on every attempt (approved AND rejected)', false, 4),
  ('44444444-0001-0001-0001-000000000001', 'Unit tests cover all 9 roles against the approve endpoint', false, 5),

  ('44444444-0001-0001-0001-000000000002', 'Bid review page shows a Scope-status banner (pending / approved / rejected)', true, 1),
  ('44444444-0001-0001-0001-000000000002', 'Approve button disabled when scope status is pending or rejected', true, 2),
  ('44444444-0001-0001-0001-000000000002', 'Tooltip explains why button is disabled', false, 3),
  ('44444444-0001-0001-0001-000000000002', 'API endpoint returns 422 with reason when scope not approved', false, 4),

  ('44444444-0001-0001-0001-000000000003', 'Drag handle visible on hover for each line item', true, 1),
  ('44444444-0001-0001-0001-000000000003', 'Drop indicator shows where the item will land', true, 2),
  ('44444444-0001-0001-0001-000000000003', 'Order persists after page refresh', true, 3),
  ('44444444-0001-0001-0001-000000000003', 'Optimistic UI — reorder visible immediately, rollback on save error', true, 4),
  ('44444444-0001-0001-0001-000000000003', 'Keyboard accessible — Up/Down arrows with modifier reorder', true, 5);

-- ---------------------------------------------------------------------------
-- Ticket files-likely-to-touch
-- ---------------------------------------------------------------------------
insert into ticket_files (ticket_id, path, note, sort_order) values
  ('44444444-0001-0001-0001-000000000001', 'src/app/(dashboard)/projects/[id]/bids/[bidId]/page.tsx', 'hide/disable Approve button', 1),
  ('44444444-0001-0001-0001-000000000001', 'src/app/api/bids/[bidId]/approve/route.ts',                'server-side authority check', 2),
  ('44444444-0001-0001-0001-000000000001', 'src/lib/permissions.ts',                                    'add hasAuthority() helper', 3),
  ('44444444-0001-0001-0001-000000000001', 'src/hooks/usePermissions.ts',                               'client hook reads current user authorities', 4),

  ('44444444-0001-0001-0001-000000000002', 'src/app/(dashboard)/projects/[id]/bids/[bidId]/page.tsx', 'add scope status banner', 1),
  ('44444444-0001-0001-0001-000000000002', 'src/components/ScopeStatusBanner.tsx',                     'new component', 2),
  ('44444444-0001-0001-0001-000000000002', 'src/app/api/bids/[bidId]/approve/route.ts',                'add scope check', 3),

  ('44444444-0001-0001-0001-000000000003', 'src/components/BidLineItemList.tsx', 'drag context + handle', 1),
  ('44444444-0001-0001-0001-000000000003', 'src/hooks/useBidLineOrder.ts',       'reorder logic + persistence', 2),
  ('44444444-0001-0001-0001-000000000003', 'src/app/api/bids/[bidId]/lines/reorder/route.ts', 'new endpoint', 3);

-- ---------------------------------------------------------------------------
-- Ticket activity log
-- ---------------------------------------------------------------------------
insert into ticket_activity (ticket_id, who, what, meta, source, occurred_at) values
  ('44444444-0001-0001-0001-000000000001', 'Evan agent', 'opened PR #234',                                 null,                  'github', now() - interval '2 hours'),
  ('44444444-0001-0001-0001-000000000001', 'Evan agent', 'pushed 4 commits to feat/bid-approver-permissions', null,              'github', now() - interval '5 hours'),
  ('44444444-0001-0001-0001-000000000001', 'Evan agent', 'moved',                                          'In dev → On stage',   'agent',  now() - interval '12 minutes'),
  ('44444444-0001-0001-0001-000000000001', 'Tyler',      'created from handoff',                           null,                  'manual', now() - interval '2 days'),

  ('44444444-0001-0001-0001-000000000002', 'Evan agent', 'opened PR #241',                                 null,                  'github', now() - interval '8 hours'),
  ('44444444-0001-0001-0001-000000000002', 'Evan agent', 'moved',                                          'Created → In dev',    'agent',  now() - interval '1 day'),
  ('44444444-0001-0001-0001-000000000002', 'Tyler',      'created from handoff',                           null,                  'manual', now() - interval '2 days'),

  ('44444444-0001-0001-0001-000000000003', 'Evan agent', 'moved',                                          'On stage → Ready',    'agent',  now() - interval '2 days'),
  ('44444444-0001-0001-0001-000000000003', 'Evan agent', 'opened PR #218',                                 null,                  'github', now() - interval '4 days'),
  ('44444444-0001-0001-0001-000000000003', 'Tyler',      'created from handoff',                           null,                  'manual', now() - interval '5 days');

-- ---------------------------------------------------------------------------
-- Feedback items
-- ---------------------------------------------------------------------------
insert into feedback_items (project_id, title, body, priority, status, source, reported_by, created_at) values
  ('11111111-1111-1111-1111-000000000001', 'Approver can''t see total before signing off', null, 'high',     'open',        'Field team',        'Jamie',       now() - interval '2 days'),
  ('11111111-1111-1111-1111-000000000001', 'PDF export cuts off long vendor names',         null, 'medium',  'open',        'BuildCore portal', 'Auto-routed', now() - interval '4 days'),
  ('11111111-1111-1111-1111-000000000001', 'Add filter for "awaiting my approval"',         null, 'medium',  'in_progress', 'Tyler',            'Tyler',       now() - interval '7 days'),
  ('11111111-1111-1111-1111-000000000001', 'Empty state copy is confusing',                 null, 'low',     'resolved',    'Field team',       'Riley',       now() - interval '7 days'),
  ('11111111-1111-1111-1111-000000000002', 'Legacy users hit 404 on first login',           null, 'critical','open',        'Client',           'ACME Corp',   now() - interval '6 hours'),
  ('11111111-1111-1111-1111-000000000002', 'Notification emails sent twice during migration', null,'high',   'in_progress', 'Support',          'Support',     now() - interval '1 day');

-- ---------------------------------------------------------------------------
-- Test cases — Bid Sheet v2
-- ---------------------------------------------------------------------------
insert into test_cases (id, project_id, feature_id, name, steps, expected, status, owner, last_run_at, failure_note, sort_order) values
  -- Vendor sourcing wizard
  ('55555555-0001-0001-0001-000000000001', '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000001', 'Select vendor type from list', array['Open new bid', 'Click Add vendor', 'Choose Plumber'], 'Wizard advances to step 2.', 'passed', 'Tyler', now() - interval '5 days', null, 1),
  ('55555555-0001-0001-0001-000000000002', '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000001', 'Search vendors by name',       array['On step 2', 'Type "Smith"'], 'Results filter to vendors with "Smith" in their name.', 'passed', 'Tyler', now() - interval '5 days', null, 2),
  ('55555555-0001-0001-0001-000000000003', '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000001', 'Send invite to vendor',        array['Pick a vendor', 'Click Send invite'], 'Vendor receives email; status moves to Invited.', 'passed', 'Tyler', now() - interval '5 days', null, 3),

  -- Drag-and-drop line items
  ('55555555-0001-0001-0001-000000000010', '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000002', 'Drag item up within a section',   array['Open a bid with 3+ line items', 'Drag item 3 to position 1'], 'Item reorders; order persists after refresh.', 'passed', 'Tyler', now() - interval '1 day', null, 1),
  ('55555555-0001-0001-0001-000000000011', '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000002', 'Drag item down within a section', array['Open a bid', 'Drag item 1 to position 3'], 'Item reorders; order persists.', 'passed', 'Tyler', now() - interval '1 day', null, 2),
  ('55555555-0001-0001-0001-000000000012', '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000002', 'Drop indicator shows correct position', array['Start dragging an item', 'Hover between items'], 'A horizontal blue line appears where the item will land.', 'passed', 'Tyler', now() - interval '1 day', null, 3),
  ('55555555-0001-0001-0001-000000000013', '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000002', 'Keyboard reorder with Cmd+Up/Down', array['Focus a line item', 'Press Cmd+Up'], 'Item moves up one position.', 'passed', 'Tyler', now() - interval '1 day', null, 4),

  -- Role-based approval permissions
  ('55555555-0001-0001-0001-000000000020', '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000003', 'Project Manager can approve',                     array['Log in as PM', 'Open a bid with scope approved', 'Click Approve'], 'Bid is marked approved.', 'passed', 'Tyler', now() - interval '4 hours', null, 1),
  ('55555555-0001-0001-0001-000000000021', '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000003', 'Field Tech cannot approve',                       array['Log in as Field Tech', 'Open a bid'], 'Approve button is hidden.', 'passed', 'Tyler', now() - interval '4 hours', null, 2),
  ('55555555-0001-0001-0001-000000000022', '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000003', 'Approve button hidden for view-only roles',       array['Log in as Auditor', 'Open a bid'], 'Approve button is hidden.', 'passed', 'Tyler', now() - interval '4 hours', null, 3),
  ('55555555-0001-0001-0001-000000000023', '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000003', 'Server rejects unauthorized approval POST',       array['As Field Tech, send POST to /api/bids/.../approve'], 'API responds 403.', 'in_progress', 'Evan', null, null, 4),
  ('55555555-0001-0001-0001-000000000024', '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000003', 'Audit log row written for every attempt',          array['Attempt an approval (success or fail)', 'Query bid_approval_audit table'], 'A new row exists with user_id, bid_id, attempted_at, and result.', 'failed', 'Evan', now() - interval '1 hour', 'No row was written when the attempt was rejected for missing authority. Audit only fires on success path.', 5),

  -- Scope approval gate
  ('55555555-0001-0001-0001-000000000030', '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000004', 'Approve disabled when scope is pending',  array['Open a bid where scope status is pending', 'Hover Approve'], 'Approve button is disabled.', 'passed', 'Tyler', now() - interval '4 hours', null, 1),
  ('55555555-0001-0001-0001-000000000031', '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000004', 'Approve disabled when scope is rejected', array['Open a bid where scope is rejected'], 'Approve button is disabled.', 'in_progress', 'Tyler', null, null, 2),
  ('55555555-0001-0001-0001-000000000032', '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000004', 'API returns 422 when scope not approved', array['Send approval POST'], 'Response is 422 with reason "scope_not_approved" and bid unchanged.', 'not_started', 'Evan', null, null, 3),

  -- Improved PDF export
  ('55555555-0001-0001-0001-000000000040', '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000005', 'Long vendor names wrap correctly',     array['Generate PDF from bid with vendor name longer than 40 chars', 'Open the PDF'], 'Vendor name wraps onto a second line; no overflow off page.', 'failed', 'Tyler', now() - interval '3 hours', 'Vendor name "Smith Construction and Renovation Services LLC" still overflows the right edge of the page on the cover page. Body sections wrap correctly — looks like the cover-page header style is missing the word-break rule.', 1),
  ('55555555-0001-0001-0001-000000000041', '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000005', 'Multi-section bid renders all sections', array['Bid with 3 sections', 'Generate PDF'], 'All three sections render in order.', 'not_started', 'Tyler', null, null, 2);

-- Test cases — Client portal migration
insert into test_cases (id, project_id, feature_id, name, steps, expected, status, owner, last_run_at, failure_note, sort_order) values
  ('55555555-0002-0001-0001-000000000001', '11111111-1111-1111-1111-000000000002', '33333333-1111-0002-0001-000000000002', 'Legacy user can log in with old email', array['Run migration', 'Log in as a legacy user'], 'Login succeeds and lands on portal home.', 'failed', 'Tyler', now() - interval '6 hours', 'After cutover, ~3% of legacy users hit a 404 page instead of the portal home. Reproduces 100% for users whose email contained a + sign.', 1);

-- ---------------------------------------------------------------------------
-- Pending updates (seeded from failed test cases)
-- ---------------------------------------------------------------------------
insert into pending_updates (project_id, type, title, description, feature_id, source_case_id, linked_ticket_refs, steps, expected, created_at)
select
  tc.project_id,
  'test_failure'::pending_type,
  tc.name,
  tc.failure_note,
  tc.feature_id,
  tc.id,
  array_remove(array(select t.ref from feature_tickets ft join tickets t on t.id = ft.ticket_id where ft.feature_id = tc.feature_id), null),
  tc.steps,
  tc.expected,
  tc.last_run_at
from test_cases tc
where tc.status = 'failed';

-- ---------------------------------------------------------------------------
-- Ideas
-- ---------------------------------------------------------------------------
insert into ideas (kind, status, title, description, value, audience, tags, owner, votes, target_project_id, target_feature_id, created_at) values
  ('new_project', 'captured', 'Mobile field photo upload with offline queue',
   'Field techs can take and attach photos to a project record from the BuildCore mobile app, even without signal. Uploads sync when connectivity returns.',
   'Field photos today get lost in text messages or never make it into the project record at all. This makes documentation reliable.',
   'Field technicians on remote job sites. PMs who need photo evidence after the fact.',
   array['mobile', 'field', 'photos'], 'Tyler', 9, null, null, '2026-05-22 16:45:00'),

  ('new_project', 'captured', 'NetSuite invoice sync nightly job',
   'Nightly job that pushes newly approved invoices from BuildCore into NetSuite without manual entry.',
   'Accounting spends 4 hours a week on dual entry. Eliminating that frees them up for analysis.',
   'Accounting team. Finance leadership reporting on cash flow.',
   array['integrations', 'netsuite', 'accounting'], 'Tyler', 3, null, null, '2026-05-15 11:00:00'),

  ('new_feature', 'approved', 'Vendor performance scorecard',
   'On every vendor page in Bid Sheet v2, show a rolling scorecard: on-time bid response rate, completion rate, average days-to-complete, dispute count.',
   'Helps PMs pick the right vendor for new work. Today they are guessing or asking around.',
   'Project managers selecting vendors.',
   array['vendors', 'analytics'], 'Evan', 5, '11111111-1111-1111-1111-000000000001', null, '2026-05-10 09:15:00'),

  ('new_feature', 'triaging', 'Auto-generate change orders from approved scope deltas',
   'When a scope is approved with changes from the prior version, automatically draft a change order doc with the differences pre-filled.',
   'PMs spend an hour per change order today. This cuts it to a 5-minute review.',
   'Project managers and operations directors.',
   array['scope', 'change-orders'], 'Tyler', 7, '11111111-1111-1111-1111-000000000001', null, '2026-05-18 14:30:00'),

  ('enhancement', 'captured', 'Bulk vendor invite from a saved list',
   'In the vendor sourcing wizard, allow selecting from a previously saved vendor list to invite multiple vendors in one click.',
   'Cuts repeat-vendor sourcing from minutes to seconds for clients who use the same vendor pool.',
   'PMs running repeat projects with the same set of subs.',
   array['vendors', 'productivity'], 'Tyler', 4, '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000001', '2026-05-23 10:00:00'),

  ('enhancement', 'captured', 'Reorder items across sections, not just within',
   'In drag-and-drop line items, allow dragging an item from one bid section into another section.',
   'Editors currently have to delete and recreate when something belongs in a different section.',
   'Bid editors restructuring complex bids.',
   array['drag-drop', 'sections'], 'Tyler', 2, '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000002', '2026-05-24 08:00:00'),

  ('enhancement', 'approved', 'Show approval gate reason on hover',
   'When the Approve button is disabled by the scope gate, show a tooltip that explains why so the user understands what to do next.',
   'Reduces support questions about why approval is blocked.',
   'Anyone trying to approve a bid that has not had its scope signed off.',
   array['ux', 'tooltips'], 'Tyler', 3, '11111111-1111-1111-1111-000000000001', '33333333-1111-0001-0001-000000000004', '2026-05-24 09:30:00');

-- ---------------------------------------------------------------------------
-- Tasks (personal to-do list)
-- ---------------------------------------------------------------------------
insert into tasks (owner, title, done, link_type, link_ref, link_project_id, link_project_name, due) values
  ('Tyler', 'Sign off on BC-7501 release',                          false, 'ticket', 'BC-7501', '11111111-1111-1111-1111-000000000001', 'Bid Sheet v2',          'today'),
  ('Tyler', 'Triage portal 404 critical from client',               false, 'feedback', null,    '11111111-1111-1111-1111-000000000002', 'Client portal migration', 'today'),
  ('Tyler', 'Write release notes for Bid Sheet v2 GA',              false, null, null, null, null, 'this_week'),
  ('Tyler', 'Draft permission matrix changes for new approver role', false, null, null, null, null, null),
  ('Tyler', 'Reply to Evan re: scope approval gate',                true,  'ticket', 'BC-7588', '11111111-1111-1111-1111-000000000001', 'Bid Sheet v2',          null);

-- ---------------------------------------------------------------------------
-- Activity events (cross-project feed for the dashboard)
-- ---------------------------------------------------------------------------
insert into activity_events (project_id, who, what, target, meta, source, occurred_at) values
  ('11111111-1111-1111-1111-000000000001', 'Evan agent',       'moved',                'BC-7544 Role permission matrix for bid approvers', 'In dev → On stage',          'agent',  now() - interval '12 minutes'),
  ('11111111-1111-1111-1111-000000000001', 'Tyler',            'created feedback',     'Approver can''t see total before signing off',     'Bid Sheet v2',               'manual', now() - interval '2 hours'),
  ('11111111-1111-1111-1111-000000000001', 'Evan agent',       'moved',                'BC-7480 New bid creation wizard',                  'Ready → Live',               'agent',  now() - interval '5 hours'),
  ('11111111-1111-1111-1111-000000000002', 'Tyler',            'updated phase',        'Preparation: SOPs created',                        'In progress → Complete',     'manual', now() - interval '1 day'),
  ('11111111-1111-1111-1111-000000000002', 'BuildCore portal', 'submitted feedback',   'Legacy users hit 404 on first login',              'Critical · Auto-routed',     'portal', now() - interval '1 day');
