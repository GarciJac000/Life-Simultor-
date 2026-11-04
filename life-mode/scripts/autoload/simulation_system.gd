extends Node
## Action validation/resolution and 10-minute need ticks. Deterministic; no UI authority.

signal action_requested(actor_id: StringName, action_id: StringName, target_id: StringName)
signal action_resolved(action_id: StringName, result: Dictionary)
signal tick_processed(tick_minute: int)

var balance: Dictionary = {}
var actions: Dictionary = {}
var realtime_accum: float = 0.0
var realtime_enabled: bool = true
var _busy: bool = false

func _ready() -> void:
 reload_balance()
 if not WorldClock.clock_advanced.is_connected(_on_clock_advanced):
  WorldClock.clock_advanced.connect(_on_clock_advanced)

func reload_balance(path: String = "res://data/game_balance.json") -> void:
 if not FileAccess.file_exists(path):
  push_error("Missing balance file: " + path)
  balance = {}
  actions = {}
  return
 var file := FileAccess.open(path, FileAccess.READ)
 var parsed: Variant = JSON.parse_string(file.get_as_text())
 balance = parsed if typeof(parsed) == TYPE_DICTIONARY else {}
 actions = balance.get("actions", {})

func _process(delta: float) -> void:
 if not realtime_enabled or _busy:
  return
 if get_tree().paused:
  return
 var rate := float(balance.get("realtime_game_minutes_per_second", 2.0))
 realtime_accum += delta * rate
 var whole := int(realtime_accum)
 if whole <= 0:
  return
 realtime_accum -= float(whole)
 WorldClock.advance(whole)

func get_action(action_id: StringName) -> Dictionary:
 return actions.get(String(action_id), {})

func describe_action(action_id: StringName) -> Dictionary:
 var action := get_action(action_id)
 if action.is_empty():
  return {"ok": false, "reason": "Unknown action"}
 var lines: Array[String] = []
 var duration := int(action.get("duration_minutes", 0))
 lines.append("Time: %s" % _format_duration(duration))
 var money := int(action.get("money", 0))
 if money > 0:
  lines.append("Pay: +$%d" % money)
 elif money < 0:
  lines.append("Cost: $%d" % abs(money))
 for stat in [&"energy", &"fullness", &"hygiene", &"social", &"happiness", &"health"]:
  var delta := int(action.get(String(stat), 0))
  if delta != 0:
   lines.append("%s %+d (before time decay)" % [String(stat).capitalize(), delta])
 if action.has("career_xp"):
  lines.append("Career XP %+d" % int(action.career_xp))
 if action.has("creative_xp"):
  lines.append("Creative XP %+d" % int(action.creative_xp))
 if action.has("groceries"):
  lines.append("Groceries +%d portions" % int(action.groceries))
 if int(action.get("requires_groceries", 0)) > 0:
  lines.append("Uses %d home meal portion" % int(action.requires_groceries))
 return {
  "ok": true,
  "title": String(action.get("title", action_id)),
  "location": String(action.get("location", "")),
  "duration_minutes": duration,
  "lines": lines,
  "action": action
 }

func validate_action(action_id: StringName, current_location: StringName) -> Dictionary:
 var action := get_action(action_id)
 if action.is_empty():
  return {"ok": false, "reason": "Unknown action"}
 if _busy:
  return {"ok": false, "reason": "Already resolving an action"}
 var required_location := StringName(String(action.get("location", "")))
 if required_location != current_location:
  return {"ok": false, "reason": "Must be at %s" % String(required_location)}
 var money := int(action.get("money", 0))
 if money < 0 and not EconomySystem.can_afford(-money):
  return {"ok": false, "reason": "Not enough funds ($%d needed)" % -money}
 var need_food := int(action.get("requires_groceries", 0))
 if need_food > 0 and int(GameState.inventory.get("groceries", 0)) < need_food:
  return {"ok": false, "reason": "No home meal portions left"}
 if action.has("requires_job"):
  var job := String(action.requires_job)
  if not GameState.unlocked_jobs.has(job):
   return {"ok": false, "reason": "Job not unlocked yet"}
 if action.has("requires_career_xp") and int(GameState.skills.get("career_xp", 0)) < int(action.requires_career_xp):
  return {"ok": false, "reason": "Need Career XP %d" % int(action.requires_career_xp)}
 if action.has("requires_creative_xp") and int(GameState.skills.get("creative_xp", 0)) < int(action.requires_creative_xp):
  return {"ok": false, "reason": "Need Creative XP %d" % int(action.requires_creative_xp)}
 return {"ok": true, "action": action}

