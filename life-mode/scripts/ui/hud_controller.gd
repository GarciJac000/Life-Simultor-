extends CanvasLayer

const MapView := preload("res://scripts/ui/map_view.gd")
var world: Node3D
var modal: StringName = &""
var phone_tab: StringName = &"today"
var pending_action: StringName = &""
var pending_location: StringName = &""
var root: Control
var clock_label: Label
var money_label: Label
var location_label: Label
var needs_label: Label
var focus_label: Label
var toast_label: Label
var debug_label: Label
var objective_label: Label
var modal_shade: ColorRect
var modal_panel: PanelContainer
var map_view: Control
var toast_remaining: float = 0.0
var debug_remaining: float = 0.0

func label(text: String, font_size: int = 18) -> Label:
 var node := Label.new()
 node.text = text
 node.add_theme_font_size_override("font_size", font_size)
 node.add_theme_color_override("font_color", Color("ecede4"))
 node.add_theme_color_override("font_outline_color", Color("203239"))
 node.add_theme_constant_override("outline_size", 2)
 return node

func panel_style() -> StyleBoxFlat:
 var style := StyleBoxFlat.new()
 style.bg_color = Color("203239")
 style.border_color = Color("63777a")
 style.set_border_width_all(1)
 style.set_corner_radius_all(6)
 style.content_margin_left = 22
 style.content_margin_right = 22
 style.content_margin_top = 18
 style.content_margin_bottom = 18
 return style

func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 root = Control.new()
 root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(root)
 var header := PanelContainer.new()
 header.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
 header.offset_left = 24
 header.offset_right = -24
 header.offset_top = 16
 header.offset_bottom = 118
 header.add_theme_stylebox_override("panel", panel_style())
 root.add_child(header)
 var header_box := VBoxContainer.new()
 header.add_child(header_box)
 var top := HBoxContainer.new()
 top.add_theme_constant_override("separation", 24)
 header_box.add_child(top)
 clock_label = label("DAY 1", 22)
 clock_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 top.add_child(clock_label)
 money_label = label("$1,250", 22)
 money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
 top.add_child(money_label)
 location_label = label("", 15)
 header_box.add_child(location_label)
 needs_label = label("", 14)
 header_box.add_child(needs_label)
 objective_label = label("", 15)
 objective_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
 objective_label.position = Vector2(-430, -70)
 objective_label.size = Vector2(400, 40)
 objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
 root.add_child(objective_label)
 var footer := label("WASD Move  SHIFT Sprint  MOUSE Orbit  E Interact  TAB Phone  M Map  ESC Pause  F3 Debug", 15)
 footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
 footer.position = Vector2(28, -42)
 root.add_child(footer)
 focus_label = label("", 23)
 focus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 focus_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
 focus_label.position = Vector2(-400, -125)
 focus_label.size.x = 800
 root.add_child(focus_label)
 toast_label = label("", 17)
 toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 toast_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
 toast_label.position = Vector2(-560, -83)
 toast_label.size.x = 1120
 root.add_child(toast_label)
 debug_label = label("", 14)
 debug_label.position = Vector2(28, 135)
 debug_label.visible = false
 root.add_child(debug_label)
 modal_shade = ColorRect.new()
 modal_shade.color = Color(0.035, 0.065, 0.08, 0.84)
 modal_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 modal_shade.visible = false
 root.add_child(modal_shade)
 var center := CenterContainer.new()
 center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 modal_shade.add_child(center)
 modal_panel = PanelContainer.new()
 modal_panel.add_theme_stylebox_override("panel", panel_style())
 center.add_child(modal_panel)
 if not GameState.money_changed.is_connected(_on_money_changed):
  GameState.money_changed.connect(_on_money_changed)
 if not GameState.need_changed.is_connected(_on_need_changed):
  GameState.need_changed.connect(_on_need_changed)
 if not GameState.quest_updated.is_connected(_on_quest_updated):
  GameState.quest_updated.connect(_on_quest_updated)
 if not WorldClock.clock_advanced.is_connected(_on_clock_advanced):
  WorldClock.clock_advanced.connect(_on_clock_advanced)
 if not SimulationSystem.action_resolved.is_connected(_on_action_resolved):
  SimulationSystem.action_resolved.connect(_on_action_resolved)

