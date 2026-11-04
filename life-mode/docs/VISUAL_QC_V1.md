# LIFE//MODE — Semi-realistic Visual Pass V1

## Goal and reference

This branch is a **graphics-only visual prototype upgrade** built on the protected `milestone-0-godot` baseline. Visual target: believable modern neighborhood with gently stylized materials and proportions (not photorealism).

## Implemented code changes

- New reusable `scripts/world/visual_polish.gd`: non-colliding decorative 3D meshes with varied roughness/metalness
- Neighborhood: storefront glazing, architectural trim and canopies, crosswalks, concrete seams, lamps, planters, trees, park benches, gym striping
- Interior: wood-toned floors, furniture detail, warm local light, accent details
- Player: clothed human-proportioned procedural body replacing visible placeholder capsule; original collision and nodes retained
- Environment: updated sky, sunlight and tone mapping, ambient occlusion, subtle glow, distance fog
- Added independently runnable structural graphics smoke check

## Protected systems unchanged

- The existing 250×250 m world, roads, facades and collision shapes
- Walk/sprint physics, orbit camera, 2.5 m E-interaction raycast, 6 locations
- Apartment and cafe portal positions and teleport logic
- Map, pause, debug UI, saved design documents
- No Milestone 1 simulation systems

## Limitations

**Not yet rendered or engine-validated in this environment.** Godot 4.7.2 is not installed in the current execution container; do not treat code inspection as a passed engine run. No claim is made regarding Windows Forward+ graphics, FPS, visual quality or shader compatibility.

Geometry is still procedural and simplified. This is a semi-realistic **first visual pass**, not final character art, animation, physically accurate building kits, or photorealistic texture assets.

## QC acceptance commands

From the repository root with Godot 4.7.2 accessible:

```bash
GODOT=godot python3 life-mode/tests/run_checks.py
godot --headless --path life-mode --script res://tests/visual_polish_smoke.gd
```

Then open `life-mode/project.godot` and press F5 on Windows with the Forward+ renderer.

1. Compare a street view, park, apartment, cafe and avatar to the original Milestone 0 screenshots.
2. Verify buildings have no z-fighting, shimmer, opaque missing materials or black surfaces.
3. Verify all six markers can still be activated from their original interaction locations.
4. Test camera and close-to-facade behavior; note any clipping of decorative storefront surfaces.
5. Enter and exit the apartment/cafe 10 times each.
6. Test UI/map/pause and window resize at 1280×720 and 1920×1080.
7. Roam continuously for 30 minutes; record crash or navigation issues.
8. Capture avg and 1% low FPS at 1080p on a real Windows GPU; compare against baseline.

Do not merge or replace the baseline until structural tests, gameplay tests, Windows render check and visual acceptance all pass.
