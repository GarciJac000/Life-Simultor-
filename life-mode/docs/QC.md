# Milestone 1 QC — 2026-11-04

**Status:** Runnable Milestone 1 source implemented; automated simulation + integration + export checks passed. Final human/in-editor acceptance remains pending. Milestone 2+ is not implemented.

## Tested environment

- Official Godot **4.7.2.stable.official.ed1daf0bf**, Linux x86_64.
- Headless engine for physics/input and simulation tests.

## Automated results

`GODOT=/path/to/Godot_v4.7.2-stable_linux.x86_64 python3 life-mode/tests/run_checks.py`

| Check | Observed result |
|---|---|
| Exact target engine | 4.7.2 stable verified |
| Headless editor import | Passed, no parser/script errors |
| Simulation suite | **53 checks, 0 failures** |
| Integration suite | **100 checks, 0 failures** |
| Clock / day rollover | 23:50 + 20m → Day 2 00:10 |
| Needs hourly decay | Energy −3 / Fullness −4 (±1) per game hour via 10-minute ticks |
| Cafe shift | +$120, +12 Career XP, +240 minutes; rejected off-location with no side effects |
| Groceries / home meal | $35 → 5 portions; eat consumes 1 and raises fullness |
| Underfunded purchase | Clear rejection; money/time/inventory unchanged |
| Sleep | +420 minutes; energy restored |
| Job gates | Market locked at XP 0; unlocks at Career XP 50 |
| Rent exactly-once | Day 8 00:00 charges once; duplicate `advance_to` does not rebill |
| Partial rent | $200 → $0 bank + $100 arrears; never negative |
| Serialize round-trip | Money, clock, XP, groceries, ledger restored |
| HUD action confirm | Cafe shift via confirm panel credits bank and closes modal |
| Four interiors | Apartment, cafe, market, studio enter/exit round trips |
| Outdoor activities | Park/gym open confirm panels |
| Phone | Tab opens/closes phone overlay |
| Traversal / collision / camera / menus | Prior Milestone 0 gates still pass |
| Linux resource-pack export + packed boot | Passed |

Raw pipeline note: runner prints `CHECKS PASSED / editor import, simulation suite, integration suite, resource-pack export, packed boot`.

## Remaining in-editor / human acceptance

- [ ] Work a cafe shift from the counter; confirm receipt shows net money/needs/time.
- [ ] Buy groceries, eat at home, shower, sleep; verify phone Wallet ledger and Goals ticks.
- [ ] Advance/sleep to Day 8; confirm a single rent charge and readable notice/log.
- [ ] Attempt groceries with insufficient funds; confirm no silent changes.
- [ ] PT-01 / PT-10 style roaming still feel correct with the live clock HUD.
- [ ] Windows desktop acceptance on Godot 4.7.2; performance measurement still deferred.

## Scope boundary

Milestone 1 delivers canonical GameState, integer-minute WorldClock, needs decay, economy/rent, action resolver, phone tabs (People placeholder), and functional stations across six locations. NPCs, dialogue, events, tutorial and player-facing save/load UI remain Milestone 2–3.
