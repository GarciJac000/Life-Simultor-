extends Node3D

@export var location_id: StringName = &"apartment"
var exit_marker: InteractionComponent

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
 if location_id == &"apartment":
  Blockout.box(self, Vector3(-5, 0.5, -4), Vector3(3, 1, 4), Color("7b9294"))
  Blockout.box(self, Vector3(5, 0.8, -5), Vector3(4, 1.6, 1.6), Color("91846c"))
 else:
  Blockout.box(self, Vector3(0, 1, -5), Vector3(12, 2, 1.5), Color("84715d"))
  for x in [-5, 5]:
   Blockout.box(self, Vector3(x, 0.65, 0), Vector3(2, 1.3, 2), Color("b5a484"))
 Blockout.sign_text(self, Vector3(0, 3.2, -6), "APARTMENT / BLOCKOUT" if location_id == &"apartment" else "CAFE / BLOCKOUT")
 exit_marker = InteractionComponent.new()
 exit_marker.location_id = &"exit"
 exit_marker.display_name = "BACK TO NEIGHBORHOOD"
 exit_marker.action_text = "Exit"
 exit_marker.destination = &"outside"
 exit_marker.position = Vector3(0, 0, 5.5)
 add_child(exit_marker)
