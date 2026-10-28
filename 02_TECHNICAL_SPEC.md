# LIFE//MODE — Technical Design (Prototype)

**Status:** Proposed implementation contract, not implemented or tested.

## Engine & platform

- **Godot 4.7.2 stable** (official archive lists stable release dated Aug 18, 2026).
- **GDScript** for the entire slice: fast iteration, straightforward Godot tooling, no external backend.
- **Desktop-first**, mouse and keyboard. Windows is primary acceptance target; smoke test macOS/Linux if available.
- **3D renderer:** Forward+ for desktop. Optimize through occlusion culling, mesh LOD, baked/environment lighting where suitable. Godot web export requires separate Compatibility/WebGL planning, so browser build is **not** a V1 acceptance target.
- One scene-sized 250m x 250m neighborhood. Scene streaming can be deferred; use small interior sub-scenes through portals as necessary.

## Proposed repository layout

```
life-mode/
  project.godot
  README.md
  docs/
    GDD.md
    technical_design.md
    playtest_protocol.md
  assets/
    environments/ characters/ props/ ui/ audio/ licenses/
  data/
    balance.json
    npc_roster.json
    events.json
    interactions.json
  scenes/
    boot.tscn
    world/neighborhood.tscn
    world/interiors/apartment.tscn
    world/interiors/cafe.tscn
    world/interiors/market.tscn
    world/interiors/studio.tscn
    actors/player.tscn
    actors/npc.tscn
    ui/hud.tscn
    ui/phone.tscn
    ui/interaction_panel.tscn
    ui/recap.tscn
  scripts/
    autoload/game_state.gd
    autoload/world_clock.gd
    autoload/simulation_system.gd
    autoload/economy_system.gd
    autoload/relationship_system.gd
    autoload/event_director.gd
    autoload/save_system.gd
    actors/player_controller.gd
    actors/npc_controller.gd
    actors/npc_schedule.gd
    interactions/interaction_component.gd
    ui/hud_controller.gd
    ui/phone_controller.gd
  tests/
    unit/
    integration/
    manual/
```

## Scene roles

- `Player`: `CharacterBody3D` with collision, third-person pivot/camera, animations, interaction ray. Use `move_and_slide()` in physics updates.
- `NPC`: `CharacterBody3D` (or suitable non-physics node for distant stand-ins), NavigationAgent3D for local path following; schedules for offscreen state.
- `World`: NavMesh regions, six location anchors, interactable entrances and props, time-of-day/environment settings.
- `UI`: Separate Control-based HUD and phone, fed by state-change signals (not constant polling).

## State and deterministic simulation

**Single canonical model:** `GameState` owns serializable progression values; scenes only render and request transitions. No UI element is the authority for money, time or relationships.

**Required event/signal contract:**

- `action_requested(actor_id, action_id, target_id)`
- `action_resolved(action_id, result)`
- `clock_advanced(from_minute, to_minute)`
- `need_changed(stat, old_value, new_value, reason)`
- `money_changed(old_amount, new_amount, reason)`
- `relationship_changed(npc_id, old_value, new_value, reason)`
- `schedule_changed(npc_id, destination_id)`
- `quest_updated(quest_id, progress)`
- `save_completed(slot_id, success)`

**Pseudo algorithm:**

```
resolve_action(request):
  check target, player proximity, location/open hours, funds, prerequisites
  reject invalid requests without charging time or money
  apply direct effects and inventory changes
  advance clock by action duration and run every missed 10-minute tick
  update NPC schedules using target game time (no expensive offscreen physics)
  bill recurring obligations at exact scheduled boundary
  resolve eligible delayed consequences/events using seeded RNG
  append human-readable log and emit changed-state signals
  schedule save when at a safe interaction boundary
```

**Time representation:** `absolute_game_minutes` as integer since Day 1 00:00; start value 540 (Day 1 09:00). Derive hour/day from this. Store `last_tick_processed` and process ticks until caught up. Track need decay with fixed-point integer subunits (e.g. 60 subunits per displayed stat point) so 10-minute ticks implement hourly rates without rounding drift; serialize those accumulators. `advance_to()` must not duplicate bills/events when passed the current timestamp or called after load.

**Sleep rule:** Sleeping always advances 420 game minutes (seven hours) and restores +55 Energy; ordinary needs decay, NPC schedules and scheduled payments still execute during the skip. It does not force wake time to 07:00.

