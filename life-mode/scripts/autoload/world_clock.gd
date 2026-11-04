extends Node
## Integer-minute game clock. Time authority lives here; scenes only display it.

signal clock_advanced(from_minute: int, to_minute: int)

const MINUTES_PER_DAY: int = 1440
const TICK_MINUTES: int = 10
const START_MINUTE: int = 540

var absolute_game_minutes: int = START_MINUTE
var last_tick_processed: int = START_MINUTE
var _advancing: bool = false

func reset(start_minute: int = START_MINUTE) -> void:
 absolute_game_minutes = start_minute
 last_tick_processed = start_minute
 _advancing = false

func day_index() -> int:
 return absolute_game_minutes / MINUTES_PER_DAY + 1

func minute_of_day() -> int:
 return absolute_game_minutes % MINUTES_PER_DAY

func hour() -> int:
 return minute_of_day() / 60

func minute() -> int:
 return minute_of_day() % 60

func weekday_name() -> String:
 var names := ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
 return names[(day_index() - 1) % 7]

func format_clock() -> String:
 return "DAY %d • %s %02d:%02d" % [day_index(), weekday_name(), hour(), minute()]

func tick_floor(minute_value: int) -> int:
 return minute_value - (minute_value % TICK_MINUTES)

## Advance by a positive duration. Zero/negative values are no-ops (no duplicate bills).
func advance(minutes: int) -> void:
 if minutes <= 0 or _advancing:
  return
 advance_to(absolute_game_minutes + minutes)

## Jump to an absolute timestamp. Calling with the current time or an earlier time is a no-op.
func advance_to(target_minute: int) -> void:
 if target_minute <= absolute_game_minutes or _advancing:
  return
 _advancing = true
 var from_minute := absolute_game_minutes
 absolute_game_minutes = target_minute
 clock_advanced.emit(from_minute, absolute_game_minutes)
 _advancing = false

func serialize() -> Dictionary:
 return {
  "absolute_game_minutes": absolute_game_minutes,
  "last_tick_processed": last_tick_processed
 }

func deserialize(data: Dictionary) -> void:
 absolute_game_minutes = int(data.get("absolute_game_minutes", START_MINUTE))
 last_tick_processed = int(data.get("last_tick_processed", absolute_game_minutes))
 _advancing = false
