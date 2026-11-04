class_name VisualPolish
extends RefCounted

# Graphics-only additions. Decorative objects have NO collision shapes.
# Milestone physics, portals, and interaction distances remain unchanged.

static func surface(parent: Node3D, at: Vector3, size: Vector3, tint: Color, roughness: float = 0.76, metallic: float = 0.0, kind: StringName = &"plaster") -> MeshInstance3D:
 var part := MeshInstance3D.new()
 var shape := BoxMesh.new()
 shape.size = size
 part.mesh = shape
 part.position = at
 part.material_override = MaterialLibrary.make(kind, tint, roughness, metallic)
 part.add_to_group("visual_polish")
 part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if size.y < 0.08 else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 parent.add_child(part)
 return part

static func ellipsoid(parent: Node3D, at: Vector3, dimensions: Vector3, tint: Color, roughness: float = 0.87, kind: StringName = &"plaster") -> void:
 var part := MeshInstance3D.new()
 var shape := SphereMesh.new()
 shape.radius = 0.5
 shape.height = 1.0
 part.mesh = shape
 part.position = at
 part.scale = dimensions
 part.material_override = MaterialLibrary.make(kind, tint, roughness, 0.0)
 part.add_to_group("visual_polish")
 part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 parent.add_child(part)

static func pole(parent: Node3D, at: Vector3, height: float, radius: float, tint: Color, metallic: float = 0.1) -> void:
 var part := MeshInstance3D.new()
 var shape := CylinderMesh.new()
 shape.top_radius = radius
 shape.bottom_radius = radius
 shape.height = height
 part.mesh = shape
 part.position = at
 part.material_override = MaterialLibrary.make(&"metal" if metallic > 0.3 else &"plaster", tint, 0.55 if metallic > 0.3 else 0.8, metallic)
 part.add_to_group("visual_polish")
 parent.add_child(part)

static func tree(parent: Node3D, at: Vector3) -> void:
 pole(parent, at + Vector3(0, 1.5, 0), 3.0, 0.2, Color("6a4f3a"), 0.05)
 ellipsoid(parent, at + Vector3(0, 3.7, 0), Vector3(3.4, 3.1, 3.2), Color("3f6a4a"), 0.9, &"grass")
 ellipsoid(parent, at + Vector3(-0.85, 4.25, 0.4), Vector3(2.4, 2.5, 2.5), Color("527e54"), 0.88, &"grass")
 ellipsoid(parent, at + Vector3(0.9, 4.05, -0.35), Vector3(2.3, 2.1, 2.2), Color("466b49"), 0.9, &"grass")

static func planter(parent: Node3D, at: Vector3) -> void:
 surface(parent, at + Vector3(0, 0.34, 0), Vector3(1.15, 0.7, 1.15), Color("7a6c5d"), 0.9, 0.0, &"concrete")
 ellipsoid(parent, at + Vector3(0, 1.05, 0), Vector3(1.1, 1.05, 1.1), Color("3f6a45"), 0.92, &"grass")

static func lamp_post(parent: Node3D, at: Vector3) -> void:
 pole(parent, at + Vector3(0, 2.4, 0), 4.8, 0.07, Color("3d4a52"), 0.7)
 surface(parent, at + Vector3(0.55, 4.7, 0), Vector3(1.15, 0.08, 0.1), Color("3d4a52"), 0.5, 0.7, &"metal")
 surface(parent, at + Vector3(1.05, 4.58, 0), Vector3(0.55, 0.14, 0.42), Color("f4e2b0"), 0.25, 0.05, &"plaster")
 var glow := OmniLight3D.new()
 glow.light_color = Color("ffd9a0")
 glow.light_energy = 0.35
 glow.omni_range = 8.0
 glow.shadow_enabled = false
 glow.position = at + Vector3(1.05, 4.45, 0)
 glow.add_to_group("visual_polish")
 parent.add_child(glow)

