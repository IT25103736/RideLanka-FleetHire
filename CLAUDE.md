# VRMS — Claude working notes

Per-repo instructions for Claude Code. Read alongside the auto-memory index at
`~/.claude/projects/.../memory/MEMORY.md`. If anything below conflicts with a
memory file, the memory file usually has the longer reasoning — read it.

## Project at a glance

- **Module:** SLIIT SE1020 — Object Oriented Programming (Y1S2)
- **Deliverable:** Vehicle Rental Management System (Sri Lankan tourist market angle)
- **Owner:** Yehan Perera — group leader of 7-person team + Component-02 (Booking) implementation owner
- **Assessment shape:** CRUD + 5 OOP pillars + file I/O + 3+ JSP pages + commit history + **individual viva (dominant)**

See [user_role_vrms_leader.md](../../../../.claude/projects/c--Users-admin-Documents-SLIIT-Y1S2-OOP-Project-SE1020-vehicleRental/memory/user_role_vrms_leader.md)
and [project_vrms_viva_prep.md](../../../../.claude/projects/c--Users-admin-Documents-SLIIT-Y1S2-OOP-Project-SE1020-vehicleRental/memory/project_vrms_viva_prep.md).

## Locked stack — do not introduce alternatives

- Java + Spring Boot 3, Jakarta servlets, JSP views
- Plain `.txt` files in [data/](data/) are the current persistence layer. A database is now permitted (examiner relaxed the constraint — see [project_vrms_db_constraint_relaxed.md](../../../../.claude/projects/c--Users-admin-Documents-SLIIT-Y1S2-OOP-Project-SE1020-vehicleRental/memory/project_vrms_db_constraint_relaxed.md)) but no migration has happened yet; do not start one without an explicit ask.
- Custom CSS in [src/main/resources/static/css/vrms-theme.css](src/main/resources/static/css/vrms-theme.css) — Tailwind/Bootstrap are aspirational only, do not add as build deps
- No new frameworks, no migration to React/Next/etc. (the Next.js dashboard kit referenced in memory is for *other* projects)

## Data file format

**All `.txt` files in [data/](data/) are pipe-delimited (`|`), not comma.** The
README schema block shows commas — it is stale; trust the actual files.

Header lines beginning with `#` are comments and must be skipped by parsers.
When adding fields, append to the right; never reorder existing columns
(seeded rows in committed `.txt` files will break).

## Design language (locked)

Dark + seafoam (`#6FCBA3`) + Liquid Glass. Full token list and rationale in
[feedback_vrms_design_language.md](../../../../.claude/projects/c--Users-admin-Documents-SLIIT-Y1S2-OOP-Project-SE1020-vehicleRental/memory/feedback_vrms_design_language.md).

Quick rules:
- Use `var(--bx-primary)` for accents — never hardcode `#405ff2` or any blue
- Use `var(--bx-ink)` / `var(--bx-body)` for text — never `color: #000`
- New surfaces default to `.glass` / `.glass-strong` utilities
- The VRMS logo lockup is **locked** (~6 iterations to land it) — do not re-glass-wrap it
- Hero has no search box; floating glass search strip reveals at `scrollY > 220`

## Git conventions

- Branches: `main` (stable) / `dev` (integration) / `feature/component-01..06`
- Commit prefixes: `feat:` `fix:` `ui:` `polish:` `docs:` `chore:`
- Active branch is `dev`; integration merges land here before promoting to `main`
- Final-submission tag will be `v1.0` (not yet created as of last memory update — verify)

## Working style with this user

- **One fix at a time, with review between iterations.** Do not batch multiple
  fixes into a single change unless asked.
- Frame VRMS discussions leader-first (architecture, integration, branch strategy),
  then drill into Component-02 specifics.
- For deep code questions on C01/C03/C04/C05/C06, defer to that component's owner
  rather than letting Yehan claim implementation he did not write.
- Every UI change must preserve or demonstrate an OOP pillar (point to abstract
  `Booking`, the `VehicleFilter` hierarchy, `Payment` polymorphism, etc.) — this
  is viva ammunition.
- Viva is imminent; favor changes that are easy to *explain orally* over clever
  abstractions that are hard to defend.

## Don't

- Don't reintroduce the old electric-blue (`#405ff2`) / light-paper Boxcar palette
- Don't rewrite the logo lockup
- Don't put the search bar back in the hero
- Don't edit seeded `.txt` rows without checking parsers — column order is load-bearing
- Don't skip pre-commit hooks or amend pushed commits
