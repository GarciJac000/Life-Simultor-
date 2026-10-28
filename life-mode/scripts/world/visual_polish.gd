class_name VisualPolish
extends RefCounted

# Graphics-only additions. All decorative objects have NO collision shapes.
# Milestone 0 physics, portals, and interaction distances remain unchanged.

static func surface(parent: Node3D, at: Vector3, size: Vector3, tint: Color, roughness: float = 0.76, metallic: float = 0.0) -> MeshInstance3D:
 var part := Blockout.box(parent, at, size, tint, false)
 var finish := StandardMaterial3D.new()
 finish.albedo_color = tint
 finish.roughness = roughness
 finish.metallic = metallic
 part.material_override = finish
 if size.y < 0.05:
  part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 return part

static func ellipsoid(parent: Node3D, at: Vector3, dimensions: Vector3, tint: Color, roughness: float = 0.87) -> void:
 var part := MeshInstance3D.new()
 var shape := SphereMesh.new()
 shape.radius = 0.5
 shape.height = 1.0
 part.mesh = shape
 part.position = at
 part.scale = dimensions
 var finish := StandardMaterial3D.new()
 finish.albedo_color = tint
 finish.roughness = roughness
 part.material_override = finish
 parent.add_child(part)

static func pole(parent: Node3D, at: Vector3, height: float, radius: float, tint: Color, metallic: float = 0.1) -> void:
 var part := MeshInstance3D.new()
 var shape := CylinderMesh.new()
 shape.top_radius = radius
 shape.bottom_radius = radius
 shape.height = height
 part.mesh = shape
 part.position = at
 var finish := StandardMaterial3D.new()
 finish.albedo_color = tint
 finish.roughness = 0.62
 finish.metallic = metallic
 part.material_override = finish
 parent.add_child(part)

static func tree(parent: Node3D, at: Vector3) -> void:
 pole(parent, at + Vector3(0, 1.4, 0), 2.8, 0.18, Color("735a45"))
 ellipsoid(parent, at + Vector3(0, 3.45, 0), Vector3(3.2, 3.0, 3.0), Color("4b7657"))
 ellipsoid(parent, at + Vector3(-0.7, 4.0, 0.35), Vector3(2.3, 2.4, 2.5), Color("638d63"))
 ellipsoid(parent, at + Vector3(0.8, 3.85, -0.3), Vector3(2.2, 2.0, 2.0), Color("527e54"))

static func planter(parent: Node3D, at: Vector3) -> void:
 surface(parent, at + Vector3(0, 0.34, 0), Vector3(1.1, 0.68, 1.1), Color("7d7064"), 0.9)
 ellipsoid(parent, at + Vector3(0, 1.0, 0), Vector3(1.05, 1.05, 1.05), Color("4c7453"))

static func lamp_post(parent: Node3D, at: Vector3) -> void:
 pole(parent, at + Vector3(0, 2.25, 0), 4.5, 0.075, Color("45535b"), 0.65)
 surface(parent, at + Vector3(0.5, 4.45, 0), Vector3(1.0, 0.08, 0.1), Color("45535b"), 0.58, 0.65)
 surface(parent, at + Vector3(1.0, 4.35, 0), Vector3(0.55, 0.12, 0.4), Color("f2dfb2"), 0.28)
 # A visual fixture only. No expensive per-post dynamic light in daytime.

static func decorate_neighborhood(parent: Node3D, locations: Array[Dictionary]) -> void:
 # Physical street surfaces remain from Milestone 0; these are decals/details only.
 for crossing in [-10.9, 10.9]:
  for index in range(-4, 5):
   surface(parent, Vector3(float(index) * 1.25, 0.053, crossing), Vector3(0.74, 0.015, 1.35), Color("ddd9cb"), 0.96)
   surface(parent, Vector3(crossing, 0.053, float(index) * 1.25), Vector3(1.35, 0.015, 0.74), Color("ddd9cb"), 0.96)
 for distance in range(-114, 115, 12):
  for sidewalk in [-10.0, 10.0]:
   surface(parent, Vector3(sidewalk, 0.039, distance), Vector3(4.9, 0.012, 0.035), Color("a2a49e"), 0.95)
   surface(parent, Vector3(distance, 0.039, sidewalk), Vector3(0.035, 0.012, 4.9), Color("a2a49e"), 0.95)
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
   planter(parent, at + Vector3(13.2, 0, 10.5))
 for x in [-17.0, 17.0]:
  for z in [-65.0, 65.0]:
   lamp_post(parent, Vector3(x, 0, z))

