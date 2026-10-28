# LIFE//MODE — Game Design Document

**Design version 0.1 | 2026-10-28 | Status: WORKING, not approved/locked**

## 1. Product definition

**One-line pitch:** A third-person 3D life simulator where everyday decisions build a personal story inside a living neighborhood.

**Player promise:** Go anywhere in the neighborhood, meet people who remember you, earn and spend money, maintain your wellbeing, and find your own path—without scripted win conditions.

**Design pillars**
1. **Agency:** The player chooses daily priorities, personal goals, and relationships; avoid forced career routes.
2. **Visible consequences:** Decisions update immediate stats and create delayed effects; explain changes to the player.
3. **Believable community:** Named NPCs follow routines, respond contextually, and remember a small number of events.
4. **Balanced pressure:** Costs and commitments matter, but setbacks create recovery paths, not instant failure.
5. **Expandable architecture:** A single fully-functional neighborhood is the foundation for a larger city.

**Experience references, not replication targets:** Life-simulation progression + third-person sandbox navigation + narrative choices. Assets, UI, mechanics, and story must be original.

## 2. Player fantasy and progression

Player starts as a 21-year-old resident with a modest rental, an entry-level job and $1,250 bank balance (preset Alex Morgan; rename and appearance preset selection supported). Goals are player-authored: maintain independence, grow friendships, start a creative career, save money, or simply explore.

**Playable scenario:** "Your First Week." The first seven in-game days provide a lightweight objective board with optional personal milestones; players may ignore goals. Sample objectives: work one shift, cook at home, make a friend, explore the studio, pay rent. The arc is complete when day 8 begins and the weekly recap appears, but sandbox play continues.

**Progression dimensions:** Wealth, career XP, creative XP, social connections, personal satisfaction, and housing upgrades. Nothing in V1 permanently gates relationships behind income.

## 3. Vertical-slice boundaries

| Included | Deferred | Explicitly excluded from V1 |
|---|---|---|
| One 250m x 250m walkable neighborhood | Multiple districts; open-world driving | Multiplayer / live-service |
| Third-person running/walking and orbit camera | Vehicle ownership/driving | AI voice/chat backend |
| Six functional places, four interiors | Fully decorated modular housing | Procedural entire city |
| Twelve named NPCs; four with relationship events | Romance, marriage, children | Generational inheritance |
| Needs, income, rent, bills, shopping | Loans, complex credit & investments | Real-money transactions |
| Three work options, one creative skill path | Full custom entrepreneurship | Sandbox destruction/combat |
| Local save/load and one tutorial arc | Cloud saves, mod support | Mobile release at prototype stage |

**Six locations:** (1) apartment (interior), (2) cafe/job (interior), (3) corner market (interior), (4) music studio (interior), (5) public park (outdoor), (6) community gym courtyard (outdoor workout point). All six have functional interactions; interiors are accessible through doors with seamless-feeling transitions but may load interior sub-scenes.

**Jobs:** Cafe barista (start), market stock clerk (discoverable), studio assistant (unlockable via creative skill or friendship). These use shared shift mechanics; courier/driving missions are deferred.

## 4. Game clock and action economy

- **Time scale:** 1 real second = 2 in-game minutes when unpaused; one in-game day equals 12 real minutes without skips.
- **Player control:** Pause via menu; sleep fast-forwards to chosen wake time, reconciling scheduled time-based effects. No time boost toggle in V1.
- **Tick model:** Apply needs and routine NPC schedule progression in discrete **10 in-game minute ticks**; actions advance time and process all intervening ticks. Use fractional or fixed-point accumulation so hourly decay remains exact across ticks.
- **Start state:** Day 1, 09:00; age 21; bank $1,250; next weekly rent charge $300 at Day 8 00:00. Other financial pressures arise from optional purchases and weekly spending.
- **Balance constraint:** A work shift occupies 4 game hours (~2 real minutes) and pays $120; a weekly rent bill is $300. Deliberate choice pressure comes from the opportunity cost of time, needs, social events, and saving goals—not an immediate poverty trap.