func resolve_action(action_id: StringName, current_location: StringName, actor_id: StringName = &"player") -> Dictionary:
 action_requested.emit(actor_id, action_id, current_location)
 var validation := validate_action(action_id, current_location)
 if not validation.get("ok", false):
  var rejected := {
   "ok": false,
   "action_id": String(action_id),
   "reason": String(validation.get("reason", "Rejected"))
  }
  action_resolved.emit(action_id, rejected)
  return rejected
 var action: Dictionary = validation.action
 _busy = true
 realtime_enabled = false
 var before := _snapshot()
 # Direct costs first so failed spends never burn time.
 var money := int(action.get("money", 0))
 if money < 0:
  var spent := EconomySystem.try_spend(-money, String(action.get("title", action_id)))
  if not spent.get("ok", false):
   _busy = false
   realtime_enabled = true
   var fail := {"ok": false, "action_id": String(action_id), "reason": String(spent.get("reason", "Payment failed"))}
   action_resolved.emit(action_id, fail)
   return fail
 elif money > 0:
  EconomySystem.credit(money, String(action.get("title", action_id)))
 if int(action.get("requires_groceries", 0)) > 0:
  if not GameState.adjust_inventory(&"groceries", -int(action.requires_groceries), String(action.title)):
   _busy = false
   realtime_enabled = true
   var fail2 := {"ok": false, "action_id": String(action_id), "reason": "No groceries"}
   action_resolved.emit(action_id, fail2)
   return fail2
 if action.has("groceries"):
  GameState.adjust_inventory(&"groceries", int(action.groceries), String(action.title))
 for stat in [&"energy", &"fullness", &"hygiene", &"social", &"happiness", &"health"]:
  var delta := int(action.get(String(stat), 0))
  if delta != 0:
   GameState.adjust_need(stat, delta, String(action.get("title", action_id)))
 if action.has("career_xp"):
  GameState.adjust_skill(&"career_xp", int(action.career_xp), String(action.title))
 if action.has("creative_xp"):
  GameState.adjust_skill(&"creative_xp", int(action.creative_xp), String(action.title))
 var duration := int(action.get("duration_minutes", 0))
 WorldClock.advance(duration)
 var after := _snapshot()
 var receipt := {
  "ok": true,
  "action_id": String(action_id),
  "title": String(action.get("title", action_id)),
  "duration_minutes": duration,
  "net": _diff(before, after),
  "clock": WorldClock.format_clock(),
  "money": GameState.money
 }
 _update_goals(action_id)
 GameState.append_log("%s complete. %s" % [receipt.title, WorldClock.format_clock()])
 _busy = false
 realtime_enabled = true
 action_resolved.emit(action_id, receipt)
 return receipt

func _on_clock_advanced(from_minute: int, to_minute: int) -> void:
 EconomySystem.process_rent_between(from_minute, to_minute)
 var tick := WorldClock.TICK_MINUTES
 var cursor := WorldClock.tick_floor(WorldClock.last_tick_processed)
 if cursor < WorldClock.last_tick_processed:
  cursor = WorldClock.last_tick_processed
 # Process every tick boundary strictly after last_tick_processed up to the tick floor of to_minute.
 var target := WorldClock.tick_floor(to_minute)
 var next_tick := WorldClock.last_tick_processed + tick
 # Align to tick grid if last_tick was on a boundary.
 if WorldClock.last_tick_processed % tick == 0:
  next_tick = WorldClock.last_tick_processed + tick
 else:
  next_tick = WorldClock.tick_floor(WorldClock.last_tick_processed) + tick
 while next_tick <= target:
  _apply_tick(next_tick)
  WorldClock.last_tick_processed = next_tick
  tick_processed.emit(next_tick)
  next_tick += tick
 # If we landed mid-tick, keep last_tick_processed as the last full tick (already set).
 if to_minute > WorldClock.last_tick_processed:
  # No partial tick decay; subunits accumulate only on full ticks.
  pass

