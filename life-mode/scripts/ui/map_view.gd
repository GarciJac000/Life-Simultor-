extends Control

var world: Node3D
const MAP_SIZE := 360.0
const MAP_ORIGIN := Vector2(26, 18)

func _draw() -> void:
 var area := Rect2(MAP_ORIGIN, Vector2.ONE * MAP_SIZE)
 draw_rect(area, Color("a3afa0"))
 var center := MAP_ORIGIN + Vector2.ONE * MAP_SIZE / 2
 draw_rect(Rect2(Vector2(center.x - 10, MAP_ORIGIN.y), Vector2(20, MAP_SIZE)), Color("4e5d60"))
 draw_rect(Rect2(Vector2(MAP_ORIGIN.x, center.y - 10), Vector2(MAP_SIZE, 20)), Color("4e5d60"))
 draw_rect(area, Color("d4dbc9"), false, 2)
 if not is_instance_valid(world):
  return
 var font := ThemeDB.fallback_font
 for i in range(world.neighborhood.LOCATIONS.size()):
  var location: Dictionary = world.neighborhood.LOCATIONS[i]
  var at: Vector3 = location.at
  var point := center + Vector2(at.x, at.z) * MAP_SIZE / 250.0
  draw_circle(point, 12, Color("24383f"))
  draw_string(font, point + Vector2(-4, 5), str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)
 var position: Vector3 = world.player.global_position
 if world.current_location != &"outside":
  position = world.neighborhood.markers[world.current_location].global_position
 var player_point := center + Vector2(position.x, position.z) * MAP_SIZE / 250.0
 draw_circle(player_point, 7, Color("ffcf73"))
 draw_arc(player_point, 10, 0, TAU, 24, Color("25363a"), 2)
 draw_string(font, MAP_ORIGIN + Vector2(4, 18), "N ↑", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("24383f"))
