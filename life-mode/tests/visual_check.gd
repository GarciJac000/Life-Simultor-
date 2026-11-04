extends SceneTree

var failed: bool = false

func _initialize() -> void:
 call_deferred("run")

func frames(count: int = 8) -> void:
 for i in range(count):
  await physics_frame
  await process_frame

func capture(name: String) -> void:
 await RenderingServer.frame_post_draw
 var image := root.get_texture().get_image()
 if image.is_empty():
  failed = true
  push_error("Empty viewport")
 else:
  var result := image.save_png("res://docs/screenshots/" + name + ".png")
  if result != OK:
   failed = true
  print("CAPTURE / ", name, " / ", image.get_size(), " / ", result)

func run() -> void:
 var world: Node3D = load("res://scenes/boot.tscn").instantiate()
 root.add_child(world)
 await frames(20)
 await capture("world")
 var player: PlayerController = world.player
 var old_yaw := player.pivot.rotation.y
 var mouse := InputEventMouseMotion.new()
 mouse.relative = Vector2(100, 100000)
 Input.parse_input_event(mouse)
 await frames()
 if player.pivot.rotation.y >= old_yaw or not is_equal_approx(player.arm.rotation.x, -0.85):
  failed = true
  push_error("Rendered mouse capture/orbit check failed")
 else:
  print("PASS / rendered captured mouse orbit and pitch clamp")
 # Place the camera behind a facade, with the player on the public side.
 player.teleport(Vector3(-34, 0.05, -19), PI)
 await frames(20)
 print("CAMERA / spring hit length = ", player.arm.get_hit_length())
 if player.arm.get_hit_length() >= 5.5 or player.arm.get_hit_length() <= 0:
  failed = true
  push_error("Camera spring arm did not retract at wall")
 else:
  print("PASS / camera retracts before wall")
 player.teleport(Vector3(-34, 0.05, -17))
 await frames()
 world.hud.set_modal(&"map")
 await frames()
 await capture("map")
 world.hud.set_modal(&"pause")
 await frames()
 await capture("pause")
 world.hud.set_modal(&"")
 # Enter the cafe using the real interaction event.
 player.teleport(world.neighborhood.markers[&"cafe"].global_position + Vector3(0, 0.05, 2))
 await frames()
 var interact := InputEventAction.new()
 interact.action = &"interact"
 interact.pressed = true
 Input.parse_input_event(interact)
 await frames()
 interact = InputEventAction.new()
 interact.action = &"interact"
 interact.pressed = false
 Input.parse_input_event(interact)
 await frames()
 # Orbit toward the room for the interior documentation screenshot.
 player.pivot.rotation.y = 0
 await frames()
 await capture("cafe")
 var overview := Camera3D.new()
 world.add_child(overview)
 overview.position = Vector3(115, 155, 160)
 overview.look_at(Vector3.ZERO)
 overview.current = true
 world.neighborhood.visible = true
 for room in world.interiors.values():
  room.visible = false
 world.hud.root.visible = false
 await frames()
 await capture("district")
 print("VISUAL RESULT / ", "FAIL" if failed else "PASS")
 world.queue_free()
 await frames()
 quit(1 if failed else 0)
