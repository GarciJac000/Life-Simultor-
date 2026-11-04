# Created / updated files (Milestone 1)

Application files live under `life-mode/`. Design documents at the repository root were not modified. Godot-generated `.uid` metadata is included; `.godot/`, Python bytecode and export artifacts are excluded.

## Milestone 1 additions

- `data/game_balance.json`
- `data/player_preset.json`
- `scripts/autoload/world_clock.gd` (+ `.uid`)
- `scripts/autoload/game_state.gd` (+ `.uid`)
- `scripts/autoload/economy_system.gd` (+ `.uid`)
- `scripts/autoload/simulation_system.gd` (+ `.uid`)
- `scenes/world/interiors/market.tscn`
- `scenes/world/interiors/studio.tscn`
- `tests/simulation_test.gd` (+ `.uid`)

## Milestone 1 updates

- `project.godot` — autoloads, Tab/`phone` input, milestone comment
- `README.md`, `docs/QC.md`, `docs/FILES.md`, `docs/automated-checks.txt`
- `scripts/world/main.gd` — four interiors, action routing
- `scripts/world/neighborhood.gd` — enterable market/studio; park/gym actions
- `scripts/world/interior.gd` — activity stations per location
- `scripts/interactions/interaction_component.gd` — `action_id`
- `scripts/ui/hud_controller.gd` — clock, needs, money, phone, action confirm
- `tests/smoke.gd`, `tests/run_checks.py`

## Retained from Milestone 0 / visual pass

- Neighborhood graybox + semi-realistic visual polish
- Player controller, map view, blockout helpers, apartment/cafe scenes
- Screenshots under `docs/screenshots/`
- `tests/visual_check.gd`, `tests/visual_polish_smoke.gd`
