# LIFE//MODE — Realistic Visual + Animation Pass V2

## Goal

Push the graybox toward **stylized-realistic** neighborhood materials and a **procedurally animated** player, without changing Milestone 1 gameplay systems or downloading third-party art.

## Implemented

- `MaterialLibrary`: synchronous procedural albedo textures (asphalt, concrete, plaster, grass, wood, brick, metal, soil, glass)
- Neighborhood ground overlays, storefront glazing, brick filler blocks, denser trees/planters/lamps
- Interior wood floors and warmer multi-light interiors
- `AvatarAnimator`: capsule/sphere hierarchical body with idle breath + walk/run limb cycles
- `DayAtmosphere`: sun/sky/ambient respond to the in-game clock
- OpenGL-safe defaults (SSIL off) so VM Compatibility fallback still shows ground/buildings

## Verification

```bash
GODOT=godot python3 life-mode/tests/run_checks.py
# includes visual_polish_smoke.gd — VISUAL QC / 0 failures
```

Demo captures: `docs/screenshots/v2_*.png` and `/opt/cursor/artifacts/screenshots/v2_*.png`.

## Limitations

Still procedural geometry (no scanned photogrammetry or mocap). Windows Forward+ GPU quality and 1080p FPS targets remain human-acceptance items. Photoreal faces and licensed modular kits are out of scope for this pass.
