# LIFE//MODE — Milestone 0

Original desktop 3D neighborhood graybox. **Godot 4.7.2 stable, GDScript, Forward+.**
Open `project.godot` in that editor and press **F6 on `scenes/boot.tscn`** or **F5** to run the project. No packages, accounts, credentials, external assets, or backend are required. Launch from a terminal with `godot --path life-mode` from the parent repository.

The player starts outside the apartment, facing its entrance. Six numbered landmarks occupy a bounded **250 × 250 metre** neighborhood. Streets, sidewalks, building masses, boundary walls, signs, and a visible capsule character are original primitive geometry. One Godot unit represents one metre. Ground is continuous; sidewalks are visual surfaces flush with it to avoid requiring a step-climbing controller.

| Control | Action |
|---|---|
| WASD | Move relative to camera yaw |
| Left Shift | Sprint (5 m/s walk; 9 m/s sprint) |
| Mouse | Orbit camera; pitch is clamped |
| E | Activate highlighted forward marker within 2.5 m |
| M | Open/close district map |
| Esc | Close current overlay, or pause/resume |
| F3 | Toggle position, grounded state, focus, speed, engine and FPS debug overlay |

Pause and map stop physics and release the cursor. The menu button also resumes play. The spring arm retracts against walls and eases outward after clearing them. An unobstructed forward target must show an E prompt before activation. Apartment and cafe entrances teleport to small separate interior scenes; their exit markers return to the corresponding street entrance. Other markers provide discovery toasts, not later-milestone activities.

## Structure

- `scenes/boot.tscn`: runnable scene and lighting.
- `scenes/actors/player.tscn`: CharacterBody3D, visible body, collision, orbit pivot, spring arm and camera.
- `scenes/world/`: neighborhood and the apartment/cafe interior sub-scenes. Geometry is built by their scripts at runtime; run the scene to view it.
- `scripts/interactions/interaction_component.gd`: reusable signal-based marker, focus ring, label and activation.
- `scripts/world/`: original blockout helpers, six-location layout and portal coordinator.
- `scenes/ui/`, `scripts/ui/`: HUD, map, pause, transient toast and debug display.
- `tests/`: runnable physics/input integration suite, CI-style runner and rendered visual checks.
- `docs/`: QC report, complete file inventory and captured screenshots.
- `assets/licenses/`: asset provenance.

## Automated verification

Python 3 is needed only for the convenience runner. With Godot 4.7.2 on PATH:

```sh
GODOT=godot python3 life-mode/tests/run_checks.py
```

Or set `GODOT` to the full editor binary path. The runner rejects other engine versions, imports the project, executes actual physics/input integration checks, exports a Linux resource PCK, and boots that pack. It rejects engine/script errors even if Godot returns exit code zero. Linux sandbox environments must allow the editor's local sockets and provide writable XDG directories (the runner supplies temporary defaults).

For optional screenshot and camera checks on a desktop display:

```sh
godot --path life-mode --audio-driver Dummy --script res://tests/visual_check.gd
```

This creates `docs/screenshots/*.png` and checks actual captured mouse input and spring-arm collision. Do not run it headlessly. Screenshots can be regenerated; desktop OS mouse focus must belong to the game window.

## Export

`export_presets.cfg` defines a Linux x86_64 preset. The runner verifies a **resource pack**, not a standalone executable. For an executable, install matching Godot 4.7.2 export templates, create `exports/`, then use the editor Export dialog or:

```sh
godot --headless --path life-mode --export-debug Linux exports/life-mode.x86_64
```

Choose an absolute output path if launching from another working directory. Windows remains the primary manual acceptance platform; add a Windows export preset when preparing that platform's executable.

## Scope and limitations

Only Milestone 0 is implemented. No clock, needs, economy, work shifts, NPCs, jobs, phone, objectives, save/load or Milestone 1 progression is present. Market and studio interiors are deliberately deferred. Missing `data/` presets referenced by the design pack are unnecessary for this milestone. All original design documents remain unchanged.

See [QC results and in-editor checklist](docs/QC.md). Passing automated checks does not replace the remaining human playtest, Windows acceptance, 1080p performance measurements, or 30-minute roaming test. After those pass, the next Milestone 1 task is a canonical GameState and integer-minute WorldClock; it is not implemented here.