static func decorate_neighborhood(parent: Node3D, locations: Array[Dictionary]) -> void:
 # Full-block textured ground overlays — keep gameplay collisions on original meshes.
 surface(parent, Vector3(0, 0.008, 0), Vector3(248, 0.01, 248), Color("5a624f"), 0.95, 0.0, &"soil")
 surface(parent, Vector3(0, 0.018, 0), Vector3(13.5, 0.012, 246), Color("1f2226"), 0.94, 0.0, &"asphalt")
 surface(parent, Vector3(0, 0.02, 0), Vector3(246, 0.012, 13.5), Color("1f2226"), 0.94, 0.0, &"asphalt")
 for side in [-1.0, 1.0]:
  surface(parent, Vector3(side * 10.0, 0.026, 0), Vector3(5.2, 0.014, 246), Color("a8a294"), 0.9, 0.0, &"concrete")
  surface(parent, Vector3(0, 0.026, side * 10.0), Vector3(246, 0.014, 5.2), Color("a8a294"), 0.9, 0.0, &"concrete")
 for crossing in [-10.9, 10.9]:
  for index in range(-4, 5):
   surface(parent, Vector3(float(index) * 1.25, 0.034, crossing), Vector3(0.74, 0.012, 1.35), Color("e8e2d2"), 0.88, 0.0, &"concrete")
   surface(parent, Vector3(crossing, 0.034, float(index) * 1.25), Vector3(1.35, 0.012, 0.74), Color("e8e2d2"), 0.88, 0.0, &"concrete")
 for distance in range(-114, 115, 12):
  for sidewalk in [-10.0, 10.0]:
   surface(parent, Vector3(sidewalk, 0.032, distance), Vector3(4.9, 0.01, 0.04), Color("9a9b94"), 0.92, 0.0, &"concrete")
   surface(parent, Vector3(distance, 0.032, sidewalk), Vector3(0.04, 0.01, 4.9), Color("9a9b94"), 0.92, 0.0, &"concrete")
 # Center line dashes on both axes.
 for offset in range(-110, 115, 10):
  if abs(offset) > 14:
   surface(parent, Vector3(0, 0.03, offset), Vector3(0.28, 0.01, 3.6), Color("e6d79a"), 0.7, 0.0, &"concrete")
   surface(parent, Vector3(offset, 0.03, 0), Vector3(3.6, 0.01, 0.28), Color("e6d79a"), 0.7, 0.0, &"concrete")
 for location in locations:
  var at: Vector3 = location["at"]
  var id: StringName = location["id"]
  if id == &"park":
   decorate_park(parent, at)
  elif id == &"gym":
   decorate_gym(parent, at)
  else:
   decorate_facade(parent, at, id)
   tree(parent, at + Vector3(-15.5, 0, 3.0))
   tree(parent, at + Vector3(15.0, 0, -8.0))
   planter(parent, at + Vector3(13.2, 0, 10.5))
   planter(parent, at + Vector3(-13.0, 0, 11.0))
 for x in [-17.0, 17.0, -55.0, 55.0]:
  for z in [-65.0, 65.0, -110.0, 110.0]:
   lamp_post(parent, Vector3(x, 0, z))
 # Distant filler blocks get brick skins so the district reads denser.
 for x in [-100.0, -67.0, 67.0, 100.0]:
  for z in [-94.0, 92.0]:
   surface(parent, Vector3(x, 4.1, z + 8.1), Vector3(17.5, 7.8, 0.12), Color("9b6a55"), 0.86, 0.0, &"brick")
   for wy in [2.5, 5.5]:
    for wx in [-5.0, 0.0, 5.0]:
     surface(parent, Vector3(x + wx, wy, z + 8.2), Vector3(2.4, 1.6, 0.08), Color("6f8b93"), 0.18, 0.15, &"glass")