**Stats** (range 0–100): Energy, Fullness, Hygiene, Social, Happiness, Health. Numbers are game abstractions, not medical claims. No deaths or hospital simulation in V1. Energy/Fullness/Hygiene/Social decay on time ticks. Happiness is affected by needs and events; Health is only a slow-moving summary. All values clamp to 0–100.

**Initial stat values:** Energy 74, Fullness 65, Hygiene 80, Social 45, Happiness 68, Health 91.

**Baseline decay (per in-game hour):** Energy -3, Fullness -4, Hygiene -2, Social -2; Happiness -1 if two or more basic needs are below 30, otherwise no passive loss. Health -1/day only if two or more needs remain under 15 for 6 consecutive game hours; otherwise stable in V1. Evaluate time-derived effects on tick, not on render frame. Decay rates are first-pass knobs, subject to playtesting.

**Core actions:**

| Action | Place | Duration (game) | Direct consequence |
|---|---|---:|---|
| Work cafe shift | Cafe | 4h | +$120; Energy -12; Happiness -3; Career XP +12 |
| Work market shift | Market | 4h | +$110; Energy -10; Career XP +10 |
| Work studio shift | Studio | 4h | +$100; Energy -8; Creative XP +10 |
| Buy groceries | Market | 15m | -$35; inventory +5 home meal portions |
| Eat home meal | Apartment | 30m | consumes 1 portion; Fullness +30 |
| Eat cafe meal | Cafe | 30m | -$18; Fullness +35; Happiness +3 |
| Take shower | Apartment | 20m | Hygiene +45 |
| Sleep | Apartment | 7h | Energy +55; time and scheduled charges processed |
| Chat with NPC | Near NPC | 30m | Social +10; featured NPC affinity +8; memory chance |
| Hang out | Park | 1h | Social +15; Happiness +6; affinity +12 if NPC available |
| Make music | Studio | 2h | Creative XP +18; Energy -10; Happiness +8 |
| Exercise | Gym courtyard | 1h | Health +2; Energy -10; Happiness +4 |

Every action also incurs baseline needs decay from elapsed game time. Show **net** changes in the action receipt after baseline decay; do not silently skip time.

**Economy:** Bank account cannot silently go negative. At Day 8 00:00, subtract as much rent ($300) as available and store any shortfall as `rent_arrears`; show a readable notice. There is no eviction/game-over in V1, but unpaid rent applies a small happiness penalty and creates an optional repayment goal. Manual payments first reduce arrears. Add explicit prices in interaction screens before confirmation.

**Inventory:** Only groceries (integer servings) and optional cosmetic items initially. No weight/crafting systems.

**Skills:** Career XP and Creative XP tracked as integers; XP milestones 25/50/100 unlock a small number of opportunities. At Creative XP >= 50, offer studio-assistant role. At Career XP >= 50, offer market role. Skills do not decay.

## 5. NPC and relationship model

- 12 named NPCs: 4 featured (repeat dialogues, affinities, memory tags) and 8 ambient (simple routines, one-line remarks).
- Each NPC has a daily schedule of destination+time blocks. Offscreen position is resolved from schedule, not simulated minute-by-minute pathfinding.
- Featured NPC fields: `affinity` (0–100), `trust` (0–100), `last_interaction_day`, up to 5 recent memory events `{type, day, magnitude}`.
- Example: Attending a planned studio meeting on time adds trust; missing it reduces trust and changes the next greeting. Memory events expire after 7 days unless flagged as major. This is authored rules and templated dialogue; no external AI required.
- No random NPC teleporting in the player's view. Spawn characters from entrances/occluded zones when their schedule changes.
- Content safety: Never disguise generated NPC responses as real people; NPCs must be clearly fictional.

**Initial featured cast:**
- **Maya**, cafe supervisor: values reliability; controls job tutorial and better shift access.
- **Jules**, aspiring producer: studio creative chain; reacts to promises.
- **Devon**, friendly neighbor: park social tutorial; shares affordable-living tips.
- **Rowan**, market employee: offers store work and practical opportunities.

## 6. Consequences and event director

Action result pipeline: **validate** -> **reserve time/cost** -> **apply action** -> **advance clock** -> **process decay/schedules/bills** -> **resolve events** -> **write event log** -> **refresh UI** -> **save at safe points**.

