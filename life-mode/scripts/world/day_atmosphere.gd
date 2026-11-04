class_name DayAtmosphere
extends Node
## Soft sun/sky response to the in-game clock (visual only).

var sun: DirectionalLight3D
var environment: Environment
var fill: DirectionalLight3D

func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 call_deferred("_bind")

func _bind() -> void:
 var world := get_parent()
 sun = world.get_node_or_null("Sun")
 fill = world.get_node_or_null("FillLight")
 var env_node: WorldEnvironment = world.get_node_or_null("WorldEnvironment")
 if env_node:
  environment = env_node.environment
 if not WorldClock.clock_advanced.is_connected(_on_clock):
  WorldClock.clock_advanced.connect(_on_clock)
 _apply(WorldClock.hour(), WorldClock.minute())

func _on_clock(_from_minute: int, _to_minute: int) -> void:
 _apply(WorldClock.hour(), WorldClock.minute())

func _process(_delta: float) -> void:
 # Keep atmosphere in sync even when only realtime minutes advance gradually.
 _apply(WorldClock.hour(), WorldClock.minute())

func _apply(hour: int, minute: int) -> void:
 if sun == null:
  return
 var t := float(hour) + float(minute) / 60.0
 var day_factor := 1.0
 var sun_color := Color(1.0, 0.93, 0.82)
 var energy := 1.35
 if t < 6.0 or t >= 21.0:
  day_factor = 0.15
  sun_color = Color(0.35, 0.45, 0.75)
  energy = 0.25
 elif t < 8.0:
  var k := (t - 6.0) / 2.0
  day_factor = lerpf(0.15, 1.0, k)
  sun_color = Color(1.0, 0.72, 0.48).lerp(Color(1.0, 0.93, 0.82), k)
  energy = lerpf(0.35, 1.35, k)
 elif t >= 18.0:
  var k2 := (t - 18.0) / 3.0
  day_factor = lerpf(1.0, 0.2, clampf(k2, 0.0, 1.0))
  sun_color = Color(1.0, 0.93, 0.82).lerp(Color(1.0, 0.45, 0.28), clampf(k2, 0.0, 1.0))
  energy = lerpf(1.35, 0.4, clampf(k2, 0.0, 1.0))
 sun.light_color = sun_color
 sun.light_energy = energy
 sun.rotation_degrees = Vector3(-lerp(8.0, 55.0, day_factor), -28.0 - t * 2.0, 0.0)
 if fill:
  fill.light_energy = lerpf(0.08, 0.35, day_factor)
 if environment:
  environment.ambient_light_energy = lerpf(0.28, 0.72, day_factor)
  environment.fog_light_color = Color(0.45, 0.5, 0.65).lerp(Color(0.78, 0.82, 0.88), day_factor)
  if environment.sky and environment.sky.sky_material is ProceduralSkyMaterial:
   var sky_mat: ProceduralSkyMaterial = environment.sky.sky_material
   sky_mat.sky_top_color = Color(0.05, 0.08, 0.18).lerp(Color(0.23, 0.45, 0.72), day_factor)
   sky_mat.sky_horizon_color = Color(0.25, 0.2, 0.35).lerp(Color(0.82, 0.78, 0.72), day_factor)