static func decorate_facade(parent: Node3D, at: Vector3, id: StringName) -> void:
 var plaster := Color("cfc4b4")
 var accent := Color("7a6d5c")
 if id == &"cafe":
  plaster = Color("d2c0a8")
  accent = Color("8a5a3c")
 elif id == &"studio":
  plaster = Color("b0bac0")
  accent = Color("4d5c66")
 elif id == &"market":
  plaster = Color("c8c7b2")
  accent = Color("5f7358")
 elif id == &"apartment":
  plaster = Color("d0b9a4")
  accent = Color("6e7f7d")
 surface(parent, at + Vector3(0, 5, 10.16), Vector3(21.8, 9.8, 0.08), plaster, 0.88, 0.0, &"plaster")
 surface(parent, at + Vector3(0, 5, -10.16), Vector3(21.8, 9.8, 0.08), plaster, 0.9, 0.0, &"plaster")
 for side in [-1.0, 1.0]:
  surface(parent, at + Vector3(side * 11.05, 5, 0), Vector3(0.08, 9.8, 20.2), plaster, 0.9, 0.0, &"plaster")
 surface(parent, at + Vector3(0, 10.55, 0), Vector3(22.6, 0.35, 21.0), Color("5c6568"), 0.7, 0.15, &"metal")
 surface(parent, at + Vector3(0, 3.55, 10.24), Vector3(22, 0.3, 0.22), accent, 0.7, 0.05, &"concrete")
 for floor_y in [5.2, 8.15]:
  for window_x in [-7.5, -2.5, 2.5, 7.5]:
   surface(parent, at + Vector3(window_x, floor_y, 10.28), Vector3(2.95, 2.05, 0.1), Color("41484a"), 0.4, 0.35, &"metal")
   surface(parent, at + Vector3(window_x, floor_y, 10.34), Vector3(2.55, 1.7, 0.06), Color("7ea0aa"), 0.12, 0.2, &"glass")
 for x in [-6.5, 6.5]:
  surface(parent, at + Vector3(x, 1.85, 10.3), Vector3(4.8, 2.75, 0.1), Color("2f4147"), 0.35, 0.45, &"metal")
  surface(parent, at + Vector3(x, 1.85, 10.38), Vector3(4.35, 2.35, 0.06), Color("8fb0b4"), 0.14, 0.12, &"glass")
 surface(parent, at + Vector3(0, 1.75, 10.32), Vector3(2.55, 3.3, 0.14), Color("2c3c40"), 0.35, 0.55, &"metal")
 surface(parent, at + Vector3(0, 1.75, 10.42), Vector3(1.95, 2.75, 0.06), Color("6f939b"), 0.16, 0.12, &"glass")
 surface(parent, at + Vector3(0.85, 1.55, 10.48), Vector3(0.07, 0.32, 0.07), Color("d0ae74"), 0.35, 0.65, &"metal")
 surface(parent, at + Vector3(0, 3.9, 11.05), Vector3(9.2, 0.18, 1.8), accent, 0.65, 0.05, &"concrete")
 var nameplate := Blockout.sign_text(parent, at + Vector3(0, 4.4, 10.5), String(id).to_upper(), 26)
 nameplate.modulate = Color("f7efe3")
 # Entry plaza mat.
 surface(parent, at + Vector3(0, 0.04, 12.2), Vector3(8.0, 0.02, 4.5), Color("b7b1a2"), 0.9, 0.0, &"concrete")

static func decorate_park(parent: Node3D, at: Vector3) -> void:
 surface(parent, at + Vector3(0, 0.05, 0), Vector3(28, 0.02, 28), Color("5f8454"), 0.94, 0.0, &"grass")
 surface(parent, at + Vector3(0, 0.06, 2.0), Vector3(4.5, 0.015, 16), Color("c2b79f"), 0.88, 0.0, &"concrete")
 for x in [-9.0, 9.0, -3.0, 3.0]:
  tree(parent, at + Vector3(x, 0.0, -5.0))
 for x in [-6.5, 6.5]:
  surface(parent, at + Vector3(x, 0.55, 6.5), Vector3(3.1, 0.16, 0.7), Color("8d6a4d"), 0.78, 0.0, &"wood")
  for leg in [-1.0, 1.0]:
   surface(parent, at + Vector3(x + leg, 0.28, 6.5), Vector3(0.14, 0.55, 0.55), Color("4f5858"), 0.4, 0.5, &"metal")
 ellipsoid(parent, at + Vector3(0, 0.35, -8), Vector3(3.5, 0.5, 3.5), Color("6f8f5c"), 0.95, &"grass")

