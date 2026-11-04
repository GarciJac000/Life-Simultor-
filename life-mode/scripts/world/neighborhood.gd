extends Node3D

const LOCATIONS: Array[Dictionary] = [
 {"id": &"apartment", "title": "01 / APARTMENT", "at": Vector3(-34, 0, -32), "color": Color("bd967c")},
 {"id": &"cafe", "title": "02 / CAFE", "at": Vector3(34, 0, -32), "color": Color("c9ab71")},
 {"id": &"market", "title": "03 / CORNER MARKET", "at": Vector3(-34, 0, 34), "color": Color("8b9d89")},
 {"id": &"studio", "title": "04 / MUSIC STUDIO", "at": Vector3(34, 0, 34), "color": Color("8b92a5")},
 {"id": &"park", "title": "05 / PUBLIC PARK", "at": Vector3(-83, 0, -26), "color": Color("92ab82")},
 {"id": &"gym", "title": "06 / GYM COURTYARD", "at": Vector3(83, 0, -26), "color": Color("ba8f76")}
]
const ENTERABLE: Array[StringName] = [&"apartment", &"cafe", &"market", &"studio"]
const OUTDOOR_ACTIONS := {
 &"park": &"hang_out",
 &"gym": &"exercise"
}
var markers: Dictionary = {}

func _ready() -> void:
 Blockout.box(self, Vector3(0, -0.5, 0), Vector3(250, 1, 250), Color("6f7669"), true, &"soil")
 Blockout.box(self, Vector3(0, 0.012, 0), Vector3(14, 0.02, 248), Color("2c3034"), false, &"asphalt")
 Blockout.box(self, Vector3(0, 0.014, 0), Vector3(248, 0.02, 14), Color("2c3034"), false, &"asphalt")
 for side in [-1, 1]:
  Blockout.box(self, Vector3(side * 10, 0.02, 0), Vector3(5, 0.02, 248), Color("d0cbb8"), false, &"concrete")
  Blockout.box(self, Vector3(0, 0.02, side * 10), Vector3(248, 0.02, 5), Color("d0cbb8"), false, &"concrete")
  Blockout.box(self, Vector3(side * 125, 1.5, 0), Vector3(1, 3, 251), Color("6f7c72"), true, &"concrete")
  Blockout.box(self, Vector3(0, 1.5, side * 125), Vector3(249, 3, 1), Color("6f7c72"), true, &"concrete")
 for offset in range(-115, 120, 10):
  if abs(offset) > 12:
   Blockout.box(self, Vector3(0, 0.035, offset), Vector3(0.22, 0.02, 4), Color("dfd5a5"), false, &"concrete")
   Blockout.box(self, Vector3(offset, 0.035, 0), Vector3(4, 0.02, 0.22), Color("dfd5a5"), false, &"concrete")
 for location in LOCATIONS:
  var at: Vector3 = location.at
  var id: StringName = location.id
  if id in [&"park", &"gym"]:
   build_courtyard(at, location.color, id == &"park")
  else:
   Blockout.box(self, at + Vector3(0, 5, 0), Vector3(22, 10, 20), location.color, true, &"plaster")
   Blockout.box(self, at + Vector3(0, 10.3, 0), Vector3(23, 0.6, 21), Color("586568"), true, &"metal")
   Blockout.box(self, at + Vector3(0, 1.8, 10.08), Vector3(2.6, 3.6, 0.12), Color("334a51"), false, &"metal")
   for x in [-7, 7]:
    for y in [3, 7]:
     Blockout.box(self, at + Vector3(x, y, 10.1), Vector3(3, 2, 0.15), Color("c4d6d0"), false, &"glass")
  var marker := InteractionComponent.new()
  marker.location_id = id
  marker.display_name = location.title
  if id in ENTERABLE:
   marker.destination = id
   marker.action_text = "Enter"
  elif OUTDOOR_ACTIONS.has(id):
   marker.action_id = OUTDOOR_ACTIONS[id]
   marker.action_text = "Start"
  else:
   marker.action_text = "Inspect"
  marker.position = at + Vector3(0, 0, 13)
  add_child(marker)
  markers[id] = marker
 for x in [-100, -67, 67, 100]:
  for z in [-94, 92]:
   Blockout.box(self, Vector3(x, 4, z), Vector3(18, 8, 16), Color("9b6a55"), true, &"brick")
 Blockout.sign_text(self, Vector3(0, 7, -110), "LIFE//MODE  /  NORTH DISTRICT", 64)
 VisualPolish.decorate_neighborhood(self, LOCATIONS)

func build_courtyard(at: Vector3, color: Color, park: bool) -> void:
 Blockout.box(self, at + Vector3(0, 0.03, 0), Vector3(28, 0.04, 28), color, false, &"grass" if park else &"concrete")
 for x in [-9, 9]:
  if park:
   Blockout.box(self, at + Vector3(x, 1, -4), Vector3(0.8, 2, 0.8), Color("756353"), true, &"wood")
   Blockout.box(self, at + Vector3(x, 3.4, -4), Vector3(5, 3, 5), Color("647f64"), true, &"grass")
  else:
   Blockout.box(self, at + Vector3(x, 1.5, -4), Vector3(0.3, 3, 0.3), Color("455e66"), true, &"metal")
 Blockout.box(self, at + Vector3(0, 0.55, -6), Vector3(6, 1.1, 1.2), Color("826e59"), true, &"wood")
 if not park:
  Blockout.box(self, at + Vector3(0, 3, -4), Vector3(18, 0.3, 0.3), Color("455e66"), true, &"metal")
