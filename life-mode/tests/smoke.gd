extends SceneTree

var failures: int = 0
var checks: int = 0
var world: Node3D
var player: PlayerController

func _initialize() -> void:
 call_deferred("run")

func check(condition: bool, description: String) -> void:
 checks += 1
 if condition:
  print("PASS / ", description)
 else:
  failures += 1
  push_error("FAIL / " + description)

func frames(count: int = 3) -> void:
 for i in range(count):
  await physics_frame
  await process_frame

func key(action: StringName) -> void:
 var event := InputEventAction.new()
 event.action = action
 event.pressed = true
 Input.parse_input_event(event)
 await process_frame
 event = InputEventAction.new()
 event.action = action
 event.pressed = false
 Input.parse_input_event(event)
 await process_frame

func walk(action: StringName, count: int, sprinting: bool = false) -> float:
 var start := player.global_position
 Input.action_press(action)
 if sprinting:
  Input.action_press("sprint")
 await frames(count)
 Input.action_release(action)
 Input.action_release("sprint")
 await frames()
 return start.distance_to(player.global_position)

func run() -> void:
 world = load("res://scenes/boot.tscn").instantiate()
 root.add_child(world)
 player = world.player
 await frames(12)
 check(Engine.get_version_info().string.begins_with("4.7.2"), "requested Godot 4.7.2 engine")
 check(world.neighborhood.markers.size() == 6, "six unique neighborhood markers")
 check(get_nodes_in_group("interactables").size() == 8, "six landmarks and two exit components")
 check(player.is_on_floor() and player.global_position.y > -0.05, "spawn settles on ground")
 check(player.get_node("Visual/Body").mesh != null, "visible player geometry")
 check(player.camera.current, "third-person camera is current")
 for action in [&"move_forward", &"move_back", &"move_left", &"move_right", &"sprint", &"interact", &"map", &"pause", &"debug_overlay"]:
  check(InputMap.has_action(action) and not InputMap.action_get_events(action).is_empty(), "mapped input: " + String(action))
 # Exercise actual CharacterBody physics and action input, rather than only testing constants.
 player.teleport(Vector3(0, 0.05, 65))
 await frames()
 var walked := await walk(&"move_forward", 45)
 check(walked > 3 and walked < 5, "walking moves at approximately 5 m/s")
 player.teleport(Vector3(0, 0.05, 65))
 await frames()
 var sprinted := await walk(&"move_forward", 45, true)
 check(sprinted > walked * 1.6 and sprinted < walked * 2.0, "sprint increases movement speed without simulation stats")
 player.teleport(Vector3(0, 0.05, -120))
 await frames()
 await walk(&"move_forward", 90, true)
 check(player.global_position.z > -124.5 and player.global_position.y >= -0.05, "north boundary blocks escape and fall-through")
 player.teleport(Vector3(-34, 0.05, -17))
 await frames()
 await walk(&"move_forward", 90, true)
 check(player.global_position.z > -21.7, "building facade blocks character collision")
 # Ground coverage probes include every corner and the crossing.
 for at in [Vector3(-122, 0.1, -122), Vector3(122, 0.1, -122), Vector3(-122, 0.1, 122), Vector3(122, 0.1, 122), Vector3.ZERO]:
  player.teleport(at)
  await frames(12)
  check(player.is_on_floor() and player.position.y > -0.05, "ground coverage at " + str(at))
 for id in world.neighborhood.markers:
  var marker: InteractionComponent = world.neighborhood.markers[id]
  player.teleport(marker.global_position + Vector3(0, 0.05, 2))
  await frames()
  check(player.focused == marker, "forward focus within 2.5m: " + String(id))
  await key(&"interact")
  check(marker.activation_count == 1, "E activates exactly once: " + String(id))
  check(world.visited.has(id), "landmark recorded: " + String(id))
  if id in [&"apartment", &"cafe"]:
   check(world.current_location == id and world.interiors[id].visible and not world.neighborhood.visible, "enter interior: " + String(id))
   await frames(12)
   check(player.is_on_floor(), "interior floor collision: " + String(id))
   check(player.focused == world.interiors[id].exit_marker, "exit prompt reachable: " + String(id))
   await key(&"interact")
   await frames()
   check(world.current_location == &"outside" and world.neighborhood.visible, "exit round trip: " + String(id))
 var cafe: InteractionComponent = world.neighborhood.markers[&"cafe"]
 player.teleport(cafe.global_position + Vector3(0, 0.05, 3.2))
 await frames()
 check(player.focused == null, "out-of-range target has no prompt")
 var activation_count := cafe.activation_count
 await key(&"interact")
 check(cafe.activation_count == activation_count, "E outside radius cannot activate")
 player.teleport(cafe.global_position + Vector3(0, 0.05, 2), PI)
 await frames()
 check(player.focused == null, "target behind camera direction has no focus")
 player.teleport(cafe.global_position + Vector3(0, 0.05, 2))
 var obstruction := StaticBody3D.new()
 var collision := CollisionShape3D.new()
 var shape := BoxShape3D.new()
 shape.size = Vector3(3, 3, 0.3)
 collision.shape = shape
 obstruction.add_child(collision)
 world.add_child(obstruction)
 obstruction.global_position = cafe.global_position + Vector3(0, 1, 1)
 await frames()
 check(player.focused == null, "wall occludes otherwise reachable marker")
 obstruction.queue_free()
 await frames()
 check(player.focused == cafe, "focus returns when occluder is removed")
 # Camera sensitivity and pitch limits via actual input dispatch.
 var motion := InputEventMouseMotion.new()
 motion.relative = Vector2(80, 100000)
 var old_yaw := player.pivot.rotation.y
 if DisplayServer.get_name() == "headless":
  player.orbit(motion.relative)
 else:
  Input.parse_input_event(motion)
 await process_frame
 check(player.pivot.rotation.y < old_yaw, "mouse orbits camera")
 check(is_equal_approx(player.arm.rotation.x, -0.85), "camera pitch clamps")
 for i in range(3):
  await key(&"map")
  check(paused and world.hud.modal == &"map", "map opens and pauses physics")
  check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE or DisplayServer.get_name() == "headless", "map releases cursor")
  var before := player.position
  var interactions_before := cafe.activation_count
  Input.action_press("move_forward")
  await key(&"interact")
  await frames(5)
  check(player.position.is_equal_approx(before) and cafe.activation_count == interactions_before, "map blocks movement and E")
  Input.action_release("move_forward")
  await key(&"pause")
  check(not paused and world.hud.modal.is_empty(), "Esc closes map without opening another modal")
  await key(&"pause")
  check(paused and world.hud.modal == &"pause", "Esc opens pause")
  await key(&"pause")
  check(not paused and world.hud.modal.is_empty(), "Esc resumes")
 check(await walk(&"move_back", 15) > 0.8, "movement recovers after repeated menu cycles")
 # Continuous traversal of both main streets and the outer perimeter.
 for route in [
  [Vector3(0, 0.05, 120), 0.0],
  [Vector3(-120, 0.05, 0), -PI / 2],
  [Vector3(-120, 0.05, 120), 0.0],
  [Vector3(-120, 0.05, -120), -PI / 2],
  [Vector3(120, 0.05, -120), PI],
  [Vector3(120, 0.05, 120), PI / 2]
 ]:
  player.teleport(route[0], route[1])
  await frames()
  var distance := await walk(&"move_forward", 1560, true)
  check(distance > 230 and player.is_on_floor(), "continuous street/perimeter traversal: " + str(route[0]))
 await key(&"debug_overlay")
 check(world.hud.debug_label.visible, "F3 toggles debug overlay")
 print("RESULT / %d checks, %d failures" % [checks, failures])
 world.queue_free()
 await frames()
 quit(1 if failures else 0)
