# LIFE//MODE — Codex / Developer Build Brief

## Goal

Implement **Milestone 0 only** of the attached LIFE//MODE V0.1 prototype design as a new Godot 4.7.2 stable 3D project. Do not build a full game or broaden scope until Milestone 0 is tested.

## Read in order

1. `README.md`
2. `01_GAME_DESIGN_DOCUMENT.md`
3. `02_TECHNICAL_SPEC.md`
4. `03_PROTOTYPE_BACKLOG.md`
5. JSON data presets in `data/`

## Scope of this handoff

Create an **original**, coherent 250m x 250m graybox urban neighborhood with six named locations. Implement third-person camera, keyboard walking/sprinting, collision, focus/highlight on reachable interactables, E-to-interact, a basic M map overlay, an Esc pause screen, an in-game debug overlay, and two interior transitions (apartment and cafe). Use temporary geometry/materials only; do not download or scrape copyrighted assets.

Technical defaults: CharacterBody3D player with `move_and_slide`, camera spring arm/collision, typed GDScript where possible, input actions in project settings, reusable Interactable component. Deliver `project.godot` with project scene and README for local execution.

## Protected-asset and repository rules

- Work in a new folder/repository unless explicitly instructed to use an existing one.
- Do not touch PRIM8, AZTEC AUTO, Nikó, or any existing project.
- Do not overwrite any LOCKED, MASTER, FINAL, APPROVED or SOURCE OF TRUTH asset.
- Report exactly which files you created or modified.
- No online account creation, publishing, paid assets or external APIs.

## Done / QC

Milestone 0 is complete **only when** the project opens in Godot 4.7.2, runs without parser errors, spawns a visible controllable character, allows traversal of the city block, enters/exits apartment and cafe, detects all six location markers, and returns input focus correctly from pause/map screens. Test actual behavior; report pass/fail and blockers. If a test fails, fix the specific failure and rerun before reporting success.

## Deliverables

- Runnable source project folder (or ZIP)
- Project README and input controls
- Screenshots of 3D world + HUD/map (if tools permit)
- QC test checklist with results; factual limitations
- Recommended next unblocked task for Milestone 1

## Do not claim

Do not claim the game is implemented if only plan/docs exist. Do not claim performance validated without measurements on stated hardware. Do not imply later milestones are finished.