static func decorate_facade(parent: Node3D, at: Vector3, id: StringName) -> void:
 var plaster := Color("c5bbac")
 if id == &"cafe":
  plaster = Color("c8b7a0")
 elif id == &"studio":
  plaster = Color("a6b0b5")
 elif id == &"market":
  plaster = Color("c1c0ae")
 # Shallow exterior shell and trim on top of the existing solid building.
 surface(parent, at + Vector3(0, 5, 10.16), Vector3(21.75, 9.7, 0.07), plaster, 0.9)
 surface(parent, at + Vector3(0, 3.55, 10.24), Vector3(22, 0.28, 0.2), Color("777a74"), 0.68)
 surface(parent, at + Vector3(0, 10.65, 10.2), Vector3(22.5, 0.5, 0.5), Color("68665f"), 0.78)
 for floor_y in [5.25, 8.25]:
  for window_x in [-7.5, -2.5, 2.5, 7.5]:
   surface(parent, at + Vector3(window_x, floor_y, 10.27), Vector3(2.95, 2.0, 0.1), Color("4e5657"), 0.45, 0.45)
   surface(parent, at + Vector3(window_x, floor_y, 10.33), Vector3(2.55, 1.7, 0.055), Color("54717e"), 0.16, 0.12)
   surface(parent, at + Vector3(window_x, floor_y, 10.38), Vector3(0.055, 1.68, 0.06), Color("d3d0c6"), 0.52, 0.45)
   surface(parent, at + Vector3(window_x, floor_y - 0.1, 10.38), Vector3(2.55, 0.06, 0.06), Color("d3d0c6"), 0.52, 0.45)
 # Ground level storefront glazing and sheltered central entry.
 for x in [-6.5, 6.5]:
  surface(parent, at + Vector3(x, 1.85, 10.29), Vector3(4.8, 2.7, 0.09), Color("354a50"), 0.36, 0.4)
  surface(parent, at + Vector3(x, 1.85, 10.36), Vector3(4.4, 2.35, 0.06), Color("718f92"), 0.17, 0.1)
  surface(parent, at + Vector3(x, 1.85, 10.42), Vector3(0.065, 2.35, 0.06), Color("d6d4cd"), 0.5, 0.5)
 surface(parent, at + Vector3(0, 1.75, 10.31), Vector3(2.5, 3.25, 0.13), Color("334447"), 0.32, 0.6)
 surface(parent, at + Vector3(0, 1.75, 10.4), Vector3(1.9, 2.7, 0.06), Color("587781"), 0.18, 0.1)
 surface(parent, at + Vector3(0.8, 1.55, 10.46), Vector3(0.06, 0.3, 0.06), Color("c6a872"), 0.38, 0.7)
 surface(parent, at + Vector3(0, 3.85, 11.0), Vector3(9, 0.16, 1.7), Color("455e61"), 0.65)
 var nameplate := Blockout.sign_text(parent, at + Vector3(0, 4.35, 10.42), String(id).to_upper(), 25)
 nameplate.modulate = Color("f4ebdc")

static func decorate_park(parent: Node3D, at: Vector3) -> void:
 surface(parent, at + Vector3(0, 0.065, 0), Vector3(27, 0.016, 27), Color("75926b"), 0.94)
 for x in [-9.0, 9.0]:
  tree(parent, at + Vector3(x, 0.0, -4.0))
 for x in [-6.5, 6.5]:
  surface(parent, at + Vector3(x, 0.53, 6.5), Vector3(3, 0.16, 0.65), Color("9b775a"), 0.8)
  for leg in [-1.0, 1.0]:
   surface(parent, at + Vector3(x + leg, 0.27, 6.5), Vector3(0.14, 0.53, 0.55), Color("5d6464"), 0.4, 0.5)