func attach(value: Node3D) -> void:
 world = value
 refresh_all()
 toast("Milestone 1 / time, needs, jobs and phone are live. Try the cafe shift.")

func refresh_all() -> void:
 refresh_location()
 refresh_clock()
 refresh_money()
 refresh_needs()
 refresh_objective()

func refresh_location() -> void:
 if not is_instance_valid(world):
  return
 location_label.text = "LIFE//MODE     •     %s     •     LANDMARKS %d / 6     •     TAB phone" % [
  String(world.current_location).to_upper(),
  world.visited.size()
 ]

func refresh_clock() -> void:
 clock_label.text = WorldClock.format_clock()

func refresh_money() -> void:
 money_label.text = "$%s" % _comma(GameState.money)
 if GameState.rent_arrears > 0:
  money_label.text += "  |  arrears $%d" % GameState.rent_arrears

func refresh_needs() -> void:
 needs_label.text = "ENERGY %d   FULLNESS %d   HYGIENE %d   SOCIAL %d   MOOD %d   HEALTH %d" % [
  GameState.get_need(&"energy"),
  GameState.get_need(&"fullness"),
  GameState.get_need(&"hygiene"),
  GameState.get_need(&"social"),
  GameState.get_need(&"happiness"),
  GameState.get_need(&"health")
 ]

func refresh_objective() -> void:
 var next := ""
 for goal in GameState.goals:
  if not bool(goal.get("done", false)):
   next = String(goal.get("title", ""))
   break
 objective_label.text = ("OBJECTIVE: " + next.to_upper()) if not next.is_empty() else "OBJECTIVES COMPLETE"

func set_focus(target: InteractionComponent) -> void:
 focus_label.text = "[E]  " + target.action_text + " / " + target.display_name if is_instance_valid(target) else ""

func toast(message: String) -> void:
 toast_label.text = message
 toast_remaining = 5.5

func offer_action(action_id: StringName, location_id: StringName) -> void:
 pending_action = action_id
 pending_location = location_id
 set_modal(&"action")

func _process(delta: float) -> void:
 if not get_tree().paused:
  toast_remaining -= delta
  if toast_remaining <= 0:
   toast_label.text = ""
  refresh_clock()
 if not is_instance_valid(world):
  return
 debug_remaining -= delta
 if debug_label.visible and debug_remaining <= 0:
  debug_remaining = 0.2
  var player: PlayerController = world.player
  debug_label.text = "DEBUG / %s\nPosition %.1f, %.1f, %.1f m\nSpeed %.2f m/s  |  Grounded %s\nFocus %s  |  Minute %d\nFPS %d (not a benchmark)" % [
   Engine.get_version_info().string,
   player.position.x, player.position.y, player.position.z,
   player.velocity.length(),
   player.is_on_floor(),
   player.focused.location_id if is_instance_valid(player.focused) else &"none",
   WorldClock.absolute_game_minutes,
   Engine.get_frames_per_second()
  ]

func _unhandled_input(event: InputEvent) -> void:
 if event.is_echo():
  return
 if event.is_action_pressed("pause"):
  if modal == &"action":
   set_modal(&"")
  else:
   set_modal(&"pause" if modal.is_empty() else &"")
 elif event.is_action_pressed("map"):
  if modal == &"phone":
   phone_tab = &"map"
   set_modal(&"phone")
  else:
   set_modal(&"" if modal == &"map" else &"map")
 elif event.is_action_pressed("phone"):
  if modal == &"phone":
   set_modal(&"")
  else:
   phone_tab = &"today"
   set_modal(&"phone")
 elif event.is_action_pressed("debug_overlay"):
  debug_label.visible = not debug_label.visible
 else:
  return
 get_viewport().set_input_as_handled()

