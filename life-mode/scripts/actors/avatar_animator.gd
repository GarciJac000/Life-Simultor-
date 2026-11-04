class_name AvatarAnimator
extends Node3D
## Hierarchical stylized-realistic body with procedural idle/walk/run animation.

var hips: Node3D
var torso: Node3D
var head: Node3D
var thigh_l: Node3D
var thigh_r: Node3D
var calf_l: Node3D
var calf_r: Node3D
var arm_l: Node3D
var arm_r: Node3D
var forearm_l: Node3D
var forearm_r: Node3D
var phase: float = 0.0
var move_amount: float = 0.0
var sprinting: bool = false

func build(skin: Color = Color("c49a78"), jacket: Color = Color("2f4a55"), denim: Color = Color("2c3b52"), hair: Color = Color("1f1e1c")) -> void:
 for child in get_children():
  child.queue_free()
 hips = _joint(self, Vector3(0, 0.94, 0))
 torso = _joint(hips, Vector3(0, 0.3, 0))
 head = _joint(torso, Vector3(0, 0.46, 0))
 thigh_l = _joint(hips, Vector3(-0.12, -0.02, 0))
 thigh_r = _joint(hips, Vector3(0.12, -0.02, 0))
 calf_l = _joint(thigh_l, Vector3(0, -0.44, 0))
 calf_r = _joint(thigh_r, Vector3(0, -0.44, 0))
 arm_l = _joint(torso, Vector3(-0.3, 0.3, 0))
 arm_r = _joint(torso, Vector3(0.3, 0.3, 0))
 forearm_l = _joint(arm_l, Vector3(0, -0.34, 0))
 forearm_r = _joint(arm_r, Vector3(0, -0.34, 0))
 # Pelvis / torso volumes.
 _capsule(hips, Vector3(0, 0.02, 0), 0.16, 0.22, jacket, 0.88)
 _capsule(torso, Vector3(0, 0.05, 0.01), 0.19, 0.48, jacket, 0.84)
 _sphere(head, Vector3(0, 0.15, 0), Vector3(0.27, 0.31, 0.25), skin, 0.68)
 _sphere(head, Vector3(0, 0.28, 0.01), Vector3(0.29, 0.13, 0.27), hair, 0.9)
 _sphere(head, Vector3(0, 0.12, -0.12), Vector3(0.07, 0.06, 0.06), skin, 0.62)
 # Legs.
 _capsule(thigh_l, Vector3(0, -0.2, 0), 0.085, 0.4, denim, 0.92)
 _capsule(thigh_r, Vector3(0, -0.2, 0), 0.085, 0.4, denim, 0.92)
 _capsule(calf_l, Vector3(0, -0.2, 0), 0.075, 0.38, denim, 0.9)
 _capsule(calf_r, Vector3(0, -0.2, 0), 0.075, 0.38, denim, 0.9)
 _box(calf_l, Vector3(0, -0.4, 0.05), Vector3(0.17, 0.09, 0.28), Color("d9d2c4"), 0.84)
 _box(calf_r, Vector3(0, -0.4, 0.05), Vector3(0.17, 0.09, 0.28), Color("d9d2c4"), 0.84)
 # Arms.
 _capsule(arm_l, Vector3(0, -0.15, 0), 0.06, 0.3, jacket, 0.84)
 _capsule(arm_r, Vector3(0, -0.15, 0), 0.06, 0.3, jacket, 0.84)
 _capsule(forearm_l, Vector3(0, -0.15, 0), 0.05, 0.28, skin, 0.68)
 _capsule(forearm_r, Vector3(0, -0.15, 0), 0.05, 0.28, skin, 0.68)
 _sphere(forearm_l, Vector3(0, -0.3, 0), Vector3(0.09, 0.09, 0.09), skin, 0.65)
 _sphere(forearm_r, Vector3(0, -0.3, 0), Vector3(0.09, 0.09, 0.09), skin, 0.65)

