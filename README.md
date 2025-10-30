# Legal Conflict Checker — Assistive, Reversible, Audit-Ready

**TL;DR:** A safe, **suggestions-only** conflict-check assist that runs on intake, surfaces **ranked matches** for human review, and writes an **audit log**. It’s **feature-flagged**, **reversible**, and requires **no schema changes**. Built to explore how Clio-style intake can be both faster and more defensible.

## Why this exists (business lens)

Manual conflict checks burn **30–60 minutes** per new client and are inconsistent to document. That slows **intake completion** and weakens trust. This prototype shows a low-blast-radius path to:

* **Speed:** move conflict-hint surfacing from minutes → **seconds**.
* **Trust:** make **documented clearance** the default via an attached log.
* **Safety:** keep humans in the loop; **suggestions ≠ decisions**.

## What it does (product behavior)

When a new intake is submitted, the service runs a fuzzy similarity scan across existing **clients, prior/alias names, related parties, and matter titles**. It returns a **ranked list of “Suggested Conflicts”** to a reviewer, who would mark it as **Cleared** or **Escalate** after review. Every check produces a **timestamped Conflict Check Log** (reviewer, inputs, decision).

* **Assistive posture:** never hard-blocks intake; reviewers decide.
* **Permissions respected:** suggestions/logs respect matter/user access (ethical walls).
* **Instant rollback:** everything is behind `CONFLICT_COLLECTOR_ENABLED`.

## Success criteria (if this shipped as a pilot)

* **Intake completion %** ↑ (pilot vs matched control)
* **Median conflict-resolution time** ↓ to **< 10s** for suggestions
* **Documented clearance rate** ↑ (log attached by default)
* **Panel open rate** ≥ 80% when suggestions exist; **false-positive ceiling** ≤ 0.5%
* **Support tickets** mentioning “conflict/ethical wall” ↓

## Architecture at a glance

* **Service:** `ConflictCollector` orchestrates detectors over historical matters.
* **Detectors:** pluggable strategy classes (concurrent / lawyer-client / successive).
* **UI:** a simple **Suggested Conflicts** panel (rank + reason + action).
* **Logging:** immutable conflict-check entry per intake (decision + timestamp).
* **Ops:** feature flag `CONFLICT_COLLECTOR_ENABLED`, small PRs, tests, and rollback notes.

## Run it locally (quick start)

```bash
git clone https://github.com/J-pilon/legal-conflict-checker
cd legal-conflict-checker
bundle install
rails s
# Optional: disable assist for comparison
CONFLICT_COLLECTOR_ENABLED=false rails s
```

Submit a sample intake:

```bash
curl -X POST http://localhost:3000/new_intake/create \
  -H "Content-Type: application/json" \
  -d '{
    "matter_number":"2024-1076",
    "title":"Martinez Restaurant Group Employment Dispute",
    "client_name":"Commercial Bank",
    "client_type":"Corporation",
    "practice_area":"Employment Law",
    "matter_type":"Discrimination",
    "status":"Active",
    "opened_date":"2024-05-15",
    "adverse_parties":["Former Employee","EEOC"],
    "related_parties":["Jennifer Martinez (Legal Counsel)","HR Department Staff"],
    "assigned_attorney":"Sarah Williams",
    "description":"Employment contract negotiation for senior physician position"
  }'
```

Open the dashboard: `http://localhost:3000/dashboard`

## Safety rails (non-negotiables)

* **Feature-flagged & reversible:** kill-switch via `CONFLICT_COLLECTOR_ENABLED`.
* **Suggestive, not dispositive:** humans review; no auto-declines in v1.
* **No schema change required** for this prototype.
* **No external calls / PII egress:** data stays within the app boundary.
* **Permissions honored:** no leakage across ethical walls.

## Links (proof & context)

* **Risk Brief (1-pager):** *[Clio Risk Brief](https://docs.google.com/document/d/14FJi-sjk3aj_fNPVaOa0v5mm6L8011yPgGm2pxUfFQ8/edit?usp=sharing)*
* **PR #5:** conflict detector logic — [https://github.com/J-pilon/legal-conflict-checker/pull/5](https://github.com/J-pilon/legal-conflict-checker/pull/5)
* **PR #6:** UI dashboard + detected conflicts modal — [https://github.com/J-pilon/legal-conflict-checker/pull/6](https://github.com/J-pilon/legal-conflict-checker/pull/6)
* **PR #7:** feature flag logic — [https://github.com/J-pilon/legal-conflict-checker/pull/7](https://github.com/J-pilon/legal-conflict-checker/pull/7)

## What’s in here (tech map)

* **Models:** `LegalMatter`, `Attorney`
* **Service:** `ConflictCollector` (fan-out, aggregate, rank)
* **Detectors:**

  * `ConcurrentConflictDetector` — party/alias clashes
  * `LawyerClientConflictDetector` — attorney interest vs former client
  * `SuccessiveConflictDetector` — matter/title/description proximity
* **Controllers/Views:** `NewIntakeController`, `DashboardController`

## Roadmap (safe next steps)

* **Phase 2 (not in this prototype):** reviewer-triggered **non-engagement** / **waiver** templates (human-approved, logged, attached to matter).
* **Threshold tuning:** per-firm config + offline evaluation set.
* **More detectors:** opposing counsel graphs; phonetic/locale variants.
* **Metrics collector:** counters for suggestions/opens/decisions to drive the KPIs above.

