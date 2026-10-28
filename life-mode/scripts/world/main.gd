extends Node3D

const NeighborhoodScene := preload("res://scenes/world/neighborhood.tscn")
const ApartmentScene := preload("res://scenes/world/interiors/apartment.tscn")
const CafeScene := preload("res://scenes/world/interiors/cafe.tscn")
@onready var player: PlayerController = $Player
@onready var hud: CanvasLayer = $HUD
var neighborhood: Node3D
var interiors: Dictionary = {}
var current_location: StringName = &"outside"
var visited: Dictionary = {}

func _ready() -> void:
 neighborhood = NeighborhoodScene.instantiate()
 add_child(neighborhood)
 for id in [&"apartment", &"cafe"]:
  var room: Node3D = (ApartmentScene if id == &"apartment" else CafeScene).instantiate()
  room.position = Vector3(400 if id == &"apartment" else 500, 0, 0)
  add_child(room)
  room.visible = false
  interiors[id] = room
 for marker in get_tree().get_nodes_in_group("interactables"):
  marker.activated.connect(_on_interaction)
 player.focus_changed.connect(hud.set_focus)
 hud.attach(self)
 # Start at the apartment threshold; the full simulation's intro is outside M0.
 player.teleport(Vector3(-34, 0.05, -17))

func _on_interaction(target: InteractionComponent) -> void:
 if target.location_id != &"exit":
  visited[target.location_id] = true
 if target.destination == &"outside":
  var previous := current_location
  interiors[previous].visible = false
  neighborhood.visible = true
  current_location = &"outside"
  player.teleport(neighborhood.markers[previous].global_position + Vector3(0, 0.05, 3))
  hud.toast("Back outside / " + String(previous).capitalize())
 elif not target.destination.is_empty():
  current_location = target.destination
  neighborhood.visible = false
  interiors[current_location].visible = true
  player.teleport(interiors[current_location].global_position + Vector3(0, 0.05, 3.5), PI)
  hud.toast(String(current_location).capitalize() + " / interior blockout. Find the exit marker.")
 else:
  hud.toast(target.display_name + " / discovered. Activities arrive in later milestones.")
 hud.refresh_location()
