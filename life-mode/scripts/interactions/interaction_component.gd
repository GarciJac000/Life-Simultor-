class_name InteractionComponent
extends Node3D

signal activated(target: InteractionComponent)
@export var location_id: StringName
@export var display_name: String = "Location"
@export var action_text: String = "Inspect"
@export var destination: StringName
var highlight: MeshInstance3D
var focus_material: StandardMaterial3D
var activation_count: int = 0

func _ready() -> void:
 add_to_group("interactables")
 highlight = MeshInstance3D.new()
 var ring := TorusMesh.new()
 ring.inner_radius = 0.42
 ring.outer_radius = 0.55
 highlight.mesh = ring
 highlight.position.y = 0.08
 focus_material = Blockout.material(Color("c8c4ac"))
 highlight.material_override = focus_material
 add_child(highlight)
 var sign_label := Blockout.sign_text(self, Vector3(0, 2.6, 0), "EXIT / STREET" if location_id == &"exit" else display_name, 36)
 sign_label.visibility_range_end = 60.0
 if location_id == &"exit":
  sign_label.pixel_size = 0.006

func set_focused(value: bool) -> void:
 focus_material.albedo_color = Color("f5cc70") if value else Color("c8c4ac")
 focus_material.emission_enabled = value
 focus_material.emission = Color("ad742d") if value else Color.BLACK
 highlight.scale = Vector3.ONE * (1.2 if value else 1.0)

func activate() -> void:
 activation_count += 1
 activated.emit(self)
