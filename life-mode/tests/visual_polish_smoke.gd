extends SceneTree

# Execute with: godot --headless --path life-mode --script res://tests/visual_polish_smoke.gd
# Graphics-only structural regression gate; DOES NOT verify rendered quality or FPS.
var failed := 0

func verify(ok: bool, label: String) -> void:
 if ok:
  print("PASS / ", label)
 else:
  failed += 1
  push_error("FAIL / " + label)

func _initialize() -> void:
 call_deferred("run")

func run() -> void:
 var world: Node3D = load("res://scenes/boot.tscn").instantiate()
 root.add_child(world)
 await physics_frame
 await process_frame
 verify(world.neighborhood.markers.size() == 6, "original six interactions remain present")
 verify(world.interiors.size() == 2, "apartment and cafe remain accessible")
 verify(world.player.get_node("Visual/Body") != null, "original avatar mesh node retained")
 verify(not world.player.get_node("Visual/Body").visible, "placeholder capsule replaced visually")
 var ornaments := get_nodes_in_group("visual_polish")
 verify(ornaments.size() > 100, "semi-realistic environment detail generated")
 var collider_count := 0
 var rendered_count := 0
 for part in ornaments:
  if part is MeshInstance3D:
   rendered_count += 1
   for child in part.get_children():
    if child is StaticBody3D or child is CollisionShape3D:
     collider_count += 1
 verify(rendered_count > 100, "new visual meshes are available")
 verify(collider_count == 0, "visual polish adds no collision volumes")
 var environment: WorldEnvironment = world.get_node("WorldEnvironment")
 verify(environment.environment != null, "world environment retained")
 verify(environment.environment.ssao_enabled, "screen space ambient occlusion enabled")
 var sun: DirectionalLight3D = world.get_node("Sun")
 verify(sun.shadow_enabled, "sunlight shadows retained")
 print("VISUAL QC / %d failures" % failed)
 world.queue_free()
 await process_frame
 quit(1 if failed > 0 else 0)
