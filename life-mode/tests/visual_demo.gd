extends SceneTree
## Capture street / avatar / cafe shots for the realistic visual pass.

func _initialize() -> void:
 call_deferred("run")

func frames(count: int = 4) -> void:
 for i in range(count):
  await physics_frame
  await process_frame

func shot(path: String) -> void:
 await frames(3)
 var image: Image = get_root().get_viewport().get_texture().get_image()
 var err := image.save_png(path)
 print("SHOT / ", path, " err=", err)

func run() -> void:
 var out_dir := "/opt/cursor/artifacts/screenshots"
 DirAccess.make_dir_recursive_absolute(out_dir)
 var world: Node3D = load("res://scenes/boot.tscn").instantiate()
 root.add_child(world)
 var sim: Node = root.get_node("SimulationSystem")
 sim.realtime_enabled = false
 root.get_node("GameState").start_new_game()
 await frames(30)
 # Street view facing cafe with animated walk.
 world.player.teleport(Vector3(20, 0.05, -10), -0.4)
 world.player.arm.rotation.x = -0.22
 await frames(8)
 # Animate a short sprint in place for a lively pose, then freeze for the shot.
 var avatar: AvatarAnimator = world.player.get_node("Visual/AvatarRig")
 for i in range(18):
  avatar.update_motion(8.0, true, 1.0 / 30.0)
 await shot(out_dir + "/v2_01_street_cafe.png")
 # Park greenery.
 world.player.teleport(world.neighborhood.markers[&"park"].global_position + Vector3(0, 0.05, 4), PI)
 world.player.arm.rotation.x = -0.2
 await frames(10)
 await shot(out_dir + "/v2_02_park.png")
 # Side view of walk cycle so limb swing is obvious.
 world.player.teleport(Vector3(0, 0.05, 12), PI * 0.5)
 world.player.pivot.rotation.y = 0.0
 world.player.arm.rotation.x = -0.12
 world.player.arm.spring_length = 3.4
 avatar.phase = 0.8
 for i in range(8):
  avatar.update_motion(6.0, false, 1.0 / 30.0)
 await frames(3)
 await shot(out_dir + "/v2_03_avatar_walk.png")
 # Cafe interior.
 world.neighborhood.markers[&"cafe"].activate()
 await frames(16)
 world.player.arm.spring_length = 4.5
 world.player.arm.rotation.x = -0.18
 await shot(out_dir + "/v2_04_cafe_interior.png")
 print("VISUAL DEMO OK")
 world.queue_free()
 await frames(2)
 quit(0)