**Balance effects:** Each action effect is named and tunable. Clamp needs to 0–100, amounts to valid integer currencies (USD whole dollars V1). Use ordered accounting ledger with unique transaction IDs; do not compute bank value from UI labels. For rent, schedule Day 8 00:00 and every 7 days after. Store obligations already processed to guarantee exactly-once billing.

## Save format

Versioned JSON in `user://` with safe-write temp file, then atomic rename where supported, keep a backup slot. Persist:

```
{
  "schema_version": 1,
  "save_id": "...",
  "rng_seed": 18477,
  "clock": {"absolute_game_minutes": 540, "last_tick_processed": 540},
  "player": {
    "name": "Alex Morgan", "age": 21, "money": 1250,
    "position": [12.0, 0.0, -8.0],
    "needs": {"energy": 74, "fullness": 65, "hygiene": 80, "social": 45, "happiness": 68, "health": 91},
    "inventory": {"groceries": 0},
    "skills": {"career_xp": 0, "creative_xp": 0}
  },
  "rent": {"amount": 300, "arrears": 0, "next_due_minute": 10080},
  "npc_state": {}, "quest_state": {}, "processed_event_ids": [], "ledger": []
}
```

**Important time correction:** The first rent due time in `absolute_game_minutes` is **10080**, i.e. start of Day 8 (7*1440), not a relative offset from the player's Day 1 09:00 start. Every subsequent weekly charge is +10080 minutes. `last_tick_processed` must be initialized to the tick floor of the current time or the exact start time and never processed twice.

No user account, telemetry or server persistence for prototype. Add schema migrations before any published save format change.

## NPC scheduling

1. Define daily destination blocks with time intervals for each NPC.
2. Update a featured NPC's on-screen route when destination changes; use baked NavMesh and a `NavigationAgent3D`.
3. At a distance, represent an NPC as schedule state only; resolve its place instantly when it next becomes visible from an occluded entry point.
4. Preserve relationship memory independently of scene unload and respawn.
5. Failed path -> stop safely -> recalculate/reposition while occluded; never trap NPC permanently.

## Dialogue & events

Content tables keyed by conditions (`min_affinity`, `remembered_event`, `location`, `day_range`). No LLM needed. EventDirector selects authored eligible events using persistent seeded random generator; protect against repeats with cooldown + processed event IDs. An event can reserve a future follow-up (e.g. appointment tomorrow), creating a visible calendar item.

## Input and camera

- Default third-person orbit camera; pitch clamp, configurable sensitivity, simple wall collision smoothing.
- 3D walk with WASD, sprint Shift; E interacts with nearest forward focus within 2.5m; always show context label before activation.
- UI controls should not leak movement input when phone/dialogue is open.
- Sprint affects movement speed (not core stats) in first build; stamina simulation deferred to avoid noisy tuning.

## Performance & reliability budgets

Initial acceptance machine: developer-specified midrange desktop at 1920x1080 (record exact specs in test report). Targets: 60 FPS average, >=30 FPS 1% low after steady-state warm-up, no consistently blocked main thread during schedules and UI; 30-minute no-crash test. These are design targets, not observed figures.

Optimize using culling, imported mesh LOD, simple materials, reduced distant animation, and no offscreen navigation ticks. Keep active fully simulated NPCs bounded to on-screen/nearby set (target <= 8). All 12 NPCs still have active abstract schedule and memory state.

## Automated test cases

- Clock: advancing from 23:50 to next day triggers one day transition.
- Duplicate billing: two `advance_to()` calls covering Day 8 cannot charge rent twice.
- Funds: exact $300 is valid; $200 triggers $200 paid + $100 arrears, no negative balance.
- Needs: stat values always remain within [0,100], including sleep and stacked effects.
- Invalid interaction: outside radius or insufficient funds -> no time/money/XP change.
- Saving: deserialize/serialize round-trip exactly preserves money, bills, quest IDs, XP, NPC affinity/memory, position, time, and RNG seed.
- NPCs: offscreen scheduler returns the correct destination at 09:00, 14:00, 22:00; no NPC visible teleport.
- Event: same seed and same action/event history yields same eligible event result.
- UI: action panel shows cost, duration and net changes; keyboard input ignored while modal panel is open.

## Security, licensing, and scope

No credentials or external API keys. Avoid proprietary ripped assets and copyrighted game characters. Track licenses in `assets/licenses/`. Keep production-ready infrastructure out of prototype unless a test demonstrates a need.

## References

- https://godotengine.org/download/archive/
- https://docs.godotengine.org/en/stable/getting_started/first_3d_game/02.player_input.html
- https://docs.godotengine.org/en/stable/tutorials/performance/optimizing_3d_performance.html
- https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