func update_motion(horizontal_speed: float, is_sprinting: bool, delta: float) -> void:
 sprinting = is_sprinting
 var target := clampf(horizontal_speed / (9.0 if is_sprinting else 5.0), 0.0, 1.0)
 move_amount = move_toward(move_amount, target, delta * 6.0)
 var cadence := lerpf(1.5, 8.0 if is_sprinting else 5.4, move_amount)
 phase += delta * cadence
 var swing := sin(phase) * move_amount
 var swing_amt := lerpf(0.65, 1.05, move_amount)
 thigh_l.rotation.x = swing * swing_amt
 thigh_r.rotation.x = -swing * swing_amt
 calf_l.rotation.x = maxf(-swing, 0.0) * 0.85
 calf_r.rotation.x = maxf(swing, 0.0) * 0.85
 arm_l.rotation.x = -swing * 0.85
 arm_r.rotation.x = swing * 0.85
 arm_l.rotation.z = lerpf(0.12, 0.22, move_amount)
 arm_r.rotation.z = lerpf(-0.12, -0.22, move_amount)
 forearm_l.rotation.x = -0.3 - maxf(-swing, 0.0) * 0.4
 forearm_r.rotation.x = -0.3 - maxf(swing, 0.0) * 0.4
 torso.rotation.y = swing * 0.1
 torso.rotation.x = lerpf(0.0, -0.1 if is_sprinting else -0.04, move_amount)
 hips.position.y = 0.94 + absf(sin(phase * 2.0)) * 0.04 * move_amount
 if move_amount < 0.08:
  var breath := sin(Time.get_ticks_msec() * 0.0025) * 0.015
  torso.position.y = 0.3 + breath
  head.rotation.x = breath * 0.5
 else:
  torso.position.y = 0.3
  head.rotation.x = move_toward(head.rotation.x, 0.0, delta)

func reset_pose() -> void:
 phase = 0.0
 move_amount = 0.0
 if hips == null:
  return
 hips.position.y = 0.94
 torso.position.y = 0.3
 torso.rotation = Vector3.ZERO
 head.rotation = Vector3.ZERO
 for node in [thigh_l, thigh_r, calf_l, calf_r, arm_l, arm_r, forearm_l, forearm_r]:
  node.rotation = Vector3.ZERO

func _joint(parent: Node3D, at: Vector3) -> Node3D:
 var node := Node3D.new()
 node.position = at
 parent.add_child(node)
 return node

func _mat(tint: Color, roughness: float) -> StandardMaterial3D:
 var mat := StandardMaterial3D.new()
 mat.albedo_color = tint
 mat.roughness = roughness
 mat.metallic = 0.0
 return mat

func _capsule(parent: Node3D, at: Vector3, radius: float, height: float, tint: Color, roughness: float) -> void:
 var mesh := MeshInstance3D.new()
 var shape := CapsuleMesh.new()
 shape.radius = radius
 shape.height = height
 mesh.mesh = shape
 mesh.position = at
 mesh.material_override = _mat(tint, roughness)
 mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 mesh.add_to_group("visual_polish")
 parent.add_child(mesh)

func _box(parent: Node3D, at: Vector3, size: Vector3, tint: Color, roughness: float) -> void:
 var mesh := MeshInstance3D.new()
 var shape := BoxMesh.new()
 shape.size = size
 mesh.mesh = shape
 mesh.position = at
 mesh.material_override = _mat(tint, roughness)
 mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 mesh.add_to_group("visual_polish")
 parent.add_child(mesh)

func _sphere(parent: Node3D, at: Vector3, dimensions: Vector3, tint: Color, roughness: float) -> void:
 var mesh := MeshInstance3D.new()
 var sphere := SphereMesh.new()
 sphere.radius = 0.5
 sphere.height = 1.0
 mesh.mesh = sphere
 mesh.position = at
 mesh.scale = dimensions
 mesh.material_override = _mat(tint, roughness)
 mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 mesh.add_to_group("visual_polish")
 parent.add_child(mesh)
