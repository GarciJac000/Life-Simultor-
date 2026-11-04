class_name MaterialLibrary
extends RefCounted
## Procedural PBR-ish materials with synchronous Image textures (OpenGL-safe).

static var _cache: Dictionary = {}

static func clear_cache() -> void:
 _cache.clear()

static func make(kind: StringName, tint: Color = Color.WHITE, roughness: float = 0.85, metallic: float = 0.0) -> StandardMaterial3D:
 var key := "%s|%s|%.2f|%.2f" % [String(kind), tint.to_html(), roughness, metallic]
 if _cache.has(key):
  return _cache[key]
 var mat := StandardMaterial3D.new()
 mat.albedo_color = tint
 mat.roughness = roughness
 mat.metallic = metallic
 mat.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
 mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
 mat.albedo_texture = _image_texture(kind)
 mat.uv1_scale = _uv_scale(kind)
 mat.uv1_triplanar = kind in [&"asphalt", &"concrete", &"plaster", &"grass", &"soil", &"brick"]
 mat.uv1_world_triplanar = true
 mat.uv1_triplanar_sharpness = 6.0
 if kind == &"glass":
  mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  mat.albedo_color = Color(tint.r, tint.g, tint.b, 0.45)
  mat.roughness = mini(roughness, 0.12)
  mat.metallic = maxf(metallic, 0.25)
 _cache[key] = mat
 return mat

static func _uv_scale(kind: StringName) -> Vector3:
 match kind:
  &"asphalt":
   return Vector3(22, 22, 22)
  &"concrete":
   return Vector3(12, 12, 12)
  &"plaster":
   return Vector3(7, 7, 7)
  &"grass":
   return Vector3(16, 16, 16)
  &"wood":
   return Vector3(4, 1.4, 4)
  &"brick":
   return Vector3(6, 6, 6)
  &"metal":
   return Vector3(5, 5, 5)
  _:
   return Vector3(9, 9, 9)

static func _image_texture(kind: StringName) -> ImageTexture:
 var cache_key := "img_%s" % String(kind)
 if _cache.has(cache_key):
  return _cache[cache_key]
 var size := 128
 var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
 var rng := RandomNumberGenerator.new()
 rng.seed = int(kind.hash())
 for y in size:
  for x in size:
   var color := _pixel(kind, x, y, size, rng)
   image.set_pixel(x, y, color)
 image.generate_mipmaps()
 var tex := ImageTexture.create_from_image(image)
 _cache[cache_key] = tex
 return tex

static func _pixel(kind: StringName, x: int, y: int, size: int, rng: RandomNumberGenerator) -> Color:
 var fx := float(x) / float(size)
 var fy := float(y) / float(size)
 var n := _hash_noise(x, y, int(kind.hash()))
 match kind:
  &"asphalt":
   var speck := 0.14 * _hash_noise(x * 3, y * 5, 11)
   var crack := 0.1 if int((x + y * 3) % 17) == 0 else 0.0
   return Color(0.1 + n * 0.16 + speck - crack, 0.11 + n * 0.14 - crack, 0.12 + n * 0.12 - crack)
  &"concrete":
   var grit := 0.12 * _hash_noise(x * 2, y * 2, 5)
   return Color(0.48 + n * 0.2 + grit, 0.47 + n * 0.18 + grit, 0.44 + n * 0.16)
  &"plaster":
   var fleck := 0.1 * _hash_noise(x * 4, y * 3, 9)
   return Color(0.72 + n * 0.14 + fleck, 0.68 + n * 0.12, 0.6 + n * 0.1)
  &"grass":
   var blade := absf(sin(fx * 64.0 + n * 8.0)) * 0.14
   var patch := 0.1 * _hash_noise(x / 4, y / 4, 2)
   return Color(0.18 + blade + patch, 0.36 + n * 0.18 + blade, 0.12 + patch)
  &"wood":
   var grain := absf(sin(fy * 55.0 + sin(fx * 8.0) * 2.0)) * 0.18
   return Color(0.42 + grain, 0.28 + grain * 0.6, 0.15 + grain * 0.3)
  &"brick":
   var brick_x := int(fx * 8.0)
   var brick_y := int(fy * 12.0)
   var mortar := 0.0
   if int(fx * 64.0) % 8 == 0 or int(fy * 96.0) % 8 == 0:
    mortar = 1.0
   var tone := 0.08 * _hash_noise(brick_x, brick_y, 3)
   if mortar > 0.5:
    return Color(0.78, 0.76, 0.72)
   return Color(0.55 + tone, 0.3 + tone * 0.4, 0.22)
  &"metal":
   var sheen := pow(n, 1.4) * 0.25
   return Color(0.4 + sheen, 0.43 + sheen, 0.46 + sheen)
  &"soil":
   return Color(0.3 + n * 0.1, 0.24 + n * 0.08, 0.16 + n * 0.05)
  &"glass":
   return Color(0.7, 0.82, 0.88, 0.55)
  _:
   return Color(0.5 + n * 0.2, 0.5 + n * 0.2, 0.5 + n * 0.2)

static func _hash_noise(x: int, y: int, seed: int) -> float:
 var n := x * 374761393 + y * 668265263 + seed * 1274126177
 n = (n ^ (n >> 13)) * 1274126177
 n = n ^ (n >> 16)
 return float(n & 0xffff) / 65535.0
