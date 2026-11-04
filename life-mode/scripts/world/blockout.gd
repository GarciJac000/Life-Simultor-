class_name Blockout
extends RefCounted

static func material(color: Color, kind: StringName = &"plaster") -> StandardMaterial3D:
 # Route all blockout surfaces through the procedural material library so
 # Forward+ and Compatibility both get visible textured albedo (avoids washed voids).
 var roughness := 0.88
 var metallic := 0.0
 if kind == &"asphalt":
  roughness = 0.92
 elif kind == &"metal":
  roughness = 0.45
  metallic = 0.55
 elif kind == &"glass":
  roughness = 0.1
  metallic = 0.2
 return MaterialLibrary.make(kind, color, roughness, metallic)

static func box(parent: Node3D, at: Vector3, size: Vector3, color: Color, solid: bool = true, kind: StringName = &"plaster") -> MeshInstance3D:
 var mesh := MeshInstance3D.new()
 var shape := BoxMesh.new()
 shape.size = size
 mesh.mesh = shape
 mesh.material_override = material(color, kind)
 mesh.position = at
 mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 parent.add_child(mesh)
 if solid:
  var body := StaticBody3D.new()
  var collision := CollisionShape3D.new()
  var volume := BoxShape3D.new()
  volume.size = size
  collision.shape = volume
  body.add_child(collision)
  mesh.add_child(body)
 return mesh

static func sign_text(parent: Node3D, at: Vector3, text: String, size: int = 48) -> Label3D:
 var label := Label3D.new()
 label.text = text
 label.font_size = size
 label.pixel_size = 0.012
 label.position = at
 label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
 label.no_depth_test = false
 label.outline_size = 8
 label.modulate = Color("f4f1ea")
 label.outline_modulate = Color("1a2428")
 parent.add_child(label)
 return label
