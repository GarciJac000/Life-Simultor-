extends Node
## Canonical serializable progression. UI and scenes request changes; they never own money/time/needs.

signal need_changed(stat: StringName, old_value: int, new_value: int, reason: String)
signal money_changed(old_amount: int, new_amount: int, reason: String)
signal skill_changed(skill: StringName, old_value: int, new_value: int, reason: String)
signal inventory_changed(item: StringName, old_value: int, new_value: int, reason: String)
signal quest_updated(quest_id: StringName, done: bool)
signal state_reset()

const SUBUNITS: int = 60
const NEED_KEYS: Array[StringName] = [&"energy", &"fullness", &"hygiene", &"social", &"happiness", &"health"]

var schema_version: int = 1
var save_id: String = ""
var rng_seed: int = 18477
var player_name: String = "Alex Morgan"
var age: int = 21
var money: int = 1250
var needs_display: Dictionary = {}
var needs_subunits: Dictionary = {}
var inventory: Dictionary = {"groceries": 0}
var skills: Dictionary = {"career_xp": 0, "creative_xp": 0}
var rent_amount: int = 300
var rent_arrears: int = 0
var rent_next_due_minute: int = 10080
var processed_rent_ids: Array = []
var ledger: Array = []
var goals: Array = []
var unlocked_jobs: Array = ["cafe"]
var event_log: Array = []
var low_need_streak_hours: float = 0.0
var _tx_counter: int = 0

func _ready() -> void:
 if needs_display.is_empty():
  start_new_game()

func start_new_game(preset_path: String = "res://data/player_preset.json") -> void:
 var preset := _load_json(preset_path)
 save_id = "slot_%d" % Time.get_unix_time_from_system()
 rng_seed = 18477
 player_name = String(preset.get("name", "Alex Morgan"))
 age = int(preset.get("age", 21))
 money = int(preset.get("money", 1250))
 var need_src: Dictionary = preset.get("needs", {})
 needs_display.clear()
 needs_subunits.clear()
 for key in NEED_KEYS:
  var value := clampi(int(need_src.get(String(key), 50)), 0, 100)
  needs_display[key] = value
  needs_subunits[key] = value * SUBUNITS
 inventory = {"groceries": int(preset.get("inventory", {}).get("groceries", 0))}
 skills = {
  "career_xp": int(preset.get("skills", {}).get("career_xp", 0)),
  "creative_xp": int(preset.get("skills", {}).get("creative_xp", 0))
 }
 var rent: Dictionary = preset.get("rent", {})
 rent_amount = int(rent.get("amount", 300))
 rent_arrears = int(rent.get("arrears", 0))
 rent_next_due_minute = int(rent.get("next_due_minute", 10080))
 processed_rent_ids.clear()
 ledger.clear()
 goals = preset.get("goals", []).duplicate(true)
 unlocked_jobs = ["cafe"]
 event_log.clear()
 low_need_streak_hours = 0.0
 _tx_counter = 0
 var start_minute := int(preset.get("absolute_game_minutes", WorldClock.START_MINUTE))
 WorldClock.reset(start_minute)
 state_reset.emit()

func get_need(stat: StringName) -> int:
 return int(needs_display.get(stat, 0))

func adjust_need(stat: StringName, delta_points: int, reason: String) -> void:
 if not needs_display.has(stat):
  return
 var old_value: int = needs_display[stat]
 var subunits: int = needs_subunits[stat] + delta_points * SUBUNITS
 subunits = clampi(subunits, 0, 100 * SUBUNITS)
 needs_subunits[stat] = subunits
 needs_display[stat] = subunits / SUBUNITS
 var new_value: int = needs_display[stat]
 if new_value != old_value:
  need_changed.emit(stat, old_value, new_value, reason)

func adjust_need_subunits(stat: StringName, delta_subunits: int, reason: String) -> void:
 if not needs_subunits.has(stat):
  return
 var old_value: int = needs_display[stat]
 var subunits: int = clampi(int(needs_subunits[stat]) + delta_subunits, 0, 100 * SUBUNITS)
 needs_subunits[stat] = subunits
 needs_display[stat] = subunits / SUBUNITS
 var new_value: int = needs_display[stat]
 if new_value != old_value:
  need_changed.emit(stat, old_value, new_value, reason)

func set_money(new_amount: int, reason: String) -> void:
 var old_amount := money
 money = maxi(new_amount, 0)
 if money != old_amount:
  money_changed.emit(old_amount, money, reason)

func add_ledger(kind: String, amount: int, reason: String, balance_after: int) -> Dictionary:
 _tx_counter += 1
 var entry := {
  "id": "tx_%d" % _tx_counter,
  "minute": WorldClock.absolute_game_minutes,
  "kind": kind,
  "amount": amount,
  "reason": reason,
  "balance": balance_after
 }
 ledger.append(entry)
 return entry

