extends Node3D

@export var location_id: StringName = &"apartment"
var exit_marker: InteractionComponent
var stations: Array[InteractionComponent] = []

func _ready() -> void:
 var wall := Color("c9c4b4")
 Blockout.box(self, Vector3(0, -0.5, 0), Vector3(18, 1, 16), Color("a28e76"))
 Blockout.box(self, Vector3(0, 2, -8), Vector3(18, 4, 0.4), wall)
 for x in [-9, 9]:
  Blockout.box(self, Vector3(x, 2, 0), Vector3(0.4, 4, 16), wall)
 for x in [-5.3, 5.3]:
  Blockout.box(self, Vector3(x, 2, 8), Vector3(7.4, 4, 0.4), wall)
 Blockout.box(self, Vector3(0, 3.6, 8), Vector3(3.2, 0.8, 0.4), wall)
 # A physical threshold barrier keeps the portal as the only route out.
 Blockout.box(self, Vector3(0, 1, 8), Vector3(3.2, 2, 0.25), Color("455e66"))
 match location_id:
  &"apartment":
   Blockout.box(self, Vector3(-5, 0.5, -4), Vector3(3, 1, 4), Color("7b9294"))
   Blockout.box(self, Vector3(5, 0.8, -5), Vector3(4, 1.6, 1.6), Color("91846c"))
   Blockout.sign_text(self, Vector3(0, 3.2, -6), "APARTMENT / NORTH DISTRICT")
   _station(&"sleep", "BED / SLEEP", "Sleep", Vector3(-5, 0, -1))
   _station(&"eat_home", "KITCHEN / EAT", "Eat", Vector3(5, 0, -1))
   _station(&"shower", "SHOWER", "Shower", Vector3(-5, 0, 3))
  &"cafe":
   Blockout.box(self, Vector3(0, 1, -5), Vector3(12, 2, 1.5), Color("84715d"))
   for x in [-5, 5]:
    Blockout.box(self, Vector3(x, 0.65, 0), Vector3(2, 1.3, 2), Color("b5a484"))
   Blockout.sign_text(self, Vector3(0, 3.2, -6), "CAFE / OPEN")
   _station(&"work_cafe", "BARISTA COUNTER", "Work shift", Vector3(-4, 0, -1))
   _station(&"eat_cafe", "CAFE MENU", "Order meal", Vector3(4, 0, -1))
  &"market":
   Blockout.box(self, Vector3(0, 1.1, -4), Vector3(10, 2.2, 2), Color("7f8a74"))
   Blockout.box(self, Vector3(-4, 0.7, 1), Vector3(3, 1.4, 2), Color("b7a57f"))
   Blockout.sign_text(self, Vector3(0, 3.2, -6), "CORNER MARKET")
   _station(&"buy_groceries", "GROCERY AISLE", "Buy groceries", Vector3(0, 0, -1))
   _station(&"work_market", "STOCK DESK", "Work shift", Vector3(4, 0, 2))
  &"studio":
   Blockout.box(self, Vector3(0, 1.2, -4), Vector3(8, 2.4, 3), Color("6d7588"))
   Blockout.box(self, Vector3(-4, 0.6, 1), Vector3(2.5, 1.2, 2.5), Color("9aa0ad"))
   Blockout.sign_text(self, Vector3(0, 3.2, -6), "MUSIC STUDIO")
   _station(&"make_music", "PRACTICE BOOTH", "Make music", Vector3(-3, 0, -1))
   _station(&"work_studio", "ASSISTANT DESK", "Work shift", Vector3(3, 0, 1))
  _:
   Blockout.sign_text(self, Vector3(0, 3.2, -6), String(location_id).to_upper())
 VisualPolish.decorate_interior(self, location_id)
 exit_marker = InteractionComponent.new()
 exit_marker.location_id = &"exit"
 exit_marker.display_name = "BACK TO NEIGHBORHOOD"
 exit_marker.action_text = "Exit"
 exit_marker.destination = &"outside"
 exit_marker.position = Vector3(0, 0, 5.5)
 add_child(exit_marker)

func _station(action: StringName, title: String, verb: String, at: Vector3) -> void:
 var marker := InteractionComponent.new()
 marker.location_id = location_id
 marker.display_name = title
 marker.action_text = verb
 marker.action_id = action
 marker.position = at
 add_child(marker)
 stations.append(marker)
