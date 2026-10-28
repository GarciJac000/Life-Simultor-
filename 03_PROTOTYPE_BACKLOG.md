# LIFE//MODE — Prototype Implementation Backlog

**Release candidate:** V0.1 desktop vertical slice  
**Priority definitions:** P0 = mandatory playable loop; P1 = credibility/polish for first external test; P2 = future scope.  
**Execution rule:** Complete milestone QC before expanding scope. Keep previous passing behavior intact.

## Milestone 0 — Project boot + world blockout (P0)

- [ ] Initialize a fresh Godot 4.7.2 stable project and Git repository; no protected or existing project asset changes.
- [ ] Project conventions, input mapping, folder tree, version note, baseline CI-style export check (if environment available).
- [ ] Build 250 m x 250 m graybox city block with sidewalks, simple streets, and six clearly labeled functional locations.
- [ ] `Player` third-person walk, sprint, camera orbit, collision, 2.5m targeting + E interaction.
- [ ] Basic interaction toast, `Esc` pause and `M` map landmark overlay.

**QC gate:** Player can traverse entire block, enter/exit apartment and cafe (stub interiors), interact with six markers, never clip below ground, and close/reopen menus without stuck controls.

## Milestone 1 — Time, needs, economy, and HUD (P0)

- [ ] Canonical GameState and integer-minute WorldClock with 10-minute tick system.
- [ ] Six needs, clamping and decay; activity action resolver.
- [ ] Working cafe job +$120 for 4 game hours; other jobs reuse same system.
- [ ] Market groceries, cafe meal, home meal, shower, and sleep.
- [ ] Bank display, transaction log, $300 weekly rent due Day 8 00:00, arrears recovery rule.
- [ ] HUD and phone tabs Today/Map/Wallet/Goals (People placeholder acceptable this milestone).

**QC gate:** One full day produces consistent balance, needs, time, action receipts; two independent calls spanning rent boundary charge rent once; sleeping advances NPC/event clock without duplicated ticks.

## Milestone 2 — Living neighborhood and relationships (P0)

- [ ] NPC data files and schedule routines for all 12; 4 featured with custom dialogue.
- [ ] Navigation mesh and safe route-finding for on-screen NPCs.
- [ ] Featured affinity, trust, 5-memory ring, scheduled check-in, relationships UI.
- [ ] Four unique conversations with conditional reactions; failed meeting consequence.
- [ ] All four interiors furnished with functional interactable stations; outdoor park and workout node.

**QC gate:** Featured NPC appears at expected schedule location; dialogue choices affect affinity; saving after an NPC promise preserves subsequent conditional reaction; no visible teleport in repeated transitions.

## Milestone 3 — Meaningful first week and persistence (P0)

- [ ] Intro tutorial (skippable), optional objective board, event director with 8 authored events.
- [ ] Three jobs available on conditions; creative studio action + XP gates.
- [ ] Local save/load versioned file, backup, safe-save boundaries.
- [ ] End-of-day and first-week recaps; calendar invitation and missed-promise feedback.
- [ ] Automated tests for rent, tick advancement, stats, invalid interactions, event repeatability, save round-trip.

**QC gate:** Fresh game -> work -> groceries -> friendship -> sleep -> calendar invite -> rent due -> save -> quit -> reload -> continue works without developer command panel. Unit/integration tests pass.

## Milestone 4 — V0.1 usability and optimization (P1)

- [ ] Replace graybox with consistent licensed modular art, basic animations/audio.
- [ ] Lighting morning/evening, NPC animation LOD, occlusion/visibility tuning.
- [ ] Text size scaling 100/125/150, subtitles, no color-only status, camera shake toggle.
- [ ] Playtest tutorial hints, clear choice cost/time panels, failure recovery, sound controls.
- [ ] Test on recorded hardware at 1080p; document FPS and crashes; resolve P0/P1 issues.

**QC gate:** Five first-time playtests; >=4 finish a job and create a friendship without live guidance; >=4 explain stat changes; 30 uninterrupted min of play; target performance met or exceptions explicitly logged and accepted.

## Mandatory playable vertical slice path

1. New Game -> choose Alex preset -> spawn in apartment Day 1 09:00, $1,250.
2. Walk outside -> cafe -> E talk to Maya -> choose Work Shift; clock +4h, bank +$120, Energy net decreases, XP increases.
3. Open phone -> read ledger, rent due date, and highlighted optional objectives.
4. Buy groceries at market for $35 -> inventory +5 -> return home and eat one portion.
5. Meet Devon at park -> chat; social stat and Devon affinity improve; new context line appears.
6. Visit Jules at studio -> choose music practice -> creative XP, mood and time update.
7. Sleep until 07:00 -> calendar progresses and an NPC invitation becomes eligible.
8. Advance/sleep to Day 8 -> weekly rent is charged once; bank reflects new balance.
9. Save -> exit -> reload -> verify funds, stats, clock, position, quest, relationship memory and ledger.

## Manual regression table

| ID | Test | Pass result |
|---|---|---|
| PT-01 | Walk neighborhood / camera collision | No stuck camera, wall clipping, fall-through |
| PT-02 | Spend $35 for groceries | One ledger debit, 5 portions added |
| PT-03 | Work cafe shift | +$120 and +12 career XP; 240 game minutes advanced |
| PT-04 | Work while starving/low energy | Warning and rule-consistent effects; no impossible soft lock |
| PT-05 | Buy when funds < price | Clear rejection; no changes |
| PT-06 | Chat to Devon twice | Affinity and social update; follow-up dialogue reflects memory/state |
| PT-07 | NPC schedule changes on sleep | Reappearance consistent with location/time; no visible pop |
| PT-08 | Day 8 rent charge | Exactly one $300 bill (or partial payment + arrears) |
| PT-09 | Save/quit/reload | No bank, needs, skills, NPC, or clock drift |
| PT-10 | 30-minute roaming and interaction | No crash, unrecoverable dead end, or permanently stuck state |

## Backlog exclusions / approval boundaries

P2 only after slice approval: cars/driving, giant city, romance system, generations, business ownership, custom housing builder, cloud save, multiplayer, AI voice NPCs, console or phone versions.

Change approval required before: expanding beyond initial district; monetization; publishing/release; replacing approved character visuals; writing to any existing project/source repository; committing third-party licensed assets.

## Handoff status

- **Complete:** concept-to-V0.1 game design, data schema, architecture, implementation backlog, QA criteria.
- **Not complete:** no Godot project created, no gameplay implemented, no build generated, no tests executed.
- **Next implementation action:** Create a new empty Godot project for Milestone 0, then deliver a locally runnable graybox scene plus the PT-01 QC evidence.