func adjust_inventory(item: StringName, delta: int, reason: String) -> bool:
 var old_value := int(inventory.get(item, 0))
 var new_value := old_value + delta
 if new_value < 0:
  return false
 inventory[item] = new_value
 inventory_changed.emit(item, old_value, new_value, reason)
 return true

func adjust_skill(skill: StringName, delta: int, reason: String) -> void:
 var old_value := int(skills.get(skill, 0))
 var new_value := maxi(old_value + delta, 0)
 skills[skill] = new_value
 if new_value != old_value:
  skill_changed.emit(skill, old_value, new_value, reason)
 _refresh_job_unlocks()

func _refresh_job_unlocks() -> void:
 if int(skills.get("career_xp", 0)) >= 50 and not unlocked_jobs.has("market"):
  unlocked_jobs.append("market")
  append_log("Market stock clerk role unlocked (Career XP 50).")
 if int(skills.get("creative_xp", 0)) >= 50 and not unlocked_jobs.has("studio"):
  unlocked_jobs.append("studio")
  append_log("Studio assistant role unlocked (Creative XP 50).")

func mark_goal(goal_id: StringName, done: bool = true) -> void:
 for goal in goals:
  if String(goal.get("id", "")) == String(goal_id):
   if bool(goal.get("done", false)) == done:
    return
   goal["done"] = done
   quest_updated.emit(goal_id, done)
   return

func append_log(message: String) -> void:
 event_log.append({
  "minute": WorldClock.absolute_game_minutes,
  "text": message
 })
 if event_log.size() > 40:
  event_log.pop_front()

func serialize() -> Dictionary:
 return {
  "schema_version": schema_version,
  "save_id": save_id,
  "rng_seed": rng_seed,
  "clock": WorldClock.serialize(),
  "player": {
   "name": player_name,
   "age": age,
   "money": money,
   "needs": needs_display.duplicate(true),
   "needs_subunits": needs_subunits.duplicate(true),
   "inventory": inventory.duplicate(true),
   "skills": skills.duplicate(true)
  },
  "rent": {
   "amount": rent_amount,
   "arrears": rent_arrears,
   "next_due_minute": rent_next_due_minute
  },
  "processed_rent_ids": processed_rent_ids.duplicate(),
  "ledger": ledger.duplicate(true),
  "goals": goals.duplicate(true),
  "unlocked_jobs": unlocked_jobs.duplicate(),
  "event_log": event_log.duplicate(true),
  "low_need_streak_hours": low_need_streak_hours,
  "tx_counter": _tx_counter
 }

func deserialize(data: Dictionary) -> void:
 schema_version = int(data.get("schema_version", 1))
 save_id = String(data.get("save_id", save_id))
 rng_seed = int(data.get("rng_seed", 18477))
 WorldClock.deserialize(data.get("clock", {}))
 var player: Dictionary = data.get("player", {})
 player_name = String(player.get("name", player_name))
 age = int(player.get("age", age))
 money = int(player.get("money", money))
 needs_display = player.get("needs", needs_display).duplicate(true)
 needs_subunits = player.get("needs_subunits", {}).duplicate(true)
 if needs_subunits.is_empty():
  for key in NEED_KEYS:
   needs_subunits[key] = int(needs_display.get(key, 0)) * SUBUNITS
 inventory = player.get("inventory", inventory).duplicate(true)
 skills = player.get("skills", skills).duplicate(true)
 var rent: Dictionary = data.get("rent", {})
 rent_amount = int(rent.get("amount", rent_amount))
 rent_arrears = int(rent.get("arrears", rent_arrears))
 rent_next_due_minute = int(rent.get("next_due_minute", rent_next_due_minute))
 processed_rent_ids = data.get("processed_rent_ids", []).duplicate()
 ledger = data.get("ledger", []).duplicate(true)
 goals = data.get("goals", []).duplicate(true)
 unlocked_jobs = data.get("unlocked_jobs", ["cafe"]).duplicate()
 event_log = data.get("event_log", []).duplicate(true)
 low_need_streak_hours = float(data.get("low_need_streak_hours", 0.0))
 _tx_counter = int(data.get("tx_counter", ledger.size()))
 state_reset.emit()

func _load_json(path: String) -> Dictionary:
 if not FileAccess.file_exists(path):
  push_warning("Missing preset: " + path)
  return {}
 var file := FileAccess.open(path, FileAccess.READ)
 var parsed: Variant = JSON.parse_string(file.get_as_text())
 return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