func set_modal(kind: StringName) -> void:
 modal = kind
 for child in modal_panel.get_children():
  modal_panel.remove_child(child)
  child.queue_free()
 modal_shade.visible = not kind.is_empty()
 get_tree().paused = not kind.is_empty()
 Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if get_tree().paused else Input.MOUSE_MODE_CAPTURED
 if is_instance_valid(world):
  world.player.velocity = Vector3.ZERO
 if kind.is_empty():
  pending_action = &""
  pending_location = &""
  return
 var content := VBoxContainer.new()
 content.add_theme_constant_override("separation", 12)
 content.custom_minimum_size.x = 520
 modal_panel.add_child(content)
 match kind:
  &"map":
   _build_map(content)
  &"phone":
   _build_phone(content)
  &"action":
   _build_action(content)
  _:
   _build_pause(content)

func _build_map(content: VBoxContainer) -> void:
 content.add_child(label("DISTRICT MAP", 30))
 map_view = MapView.new()
 map_view.world = world
 map_view.custom_minimum_size = Vector2(412, 395)
 content.add_child(map_view)
 content.add_child(label("01 Apartment  02 Cafe  03 Market\n04 Studio  05 Park  06 Gym", 16))
 _close_button(content, "Close map [M / Esc]")

func _build_pause(content: VBoxContainer) -> void:
 content.add_child(label("PAUSED", 30))
 content.add_child(label("LIFE//MODE / Milestone 1\nClock, needs, economy and phone are active.", 18))
 content.add_child(label(WorldClock.format_clock() + "\nBank $" + _comma(GameState.money), 16))
 _close_button(content, "Resume [Esc]")
 var quit := Button.new()
 quit.text = "Quit to desktop"
 quit.custom_minimum_size.y = 42
 quit.pressed.connect(func(): get_tree().quit())
 content.add_child(quit)

func _build_phone(content: VBoxContainer) -> void:
 content.add_child(label("PHONE", 30))
 var tabs := HBoxContainer.new()
 tabs.add_theme_constant_override("separation", 8)
 content.add_child(tabs)
 for tab in [&"today", &"map", &"wallet", &"goals", &"people"]:
  var button := Button.new()
  button.text = String(tab).capitalize()
  button.toggle_mode = true
  button.button_pressed = phone_tab == tab
  var captured: StringName = tab
  button.pressed.connect(func():
   phone_tab = captured
   set_modal(&"phone")
  )
  tabs.add_child(button)
 var body := VBoxContainer.new()
 body.add_theme_constant_override("separation", 8)
 content.add_child(body)
 match phone_tab:
  &"today":
   body.add_child(label(WorldClock.format_clock(), 20))
   body.add_child(label("Next rent due: Day %d 00:00 ($%d)%s" % [
    GameState.rent_next_due_minute / 1440 + 1,
    GameState.rent_amount,
    (" · arrears $%d" % GameState.rent_arrears) if GameState.rent_arrears > 0 else ""
   ], 16))
   if GameState.event_log.is_empty():
    body.add_child(label("No recent activity yet.", 16))
   else:
    var start := maxi(GameState.event_log.size() - 6, 0)
    for i in range(start, GameState.event_log.size()):
     body.add_child(label("• " + String(GameState.event_log[i].get("text", "")), 15))
  &"map":
   map_view = MapView.new()
   map_view.world = world
   map_view.custom_minimum_size = Vector2(412, 320)
   body.add_child(map_view)
  &"wallet":
   body.add_child(label("Bank  $%s" % _comma(GameState.money), 20))
   body.add_child(label("Weekly rent $%d · next due minute %d · arrears $%d" % [
    GameState.rent_amount, GameState.rent_next_due_minute, GameState.rent_arrears
   ], 15))
   body.add_child(label("Career XP %d · Creative XP %d · Groceries %d" % [
    int(GameState.skills.career_xp), int(GameState.skills.creative_xp), int(GameState.inventory.groceries)
   ], 15))
   if GameState.ledger.is_empty():
    body.add_child(label("No transactions yet.", 16))
   else:
    var from := maxi(GameState.ledger.size() - 8, 0)
    for i in range(GameState.ledger.size() - 1, from - 1, -1):
     var entry: Dictionary = GameState.ledger[i]
     body.add_child(label("%+d  %s  → $%d" % [int(entry.amount), String(entry.reason), int(entry.balance)], 14))
  &"goals":
   for goal in GameState.goals:
    var mark := "[x]" if bool(goal.get("done", false)) else "[ ]"
    body.add_child(label("%s  %s" % [mark, String(goal.get("title", ""))], 16))
  &"people":
   body.add_child(label("People tab arrives with Milestone 2 NPCs.\nFeatured cast: Maya, Jules, Devon, Rowan.", 16))
 _close_button(content, "Close phone [Tab / Esc]")

