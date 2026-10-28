class_name PlayerController
extends CharacterBody3D

signal focus_changed(target: InteractionComponent)
const WALK_SPEED: float = 5.0
const SPRINT_SPEED: float = 9.0
const INTERACTION_RANGE: float = 2.5
@export_range(0.0005, 0.01) var mouse_sensitivity: float = 0.0025
@onready var pivot: Node3D = $CameraPivot
@onready var arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var visual: Node3D = $Visual
var focused: InteractionComponent
var gravity: float = 20.0

func _ready() -> void:
 arm.add_excluded_object(get_rid())
 Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
  orbit(event.relative)
 if event.is_action_pressed("interact") and not event.is_echo():
  # Revalidate on activation, including geometry; a stale HUD prompt cannot trigger a portal.
  update_focus()
  if is_instance_valid(focused):
   focused.activate()
  get_viewport().set_input_as_handled()

func orbit(relative: Vector2) -> void:
 pivot.rotation.y -= relative.x * mouse_sensitivity
 arm.rotation.x = clampf(arm.rotation.x - relative.y * mouse_sensitivity, -0.85, 0.45)

func _physics_process(delta: float) -> void:
 # Obstructions retract immediately; ease the arm outward after they clear.
 var hit_length := arm.get_hit_length()
 arm.spring_length = move_toward(hit_length, 5.5, 12.0 * delta) if hit_length > 0 else 5.5
 var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
 var direction := pivot.global_basis * Vector3(input.x, 0, input.y)
 direction.y = 0
 direction = direction.normalized()
 var speed := SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED
 velocity.x = direction.x * speed
 velocity.z = direction.z * speed
 if not is_on_floor():
  velocity.y -= gravity * delta
 else:
  velocity.y = 0
 move_and_slide()
 if direction.length_squared() > 0.01:
  visual.rotation.y = lerp_angle(visual.rotation.y, atan2(-direction.x, -direction.z), 12.0 * delta)
 update_focus()

func update_focus() -> void:
 var closest: InteractionComponent = null
 var best_distance: float = INTERACTION_RANGE
 var forward := -pivot.global_basis.z
 forward.y = 0
 forward = forward.normalized()
 for node in get_tree().get_nodes_in_group("interactables"):
  var target := node as InteractionComponent
  var offset := target.global_position - global_position
  offset.y = 0
  var distance := offset.length()
  if distance > best_distance or (distance > 0.15 and forward.dot(offset.normalized()) < 0.45):
   continue
  var query := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP, target.global_position + Vector3.UP)
  query.exclude = [get_rid()]
  if not get_world_3d().direct_space_state.intersect_ray(query).is_empty():
   continue
  closest = target
  best_distance = distance
 if closest != focused:
  if is_instance_valid(focused):
   focused.set_focused(false)
  focused = closest
  if is_instance_valid(focused):
   focused.set_focused(true)
  focus_changed.emit(focused)

func teleport(at: Vector3, yaw: float = 0.0) -> void:
 if is_instance_valid(focused):
  focused.set_focused(false)
 focused = null
 focus_changed.emit(null)
 global_position = at
 velocity = Vector3.ZERO
 pivot.rotation.y = yaw
 visual.rotation.y = yaw
 arm.rotation.x = -0.28
 arm.spring_length = 5.5
 reset_physics_interpolation()
