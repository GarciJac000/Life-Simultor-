extends CanvasLayer

const MapView := preload("res://scripts/ui/map_view.gd")
var world: Node3D
var modal: StringName = &""
var root: Control
var location_label: Label
var focus_label: Label
var toast_label: Label
var debug_label: Label
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
 header.offset_top = 20
 header.offset_bottom = 102
 header.add_theme_stylebox_override("panel", panel_style())
 root.add_child(header)
 var header_box := VBoxContainer.new()
 header.add_child(header_box)
 header_box.add_child(label("LIFE//MODE     /     NEIGHBORHOOD STUDY", 25))
 location_label = label("", 15)
 header_box.add_child(location_label)
 var footer := label("WASD  Move     SHIFT  Sprint     MOUSE  Orbit     E  Interact     M  Map     ESC  Pause     F3  Debug", 16)
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
 debug_label.position = Vector2(28, 125)
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

func attach(value: Node3D) -> void:
 world = value
 refresh_location()
 toast("Milestone 0 / explore six landmarks. Apartment and cafe doors are enterable.")

func refresh_location() -> void:
 location_label.text = "M0 / GRAYBOX     •     " + String(world.current_location).to_upper() + "     •     250 × 250 m     •     LANDMARKS %d / 6" % world.visited.size()

func set_focus(target: InteractionComponent) -> void:
 focus_label.text = "[E]  " + target.action_text + " / " + target.display_name if is_instance_valid(target) else ""

func toast(message: String) -> void:
 toast_label.text = message
 toast_remaining = 5.0

func _process(delta: float) -> void:
 if not get_tree().paused:
  toast_remaining -= delta
  if toast_remaining <= 0:
   toast_label.text = ""
 if not is_instance_valid(world):
  return
 debug_remaining -= delta
 if debug_label.visible and debug_remaining <= 0:
  debug_remaining = 0.2
  var player: PlayerController = world.player
  debug_label.text = "DEBUG / %s
Position %.1f, %.1f, %.1f m
Speed %.2f m/s  |  Grounded %s
Focus %s  |  Radius 2.5 m
FPS %d (not a benchmark)" % [Engine.get_version_info().string, player.position.x, player.position.y, player.position.z, player.velocity.length(), player.is_on_floor(), player.focused.location_id if is_instance_valid(player.focused) else &"none", Engine.get_frames_per_second()]

func _unhandled_input(event: InputEvent) -> void:
 if event.is_echo():
  return
 if event.is_action_pressed("pause"):
  set_modal(&"pause" if modal.is_empty() else &"")
 elif event.is_action_pressed("map"):
  set_modal(&"" if modal == &"map" else &"map")
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
  return
 var content := VBoxContainer.new()
 content.add_theme_constant_override("separation", 12)
 content.custom_minimum_size.x = 420
 modal_panel.add_child(content)
 content.add_child(label("DISTRICT MAP" if kind == &"map" else "PAUSED", 30))
 if kind == &"map":
  map_view = MapView.new()
  map_view.world = world
  map_view.custom_minimum_size = Vector2(412, 395)
  content.add_child(map_view)
  content.add_child(label("01 Apartment       02 Cafe       03 Corner market
04 Music studio    05 Public park    06 Gym courtyard", 16))
  content.add_child(label("Gold dot: you  /  North is up  /  250 m square", 15))
 else:
  content.add_child(label("LIFE//MODE / Milestone 0
Simulation systems are outside this build.", 18))
 var resume := Button.new()
 resume.text = "Close map [M / Esc]" if kind == &"map" else "Resume [Esc]"
 resume.custom_minimum_size.y = 42
 resume.pressed.connect(func(): set_modal(&""))
 content.add_child(resume)
 resume.grab_focus()
 if kind == &"pause":
  var quit := Button.new()
  quit.text = "Quit to desktop"
  quit.custom_minimum_size.y = 42
  quit.pressed.connect(func(): get_tree().quit())
  content.add_child(quit)