func _apply_tick(tick_minute: int) -> void:
 var hourly: Dictionary = balance.get("hourly_decay", {})
 var scale := int(balance.get("need_subunit_scale", GameState.SUBUNITS))
 # Per 10-minute tick = hourly / 6, in subunits.
 for stat in [&"energy", &"fullness", &"hygiene", &"social"]:
  var per_hour := int(hourly.get(String(stat), 0))
  var delta_subunits := -int(round(float(per_hour * scale) / 6.0))
  if delta_subunits != 0:
   GameState.adjust_need_subunits(stat, delta_subunits, "time")
 var low_count := 0
 var threshold := int(balance.get("happiness_low_need_threshold", 30))
 for stat in [&"energy", &"fullness", &"hygiene", &"social"]:
  if GameState.get_need(stat) < threshold:
   low_count += 1
 if low_count >= 2:
  var happiness_pen := -int(balance.get("happiness_hourly_penalty", 1))
  # Convert hourly happiness penalty into per-tick point adjustment via subunits.
  GameState.adjust_need_subunits(&"happiness", happiness_pen * scale / 6, "low needs")
 var crisis_threshold := int(balance.get("health_crisis_threshold", 15))
 var crisis := 0
 for stat in [&"energy", &"fullness", &"hygiene", &"social"]:
  if GameState.get_need(stat) < crisis_threshold:
   crisis += 1
 if crisis >= 2:
  GameState.low_need_streak_hours += 1.0 / 6.0
 else:
  GameState.low_need_streak_hours = 0.0
 var crisis_hours := float(balance.get("health_crisis_hours", 6))
 if GameState.low_need_streak_hours + 0.0001 >= crisis_hours:
  GameState.adjust_need(&"health", -int(balance.get("health_daily_penalty", 1)), "prolonged low needs")
  GameState.low_need_streak_hours = 0.0

func _update_goals(action_id: StringName) -> void:
 match String(action_id):
  "work_cafe", "work_market", "work_studio":
   GameState.mark_goal(&"work_one_shift", true)
  "eat_home":
   GameState.mark_goal(&"cook_at_home", true)
  "buy_groceries":
   GameState.mark_goal(&"buy_groceries", true)
  "make_music":
   GameState.mark_goal(&"explore_studio", true)
 if GameState.money >= GameState.rent_amount:
  GameState.mark_goal(&"pay_rent_ready", true)
 else:
  GameState.mark_goal(&"pay_rent_ready", false)

func _snapshot() -> Dictionary:
 return {
  "money": GameState.money,
  "energy": GameState.get_need(&"energy"),
  "fullness": GameState.get_need(&"fullness"),
  "hygiene": GameState.get_need(&"hygiene"),
  "social": GameState.get_need(&"social"),
  "happiness": GameState.get_need(&"happiness"),
  "health": GameState.get_need(&"health"),
  "career_xp": int(GameState.skills.get("career_xp", 0)),
  "creative_xp": int(GameState.skills.get("creative_xp", 0)),
  "groceries": int(GameState.inventory.get("groceries", 0)),
  "minute": WorldClock.absolute_game_minutes
 }

func _diff(before: Dictionary, after: Dictionary) -> Dictionary:
 var result := {}
 for key in before.keys():
  var delta: int = int(after[key]) - int(before[key])
  if delta != 0:
   result[key] = delta
 return result

func _format_duration(minutes: int) -> String:
 if minutes < 60:
  return "%dm" % minutes
 if minutes % 60 == 0:
  return "%dh" % (minutes / 60)
 return "%dh %dm" % [minutes / 60, minutes % 60]