static func decorate_gym(parent: Node3D, at: Vector3) -> void:
 surface(parent, at + Vector3(0, 0.05, 0), Vector3(28, 0.02, 28), Color("7f8982"), 0.94, 0.0, &"concrete")
 for x in [-6.0, 6.0]:
  surface(parent, at + Vector3(x, 0.07, 0), Vector3(0.12, 0.02, 18), Color("e5e8e1"), 0.9, 0.0, &"concrete")
 for z in [-9.0, 9.0]:
  surface(parent, at + Vector3(0, 0.07, z), Vector3(12, 0.02, 0.12), Color("e5e8e1"), 0.9, 0.0, &"concrete")
 surface(parent, at + Vector3(0, 1.2, -5), Vector3(8, 0.15, 0.15), Color("3d4c52"), 0.4, 0.65, &"metal")
 for x in [-3.0, 0.0, 3.0]:
  pole(parent, at + Vector3(x, 1.0, -5), 2.0, 0.05, Color("3d4c52"), 0.7)
 for x in [-11.5, 11.5]:
  planter(parent, at + Vector3(x, 0, 9.8))

static func decorate_interior(parent: Node3D, location_id: StringName) -> void:
 surface(parent, Vector3(0, 0.02, 0), Vector3(17.7, 0.025, 15.7), Color("a88868"), 0.78, 0.0, &"wood")
 for z in range(-7, 8, 2):
  surface(parent, Vector3(0, 0.035, float(z)), Vector3(17.5, 0.01, 0.03), Color("7a6a55"), 0.85, 0.0, &"wood")
 for x in [-7.3, 7.3]:
  surface(parent, Vector3(x, 2.15, -7.72), Vector3(1.25, 1.65, 0.05), Color("c5d4cc"), 0.25, 0.1, &"glass")
 var light := OmniLight3D.new()
 light.light_color = Color("ffe6c2")
 light.light_energy = 0.85
 light.omni_range = 11
 light.shadow_enabled = false
 light.position = Vector3(0, 3.4, 0)
 light.add_to_group("visual_polish")
 parent.add_child(light)
 var fill := OmniLight3D.new()
 fill.light_color = Color("d9e7f2")
 fill.light_energy = 0.25
 fill.omni_range = 10
 fill.shadow_enabled = false
 fill.position = Vector3(0, 2.8, 3.5)
 fill.add_to_group("visual_polish")
 parent.add_child(fill)
 match location_id:
  &"apartment":
   surface(parent, Vector3(-5, 0.55, -4), Vector3(3.6, 0.35, 2.3), Color("b8aea4"), 0.86, 0.0, &"plaster")
   surface(parent, Vector3(-5, 0.9, -4.95), Vector3(3.7, 0.7, 0.5), Color("5f7776"), 0.9, 0.0, &"plaster")
   surface(parent, Vector3(5, 0.9, -5), Vector3(3.8, 1.5, 1.4), Color("8f7d62"), 0.8, 0.0, &"wood")
   surface(parent, Vector3(1.4, 0.04, -0.8), Vector3(3.4, 0.015, 4.8), Color("6f6558"), 0.92, 0.0, &"wood")
   for x in [3.3, 6.3]:
    surface(parent, Vector3(x, 1.15, -7.55), Vector3(2.3, 2.05, 0.7), Color("6f6456"), 0.78, 0.0, &"wood")
  &"cafe":
   surface(parent, Vector3(0, 2.05, -5), Vector3(12, 0.14, 1.8), Color("b79a78"), 0.55, 0.0, &"wood")
   for x in [-5.0, 5.0]:
    surface(parent, Vector3(x, 1.35, 0), Vector3(2.2, 0.12, 2.2), Color("8a6d50"), 0.65, 0.0, &"wood")
    pole(parent, Vector3(x, 0.7, 0), 1.3, 0.11, Color("4a5150"), 0.45)
   for x in [-6.6, 6.6]:
    planter(parent, Vector3(x, 0, -5.8))
  &"market":
   surface(parent, Vector3(0, 1.2, -4), Vector3(10.5, 0.2, 2.2), Color("7f8f72"), 0.75, 0.0, &"metal")
   for x in [-4.0, 0.0, 4.0]:
    surface(parent, Vector3(x, 0.85, 1.2), Vector3(2.4, 1.5, 1.6), Color("c2a87c"), 0.8, 0.0, &"wood")
  &"studio":
   surface(parent, Vector3(0, 1.3, -4), Vector3(8.5, 0.2, 3.2), Color("5f6a7c"), 0.55, 0.25, &"metal")
   surface(parent, Vector3(-3.5, 0.85, 1), Vector3(2.8, 1.4, 2.4), Color("3b414c"), 0.45, 0.4, &"metal")
   surface(parent, Vector3(3.2, 0.9, 0.8), Vector3(2.2, 1.2, 1.8), Color("d0c3a8"), 0.7, 0.0, &"wood")
  _:
   pass

