#!/usr/bin/env node
/**
 * One-time import: v1 Release Plan Tool → v2 Supabase.
 *
 * Reads v1 projects (JSON blobs) from the legacy Supabase project and
 * inserts them into v2 as normalized rows (projects + lifecycle_phases +
 * phase_items). The v2 has its own demo seed; this script ADDS v1
 * projects alongside by default (so you can compare). Pass --replace
 * to wipe everything in v2 first.
 *
 * Usage:
 *   node scripts/import-from-v1.mjs [--replace]
 */

import { Client } from "pg";

// v1 (read-only) — public Supabase anon key
const V1_URL = "https://utrikgdbtuiyvvpryajv.supabase.co";
const V1_ANON =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV0cmlrZ2RidHVpeXZ2cHJ5YWp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2NTk2NjIsImV4cCI6MjA5NDIzNTY2Mn0.Td96BIbgmMTwoivpggIHpxx3jf60taEQvjcjiQGMg1U";

// v2 (write) — direct Postgres via the buildcore-release-tool project's
// connection string. Loaded from local secrets file outside the repo.
import { readFileSync } from "fs";
import { homedir } from "os";
const secrets = readFileSync(`${homedir()}/.buildcore-release-supabase-secrets`, "utf8");
const dbPw = secrets.match(/^DB_PASSWORD=(.+)$/m)?.[1];
if (!dbPw) {
  console.error("DB_PASSWORD not found in ~/.buildcore-release-supabase-secrets");
  process.exit(1);
}
const V2_CONN = `postgresql://postgres:${dbPw}@db.fbrdhbxfkxywzokbdznv.supabase.co:5432/postgres`;

const replace = process.argv.includes("--replace");

// Map v1 phase types to v2 enum values
const PHASE_TYPE_MAP = {
  planning: "planning",
  development: "development",
  preparation: "preparation",
  go_live: "golive",
  feedback: "feedback",
};

const PHASE_COLOR_MAP = {
  planning: "purple",
  development: "brand",
  preparation: "info",
  golive: "success",
  feedback: "warning",
};

// Map v1 item statuses → v2 enum
const ITEM_STATUS_MAP = {
  not_started: "not_started",
  in_progress: "in_progress",
  blocked: "in_progress", // closest mapping
  complete: "complete",
  na: "na",
};

async function fetchV1Projects() {
  const res = await fetch(`${V1_URL}/rest/v1/projects?select=id,data`, {
    headers: { apikey: V1_ANON, Authorization: `Bearer ${V1_ANON}` },
  });
  if (!res.ok) throw new Error(`v1 fetch failed: ${res.status} ${await res.text()}`);
  return res.json();
}

async function main() {
  console.log("Connecting to v2 Postgres...");
  const v2 = new Client({ connectionString: V2_CONN, ssl: { rejectUnauthorized: false } });
  await v2.connect();

  if (replace) {
    console.log("--replace: truncating projects in v2...");
    await v2.query(`truncate table projects restart identity cascade`);
  }

  console.log("Fetching v1 projects...");
  const v1Rows = await fetchV1Projects();
  console.log(`v1 has ${v1Rows.length} project(s)`);

  let inserted = 0;
  let skipped = 0;
  let phasesIns = 0;
  let itemsIns = 0;

  for (const row of v1Rows) {
    const p = row.data;
    if (!p) continue;
    const id = row.id;

    // Skip if a v2 project with the same id already exists (don't clobber the demo)
    const existsRes = await v2.query("select 1 from projects where id = $1 limit 1", [id]);
    if (existsRes.rowCount > 0) {
      skipped++;
      console.log(`  skipped (already in v2): ${p.name}`);
      continue;
    }

    const totalItems = (p.phases ?? []).reduce((s, ph) => s + (ph.items ?? []).length, 0);
    const completedItems = (p.phases ?? []).reduce(
      (s, ph) => s + (ph.items ?? []).filter((i) => i.status === "complete").length,
      0,
    );
    const completion = totalItems > 0 ? Math.round((completedItems / totalItems) * 100) : 0;

    await v2.query(
      `insert into projects (id, name, description, color, status, status_kind, completion, target_release_date, owner, sort_order)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)`,
      [
        id,
        p.name ?? "Untitled",
        p.description ?? null,
        p.color ?? "#008C95",
        "Imported from v1",
        "neutral",
        completion,
        p.targetEnd && p.targetEnd.length > 0 ? p.targetEnd : null,
        "Tyler W.",
        100 + inserted, // sort imported projects after seeded
      ],
    );
    inserted++;
    console.log(`  inserted: ${p.name} (${totalItems} items, ${completion}% complete)`);

    for (const ph of p.phases ?? []) {
      const v2Type = PHASE_TYPE_MAP[ph.type] ?? "custom";
      const color = PHASE_COLOR_MAP[v2Type] ?? "neutral";
      const phaseRes = await v2.query(
        `insert into lifecycle_phases (project_id, type, name, color, sort_order)
         values ($1,$2,$3,$4,$5) returning id`,
        [id, v2Type, ph.name ?? "Phase", color, ph.order ?? 0],
      );
      const phaseId = phaseRes.rows[0].id;
      phasesIns++;

      for (let i = 0; i < (ph.items ?? []).length; i++) {
        const it = ph.items[i];
        if (!it.name || it.name.trim() === "") continue; // skip empty rows from v1
        await v2.query(
          `insert into phase_items (phase_id, name, owner, status, sort_order, notes, target_start, target_end, actual_start, actual_end)
           values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)`,
          [
            phaseId,
            it.name,
            it.owner && it.owner.trim() !== "" ? it.owner : null,
            ITEM_STATUS_MAP[it.status] ?? "not_started",
            i + 1,
            it.notes && it.notes.trim() !== "" ? it.notes : null,
            it.targetStart && it.targetStart.length === 10 ? it.targetStart : null,
            it.targetEnd && it.targetEnd.length === 10 ? it.targetEnd : null,
            it.actualStart && it.actualStart.length === 10 ? it.actualStart : null,
            it.actualEnd && it.actualEnd.length === 10 ? it.actualEnd : null,
          ],
        );
        itemsIns++;
      }
    }
  }

  console.log();
  console.log("Done.");
  console.log(`  Projects inserted: ${inserted}`);
  console.log(`  Projects skipped (already in v2): ${skipped}`);
  console.log(`  Phases inserted: ${phasesIns}`);
  console.log(`  Items inserted: ${itemsIns}`);

  await v2.end();
}

main().catch((e) => {
  console.error("Import failed:", e);
  process.exit(1);
});