Examples of small authored events: rain changes NPC locations; friend invites player to park; delayed utility reminder; friend comments on missed promise; new shift posted after career milestone. Prototype target: 8 unique events. Event trigger weights are deterministic from seeded RNG per save and constrained by eligibility, cooldown and player's prior choices.

**Fairness:** No unavoidable sudden loss above $50 in an event; always show the cause of a consequence. No monetized randomness.

## 7. Third-person interface and controls

**Controls (keyboard + mouse):** WASD move, mouse orbit, Shift sprint, E interact, Tab phone/dashboard, M map, J objectives, Esc pause. Controller mapping deferred until P1 unless accessibility testing demands earlier.

**HUD layout:**

```
+------------------------------------------------------------------+
| DAY 1 • MON 09:00     DOWNTOWN BLOCK              $1,250    [MAP]|
|                                                                  |
|                                                                  |
|                     THIRD-PERSON WORLD                           |
|                                                                  |
|                   [E] Talk to Maya                               |
|                                                                  |
| [ENERGY 74] [FULLNESS 65] [MOOD 68]            [OBJECTIVE: WORK]|
|                      [TAB] PHONE                                |
+------------------------------------------------------------------+
```

**Phone tabs:** Today (calendar and next event), Map (six locations + active destination), People (four featured contacts), Wallet (bank, weekly rent, past transactions), Goals (self-directed objectives). Needs can be expanded from HUD. No phone network features.

**Interaction panel pattern:** Contextual label -> action name -> cost/time -> expected direct effects -> confirm/cancel -> receipt with net effects; risky/expensive actions never activate directly from proximity.

**Accessibility baseline:** Subtitles on by default, no critical information encoded only by color, adjustable UI text scale (100/125/150%), reduced camera shake toggle, remappable keyboard in later polish; no mandatory rapid-response sequences.

## 8. Onboarding and first-session walkthrough

- **00:00–02:00:** Spawn inside apartment, basic camera movement tutorial, inspect clock/stats, select a goal.
- **02:00–06:00:** Walk to cafe; talk to Maya; work first shift; collect $120 and XP; observe 4 game hours advance.
- **06:00–10:00:** Buy groceries; meet Devon in park or visit Jules at studio; feel tradeoff between time, money and relationships.
- **10:00–15:00:** Return home, eat, shower, sleep; see daily recap and tomorrow's invitation.

Real-time session positions are illustrative, not promised timings; walking and player exploration may vary.

**One-week recap:** bank balance, income, recurring costs, missed commitments, closest connection, biggest skill gain, and optional new goal. No ranked success/fail screen.

## 9. Art, animation, and sound direction

**Art:** Premium stylized realism—natural human proportions, contemporary streets, warm lighting, grounded materials. Avoid photo-real faces and expensive motion-capture expectations. Palette shifts naturally from warm morning to neon-accented night; city identity should feel inviting, not dystopian.

**Assets:** Blockout primitives first. Swap with licensed modular environments, a small consistent character rig and basic animation set (idle/walk/run/talk/work), original UI icons, ambient neighborhood audio. Asset licenses stored with asset source records; source art must not be silently replaced.

**Audio:** Layered ambient city sound and light reactive music; voiceover not needed for slice. Provide separate volume controls (master/music/SFX) by polish milestone.

## 10. Monetization and long-term expansion

V1 is single-player offline and does **not** contain microtransactions. Business model is an independent future decision. After the slice proves fun, potential expansions include additional districts, transportation, owned businesses, deep romance/family, generational simulation, and more sophisticated emergent storylines. None is a prototype dependency.

## 11. Definition of a successful slice

The build is complete when a new player can: create/select a preset -> walk outdoors -> enter cafe -> meet NPC -> work and get paid -> buy/eat groceries -> visit a friend -> sleep -> see a calendar event -> pay rent when due -> save/quit/reload with the same state. No developer command console should be necessary.

**Playtest targets:** >= 80% of five first-time testers can finish their first job and make a friend without developer guidance; at least four can explain why their stats changed; no critical progression bug; uninterrupted 30-minute session; saved state round-trip preserves key player/NPC/economy values. Targets are proposed QC criteria, not measured outcomes.