static func decorate_avatar(visual: Node3D) -> void:
 # Preserve smoke-test nodes; hide capsule placeholders and attach animated rig.
 visual.get_node("Body").visible = false
 visual.get_node("Face").visible = false
 var existing := visual.get_node_or_null("AvatarRig")
 if existing:
  existing.queue_free()
 var rig := AvatarAnimator.new()
 rig.name = "AvatarRig"
 visual.add_child(rig)
 rig.build()

static func apply_world_atmosphere(world: Node3D) -> void:
 var env_node: WorldEnvironment = world.get_node_or_null("WorldEnvironment")
 if env_node == null or env_node.environment == null:
  return
 var environment := env_node.environment
 # Prefer features that survive OpenGL Compatibility fallback in VMs.
 environment.ssao_enabled = true
 environment.ssil_enabled = false
 environment.glow_enabled = true
 environment.glow_intensity = 0.22
 environment.fog_enabled = true
 environment.fog_light_color = Color(0.75, 0.8, 0.86)
 environment.fog_density = 0.0009
 environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
 environment.tonemap_exposure = 1.05
 environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
 environment.ambient_light_energy = 0.72
 environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
 var sky_mat := ProceduralSkyMaterial.new()
 sky_mat.sky_top_color = Color(0.23, 0.45, 0.72)
 sky_mat.sky_horizon_color = Color(0.82, 0.78, 0.72)
 sky_mat.ground_bottom_color = Color(0.28, 0.3, 0.28)
 sky_mat.ground_horizon_color = Color(0.7, 0.72, 0.68)
 sky_mat.sun_angle_max = 35.0
 var sky := Sky.new()
 sky.sky_material = sky_mat
 environment.background_mode = Environment.BG_SKY
 environment.sky = sky
 var sun: DirectionalLight3D = world.get_node_or_null("Sun")
 if sun:
  sun.light_color = Color(1.0, 0.93, 0.82)
  sun.light_energy = 1.35
  sun.shadow_enabled = true
  sun.shadow_blur = 1.2
  sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
 # Soft fill so shaded sides of buildings stay readable.
 if world.get_node_or_null("FillLight") == null:
  var fill := DirectionalLight3D.new()
  fill.name = "FillLight"
  fill.rotation_degrees = Vector3(-25, 140, 0)
  fill.light_color = Color(0.65, 0.75, 0.9)
  fill.light_energy = 0.35
  fill.shadow_enabled = false
  world.add_child(fill)
