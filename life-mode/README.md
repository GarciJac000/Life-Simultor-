# LIFE//MODE — Milestone 1

Original desktop 3D neighborhood life-sim prototype. **Godot 4.7.2 stable, GDScript, Forward+.**
Open `project.godot` in that editor and press **F5** (main scene `scenes/boot.tscn`) to run. No packages, accounts, credentials, external assets, or backend are required. Launch from a terminal with `godot --path life-mode` from the parent repository.

The player starts outside the apartment on **Day 1, 09:00** with **$1,250**, six needs, and optional first-week goals. A living clock advances in free roam (1 real second ≈ 2 game minutes) and during confirmed actions. Four interiors (apartment, cafe, market, studio) plus park hangout and gym exercise stations are playable.

| Control | Action |
|---|---|
| WASD | Move relative to camera yaw |
| Left Shift | Sprint (5 m/s walk; 9 m/s sprint) |
| Mouse | Orbit camera; pitch is clamped |
| E | Activate highlighted forward marker within 2.5 m |
| Tab | Open/close phone (Today / Map / Wallet / Goals / People) |
| M | Open/close district map |
| Esc | Close current overlay, or pause/resume |
| F3 | Toggle position, grounded state, focus, clock minute, FPS debug overlay |

Pause, map, phone and action confirm stop physics and release the cursor. Activities always show cost/time/effects and require confirm. Bank balance cannot go negative; weekly rent is due Day 8 00:00 with arrears if underfunded.

## Playable Milestone 1 loop

1. Enter the **cafe** → barista counter → confirm **Work cafe shift** (+$120, +12 Career XP, 4 game hours).
2. Open **Tab → Wallet** to read the ledger and rent due.
3. Enter the **market** → buy groceries ($35 → 5 portions).
4. Return to the **apartment** → eat, shower, sleep.
5. Visit **park** / **gym** / **studio** for social, exercise and creative practice.
6. Advance (or sleep repeatedly) to Day 8 to observe a single $300 rent charge.

Market and studio **jobs** unlock at Career XP 50 and Creative XP 50; practice/shopping remain available immediately.

## Structure

- `data/`: player preset and tunable action/balance JSON.
- `scripts/autoload/`: `WorldClock`, `GameState`, `EconomySystem`, `SimulationSystem`.
- `scenes/world/`: neighborhood plus apartment/cafe/market/studio interiors.
- `scripts/interactions/`: reusable Interactable with optional `action_id` / portal `destination`.
- `scenes/ui/`, `scripts/ui/`: HUD, phone, map, pause, action confirm, toast, debug.
- `tests/`: simulation QC, physics/input integration, CI runner.
- `docs/`: QC report, file inventory, screenshots.

## Automated verification

```sh
GODOT=godot python3 life-mode/tests/run_checks.py
```

Runs Godot 4.7.2 import, **53 simulation checks**, **100 integration checks**, Linux resource-pack export, and packed boot. Rejects engine/script errors even if Godot returns exit code zero.

Optional rendered checks on a desktop display:

```sh
godot --path life-mode --audio-driver Dummy --script res://tests/visual_check.gd
```


## Web (browser) play

Export uses the Godot **Web** preset (Compatibility / single-thread). From `life-mode/`:

```sh
# requires Godot 4.7.2 export templates installed
godot --headless --path . --export-debug "Web" exports/web/index.html
python3 tools/serve_web.py
```

Then open [http://127.0.0.1:8080/](http://127.0.0.1:8080/). The helper server sets `application/wasm` and isolation headers.

## Scope and limitations

Milestone 1 adds clock, needs, economy, jobs/activities, phone HUD and market/studio interiors. **Not included yet:** named NPCs/schedules, dialogue memory, authored events, tutorial arc, disk save/load UI, polished art/audio. Serialize/deserialize exists on `GameState` for tests and as foundation for Milestone 3 persistence.

See [QC results](docs/QC.md). Next unblocked task after M1 human QC: Milestone 2 living neighborhood (NPC roster, schedules, NavMesh, relationships).
