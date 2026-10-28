# LIFE//MODE — V1 Game Design Pack

**Version:** 0.1 — working design (not approved production code)  
**Date:** 2026-10-28  
**Genre:** 3D third-person, single-player, open-neighborhood life simulation  
**Tone:** Balanced: realistic consequences, accessible progression, player freedom

## Pack contents

1. `01_GAME_DESIGN_DOCUMENT.md` — game vision, systems, gameplay loop, interface, world, example playthrough, boundaries, acceptance criteria.
2. `02_TECHNICAL_SPEC.md` — engine decision, architecture, scene tree, simulation tick, persistence, content format, testing strategy.
3. `03_PROTOTYPE_BACKLOG.md` — milestone-by-milestone, dependency-ordered task list, QC gates, developer test scenarios, prototype definition of done.
4. `04_CODEX_BUILD_BRIEF.md` — concrete implementation handoff prompt for a coding agent or developer.
5. `data/player_preset.json` — example starting player data.
6. `data/game_balance.json` — first-pass tunable action and needs values.
7. `data/npc_roster.json` — NPC design seed and schedule roles.

**What this is:** A complete prototype specification and implementation plan.  
**What this is not:** A compiled or playable game. It contains specifications/data only.

## Chosen direction

- Engine: **Godot 4.7.2 stable**, **GDScript**, desktop-first (Windows, macOS, Linux).
- Rendering: 3D third-person with stylized-realistic art direction, moderately dense urban block.
- Main map: **250 m x 250 m** continuous, walkable neighborhood; no hard loading seams outdoors.
- Scope: 6 functional locations, 4 furnished interiors, 12 named NPCs (4 featured + 8 ambient).
- Core systems: locomotion and interaction, in-game clock, needs, economy, jobs, relationships, schedules, contextual events, local saves.
- No network services, external LLM, accounts, generative NPC conversations, vehicle driving, or online multiplayer in V1.

## How to use

1. Read `01_GAME_DESIGN_DOCUMENT.md` to align on the experience.
2. Treat `02_TECHNICAL_SPEC.md` as the architecture and implementation contract.
3. Execute `03_PROTOTYPE_BACKLOG.md` in order and apply each milestone's tests.
4. Paste `04_CODEX_BUILD_BRIEF.md` into your developer/coding workspace when implementation is authorized.
5. Edit balance values in `data/` only after recording a design revision; keep these defaults as a baseline.

## Source verification

- Official Godot download archive (4.7.2 stable, 2026-08-18): https://godotengine.org/download/archive/
- Godot 3D movement: https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html
- Godot 3D optimization: https://docs.godotengine.org/en/stable/tutorials/performance/optimizing_3d_performance.html
- Godot save systems: https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html

**Asset/legal note:** Use original or correctly licensed artwork, animations, sounds, and names. The LIFE//MODE name is a working title; trademark clearance is out of scope.
