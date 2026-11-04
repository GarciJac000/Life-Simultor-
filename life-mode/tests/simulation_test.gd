extends SceneTree
## Milestone 1 simulation QC: clock ticks, needs, economy, rent exactly-once, actions, serialize.

var failures: int = 0
var checks: int = 0

func _initialize() -> void:
 call_deferred("run")

func check(condition: bool, description: String) -> void:
 checks += 1
 if condition:
  print("PASS / ", description)
 else:
  failures += 1
  push_error("FAIL / " + description)

func approx(value: int, expected: int, description: String, slack: int = 0) -> void:
 check(absi(value - expected) <= slack, "%s (got %d, expected %d±%d)" % [description, value, expected, slack])

func clock() -> Node:
 return root.get_node("WorldClock")

func state() -> Node:
 return root.get_node("GameState")

func sim() -> Node:
 return root.get_node("SimulationSystem")

func run() -> void:
 sim().realtime_enabled = false
 state().start_new_game()
 sim().reload_balance()
 check(clock().absolute_game_minutes == 540, "new game starts Day 1 09:00")
 check(state().money == 1250, "starting bank is $1250")
 check(state().get_need(&"energy") == 74, "starting energy")
 check(state().rent_next_due_minute == 10080, "first rent due at Day 8 00:00")

 # Clock day rollover near midnight.
 clock().advance_to(1430)
 clock().advance(20)
 check(clock().day_index() == 2, "advancing past midnight starts day 2")
 check(clock().hour() == 0 and clock().minute() == 10, "23:50 + 20m => 00:10")

 # Needs decay over one game hour (six 10-minute ticks) from a clean preset.
 state().start_new_game()
 var energy_before: int = state().get_need(&"energy")
 var fullness_before: int = state().get_need(&"fullness")
 clock().advance(60)
 approx(state().get_need(&"energy"), energy_before - 3, "energy decays ~3 per hour", 1)
 approx(state().get_need(&"fullness"), fullness_before - 4, "fullness decays ~4 per hour", 1)
 for key in state().NEED_KEYS:
  check(state().get_need(key) >= 0 and state().get_need(key) <= 100, "need clamped: " + String(key))

 # Cafe shift: +$120, +12 career XP, +240 minutes, net energy drop after decay.
 state().start_new_game()
 var rejected: Dictionary = sim().resolve_action(&"work_cafe", &"park")
 check(not rejected.get("ok", true), "cafe shift rejected away from cafe")
 check(state().money == 1250 and clock().absolute_game_minutes == 540, "rejected action changes nothing")
 var shift: Dictionary = sim().resolve_action(&"work_cafe", &"cafe")
 check(shift.get("ok", false), "cafe shift resolves")
 check(state().money == 1370, "cafe shift pays $120")
 check(int(state().skills.career_xp) == 12, "cafe shift grants +12 career XP")
 check(clock().absolute_game_minutes == 780, "cafe shift advances 4 game hours")
 check(state().get_need(&"energy") < 74, "cafe shift reduces energy after work + decay")
 check(bool(state().goals[0].get("done", false)), "work goal completed")

 # Insufficient funds leave state untouched.
 state().set_money(10, "test")
 var broke: Dictionary = sim().resolve_action(&"buy_groceries", &"market")
 check(not broke.get("ok", true), "groceries rejected when underfunded")
 check(state().money == 10, "failed grocery purchase spends nothing")
 check(int(state().inventory.groceries) == 0, "failed grocery purchase adds no inventory")
 check(clock().absolute_game_minutes == 780, "failed grocery purchase advances no time")

 # Groceries -> home meal path.
 state().set_money(200, "test")
 var groceries: Dictionary = sim().resolve_action(&"buy_groceries", &"market")
 check(groceries.get("ok", false) and int(state().inventory.groceries) == 5, "groceries add 5 portions")
 check(state().money == 165, "groceries cost $35")
 var meal: Dictionary = sim().resolve_action(&"eat_home", &"apartment")
 check(meal.get("ok", false) and int(state().inventory.groceries) == 4, "home meal consumes one portion")
 check(state().get_need(&"fullness") > 65, "home meal raises fullness")

 # Sleep advances seven hours and restores energy.
 var before_sleep: int = clock().absolute_game_minutes
 var sleep: Dictionary = sim().resolve_action(&"sleep", &"apartment")
 check(sleep.get("ok", false), "sleep resolves")
 check(clock().absolute_game_minutes == before_sleep + 420, "sleep advances 420 minutes")
 check(state().get_need(&"energy") > 50, "sleep restores energy")

 # Locked jobs stay locked until XP gates.
 state().start_new_game()
 var market_locked: Dictionary = sim().resolve_action(&"work_market", &"market")
 check(not market_locked.get("ok", true), "market job locked at career XP 0")
 state().adjust_skill(&"career_xp", 50, "test unlock")
 var market_open: Dictionary = sim().validate_action(&"work_market", &"market")
 check(market_open.get("ok", false), "market job unlocks at career XP 50")

 # Rent exactly once across the Day 8 boundary.
 state().start_new_game()
 clock().advance_to(10080)
 check(state().money == 950, "exact $300 rent from $1250")
 check(state().rent_arrears == 0, "no arrears when fully paid")
 check(state().processed_rent_ids.has("rent_10080"), "rent id recorded")
 var money_after: int = state().money
 clock().advance_to(10080)
 check(state().money == money_after, "duplicate advance_to same minute does not rebill")
 clock().advance(10)
 check(state().money == money_after, "further advance after rent does not rebill same due")

 # Partial rent + arrears, never negative bank.
 state().start_new_game()
 state().set_money(200, "test")
 clock().advance_to(10080)
 check(state().money == 0, "partial rent drains available cash only")
 check(state().rent_arrears == 100, "shortfall stored as arrears")
 check(state().get_need(&"happiness") <= 68, "unpaid rent applies happiness penalty")

 # Serialize / deserialize round-trip for M1 state.
 state().start_new_game()
 sim().resolve_action(&"work_cafe", &"cafe")
 sim().resolve_action(&"buy_groceries", &"market")
 var blob: Dictionary = state().serialize()
 var money_snap: int = state().money
 var minute_snap: int = clock().absolute_game_minutes
 var xp_snap: int = int(state().skills.career_xp)
 var groceries_snap: int = int(state().inventory.groceries)
 state().start_new_game()
 check(state().money == 1250, "reset restores preset before load")
 state().deserialize(blob)
 check(state().money == money_snap, "deserialize restores money")
 check(clock().absolute_game_minutes == minute_snap, "deserialize restores clock")
 check(int(state().skills.career_xp) == xp_snap, "deserialize restores career XP")
 check(int(state().inventory.groceries) == groceries_snap, "deserialize restores groceries")
 check(state().ledger.size() >= 2, "deserialize restores ledger")

 # Full in-world cafe shift through the action panel plumbing.
 var world: Node3D = load("res://scenes/boot.tscn").instantiate()
 root.add_child(world)
 await process_frame
 await process_frame
 sim().realtime_enabled = false
 state().start_new_game()
 world.current_location = &"cafe"
 world.neighborhood.visible = false
 world.interiors[&"cafe"].visible = true
 world.player.teleport(world.interiors[&"cafe"].global_position + Vector3(-4, 0.05, 0.5), PI)
 await physics_frame
 await process_frame
 var station: InteractionComponent = null
 for node in get_nodes_in_group("interactables"):
  if node.action_id == &"work_cafe" and world.interiors[&"cafe"].is_ancestor_of(node):
   station = node
   break
 check(station != null, "cafe work station exists")
 world.hud.offer_action(&"work_cafe", &"cafe")
 check(world.hud.modal == &"action" and paused, "action confirm pauses game")
 world.hud._confirm_pending_action()
 check(state().money == 1370, "confirmed cafe shift credits bank via HUD")
 check(not paused and world.hud.modal.is_empty(), "confirm closes action modal")

 print("RESULT / %d checks, %d failures" % [checks, failures])
 world.queue_free()
 await process_frame
 quit(1 if failures else 0)
