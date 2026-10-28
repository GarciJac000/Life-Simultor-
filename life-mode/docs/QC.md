# Milestone 0 QC — 2026-10-28

**Status:** Runnable source implemented; automated engine and rendered checks passed. Final human/in-editor acceptance remains pending. Milestone 1 is not implemented.

## Tested environment

- Official Godot **4.7.2.stable.official.ed1daf0bf**, Linux x86_64. Downloaded from the official Godot GitHub release and verified against its SHA-512 manifest before execution.
- Managed Linux machine: Intel Xeon Platinum 8573C, 5 exposed logical CPUs, approximately 33 GiB RAM. No physical desktop GPU used.
- Headless engine for physics/input tests. Virtual Xorg display at 1280×720 for actual rendered checks, **Forward+ / Vulkan 1.4.305 / llvmpipe LLVM 19.1.7 (256 bit)**. Software renderer supplied by the signed Debian `mesa-vulkan-drivers` package, extracted outside the checkout.
- Initial sandbox restrictions blocked the editor's local sockets and home-directory writes. Writable temporary XDG paths and permitted local socket access resolved these environment issues; the final pipeline has no engine/script errors.

## Automated results

`GODOT=/path/to/Godot_v4.7.2-stable_linux.x86_64 python3 life-mode/tests/run_checks.py`

| Check | Observed result |
|---|---|
| Exact target engine | 4.7.2 stable verified |
| Headless editor import | Passed, no parser/script errors |
| Integration suite | **83 checks, 0 failures** |
| Runtime spawn | Visible player mesh, active third-person camera, grounded physics body |
| Input setup | All nine actions have project input mappings |
| Walking and sprint | Actual CharacterBody motion near 5 and 9 m/s; no stats system |
| Collision | Ground probes at four corners and crossing, north boundary barrier, building facade |
| Continuous traversal | Both main streets and all four perimeter routes, each >230m of actual sprint motion; remained grounded |
| Six landmarks | Each gives forward focus and exactly one E activation; discovery recorded |
| Apartment and cafe | Both enter, settle on interior floors, show exit focus and return outside |
| Interaction rejection | Outside 2.5m, behind forward view and occluded by a wall cannot focus; out-of-range E cannot activate |
| Camera math | Mouse orbit direction and pitch clamp pass (headless calls the same orbit function directly) |
| Menus | Three map/pause cycles; map freezes movement/E, Esc closes the current modal, movement resumes |
| Debug UI | F3 toggle passes |
| Linux resource-pack export | Passed; PCK then booted in engine without script/runtime errors |
| Diff whitespace | `git diff --check` passed |

`godot --path life-mode --audio-driver Dummy --script res://tests/visual_check.gd`

Rendered input checks passed: captured mouse motion changes camera yaw and clamps pitch; the spring arm retracts before a facade. World, map, pause, cafe and district images were captured from the engine viewport and inspected. Exit signage was reduced after reviewing its initial oversized rendering. HUD text has an outline for legibility over the blockout.

Screenshots: [world](screenshots/world.png), [map](screenshots/map.png), [pause](screenshots/pause.png), [cafe](screenshots/cafe.png), [district](screenshots/district.png).

Raw final pipeline and rendered output: [automated checks](automated-checks.txt), [rendered checks](rendered-checks.txt).

The PCK is a resource-pack validation artifact, **not** a standalone executable. Matching export templates and platform binary export were not tested. No Windows or macOS runtime was available. No performance target is claimed from software-rendered screenshots or a momentary FPS display.

## Remaining in-editor / human acceptance

Open `project.godot` in Godot 4.7.2 and run F5. These remain **unrun human checks**, even where automated coverage exists:

- [ ] PT-01: manually walk/sprint the entire block; judge turning feel, camera pitch limits and wall retraction/extension, facade corners and recovery from close walls.
- [ ] Approach all six landmarks from different directions; check prompt readability and that E only fires the visible reachable target.
- [ ] Enter/exit both rooms repeatedly while moving and orbiting; inspect floor/wall collisions, furniture clearance and return placement.
- [ ] Reopen M and Esc with keys held/released in different orders; use the mouse Resume/Close button and keyboard button focus; confirm OS mouse capture returns and no stuck movement.
- [ ] Inspect HUD/map/pause at target desktop sizes, including 1920×1080 and smaller window sizes.
- [ ] PT-10: uninterrupted 30-minute roaming session; record any crash, stuck state or fall-through.
- [ ] Primary Windows desktop acceptance using Godot 4.7.2; optionally macOS. Test any standalone executable after installing matching export templates.
- [ ] Measure target performance on recorded midrange desktop hardware at 1080p after warm-up; record average FPS and 1% low. Current virtual/software-rendered checks do not validate the 60/30 FPS targets.

## Scope boundary

No canonical progression state, clock, needs, economy, jobs, NPC schedules, navigation mesh, phone, objectives, persistence or later activities were added. Marker visit counts are transient M0 exploration feedback. Apartment and cafe are stub interiors; market/studio remain exterior inspection points. Procedural original primitives and engine fallback fonts require no third-party asset download.

Recommended next task after the Milestone 0 human QC gate: implement Milestone 1's GameState and integer-minute WorldClock with meaningful tick-boundary tests. That work remains outside this delivery.
