extends SceneTree
## Captures Milestone 1 demo screenshots: HUD, cafe confirm, post-shift wallet.

func _initialize() -> void:
 call_deferred("run")

func frames(count: int = 4) -> void:
 for i in range(count):
  await physics_frame
  await process_frame

func shot(path: String) -> void:
 await frames(2)
 var image: Image = get_root().get_viewport().get_texture().get_image()
 # Godot 4 viewport images are already top-left origin; do not flip.
 var err := image.save_png(path)
 print("SHOT / ", path, " err=", err, " size=", image.get_width(), "x", image.get_height())

func run() -> void:
 var out_dir := "/opt/cursor/artifacts/screenshots"
 DirAccess.make_dir_recursive_absolute(out_dir)
 var world: Node3D = load("res://scenes/boot.tscn").instantiate()
 root.add_child(world)
 var sim: Node = root.get_node("SimulationSystem")
 var state: Node = root.get_node("GameState")
 sim.realtime_enabled = false
 state.start_new_game()
 await frames(20)
 # Spawn facing cafe entrance.
 world.player.teleport(world.neighborhood.markers[&"cafe"].global_position + Vector3(0, 0.05, 2.2))
 await frames(10)
 await shot(out_dir + "/m1_01_hud_outside_cafe.png")
 # Enter cafe.
 world.neighborhood.markers[&"cafe"].activate()
 await frames(15)
 await shot(out_dir + "/m1_02_cafe_interior.png")
 # Offer and confirm work shift.
 world.hud.offer_action(&"work_cafe", &"cafe")
 await frames(8)
 await shot(out_dir + "/m1_03_action_confirm.png")
 world.hud._confirm_pending_action()
 await frames(10)
 await shot(out_dir + "/m1_04_after_shift.png")
 # Phone wallet.
 world.hud.phone_tab = &"wallet"
 world.hud.set_modal(&"phone")
 await frames(8)
 await shot(out_dir + "/m1_05_phone_wallet.png")
 print("DEMO OK / money=", state.money, " minute=", root.get_node("WorldClock").absolute_game_minutes)
 world.queue_free()
 await frames(2)
 quit(0 if state.money == 1370 else 1)