func _build_action(content: VBoxContainer) -> void:
 var info := SimulationSystem.describe_action(pending_action)
 var validation := SimulationSystem.validate_action(pending_action, pending_location)
 content.add_child(label(String(info.get("title", pending_action)), 28))
 content.add_child(label("Location: " + String(pending_location).capitalize(), 16))
 for line in info.get("lines", []):
  content.add_child(label("• " + String(line), 16))
 if not validation.get("ok", false):
  content.add_child(label("Cannot start: " + String(validation.get("reason", "")), 16))
  _close_button(content, "Cancel [Esc]")
  return
 content.add_child(label("Confirm to spend the time and apply net effects after decay.", 15))
 var row := HBoxContainer.new()
 row.add_theme_constant_override("separation", 12)
 content.add_child(row)
 var confirm := Button.new()
 confirm.text = "Confirm"
 confirm.custom_minimum_size = Vector2(160, 42)
 confirm.pressed.connect(_confirm_pending_action)
 row.add_child(confirm)
 var cancel := Button.new()
 cancel.text = "Cancel"
 cancel.custom_minimum_size = Vector2(160, 42)
 cancel.pressed.connect(func(): set_modal(&""))
 row.add_child(cancel)
 confirm.grab_focus()

func _confirm_pending_action() -> void:
 var action := pending_action
 var location := pending_location
 set_modal(&"")
 var result := SimulationSystem.resolve_action(action, location)
 if result.get("ok", false):
  var net: Dictionary = result.get("net", {})
  var bits: Array[String] = []
  for key in net.keys():
   bits.append("%s %+d" % [String(key), int(net[key])])
  toast("%s · %s" % [String(result.get("title", action)), ", ".join(bits)])
  refresh_all()
 else:
  toast(String(result.get("reason", "Action failed")))

func _close_button(content: VBoxContainer, text: String) -> void:
 var resume := Button.new()
 resume.text = text
 resume.custom_minimum_size.y = 42
 resume.pressed.connect(func(): set_modal(&""))
 content.add_child(resume)
 resume.grab_focus()

func _on_money_changed(_old_amount: int, _new_amount: int, _reason: String) -> void:
 refresh_money()

func _on_need_changed(_stat: StringName, _old_value: int, _new_value: int, _reason: String) -> void:
 refresh_needs()

func _on_quest_updated(_quest_id: StringName, _done: bool) -> void:
 refresh_objective()

func _on_clock_advanced(_from_minute: int, _to_minute: int) -> void:
 refresh_clock()
 refresh_money()
 refresh_needs()

func _on_action_resolved(_action_id: StringName, _result: Dictionary) -> void:
 refresh_all()

func _comma(value: int) -> String:
 var raw := str(value)
 var out := ""
 var count := 0
 for i in range(raw.length() - 1, -1, -1):
  out = raw[i] + out
  count += 1
  if count == 3 and i > 0 and raw[i - 1] != "-":
   out = "," + out
   count = 0
 return out