static func decorate_gym(parent: Node3D, at: Vector3) -> void:
 surface(parent, at + Vector3(0, 0.07, 0), Vector3(27, 0.018, 27), Color("87918a"), 0.96)
 for x in [-6.0, 6.0]:
  surface(parent, at + Vector3(x, 0.085, 0), Vector3(0.1, 0.018, 18), Color("d5d9d2"), 0.95)
 for z in [-9.0, 9.0]:
  surface(parent, at + Vector3(0, 0.085, z), Vector3(12, 0.018, 0.1), Color("d5d9d2"), 0.95)
 for x in [-11.5, 11.5]:
  planter(parent, at + Vector3(x, 0, 9.8))

static func decorate_interior(parent: Node3D, location_id: StringName) -> void:
 # All details are pass-through; leave the central portal route entirely usable.
 surface(parent, Vector3(0, 0.022, 0), Vector3(17.7, 0.024, 15.7), Color("a58c70"), 0.77)
 for z in range(-7, 8, 2):
  surface(parent, Vector3(0, 0.039, float(z)), Vector3(17.5, 0.01, 0.026), Color("796f62"), 0.86)
 for x in [-7.3, 7.3]:
  surface(parent, Vector3(x, 2.1, -7.72), Vector3(1.2, 1.6, 0.05), Color("b8c6bf"), 0.34)
 var light := OmniLight3D.new()
 light.light_color = Color("fff1d6")
 light.light_energy = 0.45
 light.omni_range = 9
 light.shadow_enabled = false
 light.position = Vector3(0, 3.45, 0)
 parent.add_child(light)
 if location_id == &"apartment":
  surface(parent, Vector3(-5, 0.62, -4), Vector3(3.5, 0.3, 2.2), Color("b0a8a0"), 0.86)
  surface(parent, Vector3(-5, 0.92, -4.9), Vector3(3.6, 0.65, 0.45), Color("6c8382"), 0.92)
  surface(parent, Vector3(1.4, 0.044, -0.8), Vector3(3.3, 0.014, 4.8), Color("776e60"), 0.95)
  for x in [3.3, 6.3]:
   surface(parent, Vector3(x, 1.1, -7.55), Vector3(2.3, 2.0, 0.7), Color("746858"), 0.76)
 else:
  surface(parent, Vector3(0, 2.07, -5), Vector3(12, 0.12, 1.7), Color("b49b7a"), 0.57)
  for x in [-5.0, 5.0]:
   surface(parent, Vector3(x, 1.4, 0), Vector3(2.2, 0.12, 2.2), Color("8d6f53"), 0.65)
   pole(parent, Vector3(x, 0.7, 0), 1.3, 0.12, Color("4d5352"), 0.5)
  for x in [-6.6, 6.6]:
   planter(parent, Vector3(x, 0, -5.8))

static func decorate_avatar(visual: Node3D) -> void:
 # Preserve the test's Visual/Body node; hide its capsule-shaped placeholder.
 visual.get_node("Body").visible = false
 visual.get_node("Face").visible = false
 var jacket := Color("314b55")
 var denim := Color("303e54")
 var skin := Color("bc8c6e")
 surface(visual, Vector3(0, 1.22, 0), Vector3(0.49, 0.65, 0.31), jacket, 0.9)
 surface(visual, Vector3(0, 0.8, 0), Vector3(0.36, 0.18, 0.25), Color("252b33"), 0.87)
 for side in [-1.0, 1.0]:
  var x := float(side)
  pole(visual, Vector3(x * 0.35, 1.14, 0), 0.58, 0.125, jacket)
  ellipsoid(visual, Vector3(x * 0.36, 0.76, 0), Vector3(0.21, 0.22, 0.2), skin)
  surface(visual, Vector3(x * 0.12, 0.47, 0), Vector3(0.21, 0.63, 0.22), denim, 0.94)
  surface(visual, Vector3(x * 0.12, 0.13, -0.065), Vector3(0.24, 0.19, 0.39), Color("d1c9b9"), 0.88)
 ellipsoid(visual, Vector3(0, 1.72, -0.01), Vector3(0.37, 0.43, 0.34), skin)
 ellipsoid(visual, Vector3(0, 1.9, 0.02), Vector3(0.37, 0.14, 0.33), Color("262725"))
