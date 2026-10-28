class_name Blockout
extends RefCounted

static func material(color: Color) -> StandardMaterial3D:
 var result := StandardMaterial3D.new()
 result.albedo_color = color
 result.roughness = 0.92
 return result

static func box(parent: Node3D, at: Vector3, size: Vector3, color: Color, solid: bool = true) -> MeshInstance3D:
 var mesh := MeshInstance3D.new()
 var shape := BoxMesh.new()
 shape.size = size
 mesh.mesh = shape
 mesh.material_override = material(color)
 mesh.position = at
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
 parent.add_child(label)
 return label
