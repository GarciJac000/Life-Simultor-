extends Node3D

const NeighborhoodScene := preload("res://scenes/world/neighborhood.tscn")
const INTERIOR_SCENES := {
 &"apartment": preload("res://scenes/world/interiors/apartment.tscn"),
 &"cafe": preload("res://scenes/world/interiors/cafe.tscn"),
 &"market": preload("res://scenes/world/interiors/market.tscn"),
 &"studio": preload("res://scenes/world/interiors/studio.tscn")
}
@onready var player: PlayerController = $Player
@onready var hud: CanvasLayer = $HUD
var neighborhood: Node3D
var interiors: Dictionary = {}
var current_location: StringName = &"outside"
var visited: Dictionary = {}

func _ready() -> void:
 GameState.start_new_game()
 SimulationSystem.realtime_enabled = true
 neighborhood = NeighborhoodScene.instantiate()
 add_child(neighborhood)
 var slot := 0
 for id in INTERIOR_SCENES.keys():
  var room: Node3D = INTERIOR_SCENES[id].instantiate()
  room.position = Vector3(400 + slot * 100, 0, 0)
  add_child(room)
  room.visible = false
  interiors[id] = room
  slot += 1
 for marker in get_tree().get_nodes_in_group("interactables"):
  if not marker.activated.is_connected(_on_interaction):
   marker.activated.connect(_on_interaction)
 player.focus_changed.connect(hud.set_focus)
 hud.attach(self)
 # Start at the apartment threshold facing the entrance.
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
  hud.toast(String(current_location).capitalize() + " / find stations inside, or the exit marker.")
 elif not target.action_id.is_empty():
  hud.offer_action(target.action_id, current_location if current_location != &"outside" else target.location_id)
 else:
  hud.toast(target.display_name + " / no activity here yet.")
 hud.refresh_location()
