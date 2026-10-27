@tool
extends PointLight2D

@export var sector_angle := 90.0
@export var feather_deg := 5.0
@export var tex_size := 256
@export var update := false:
	set(value):
		bake_texture(sector_angle, feather_deg)

func _ready() -> void:
	texture = load_tex()

func load_tex() -> ImageTexture:
	return ResourceLoader.load("res://player/point_light_tex.res")

func bake_texture(angle_deg: float, feather: float):
	var img := Image.create(tex_size, tex_size, false, Image.FORMAT_RGBA8)
	var half_w := deg_to_rad(angle_deg) * 0.5
	var feather_rad := maxf(deg_to_rad(feather), 0.0001)
	var c := Vector2(tex_size, tex_size) * 0.5
	for y in tex_size:
		for x in tex_size:
			var p := (Vector2(x + 0.5, y + 0.5) - c) / c  # -1..1
			var diff := absf(angle_difference(0.0, p.angle()))
			var mask := 1.0 - smoothstep(half_w, half_w + feather_rad, diff)
			var falloff := clampf(1.0 - p.length(), 0.0, 1.0)
			var v := mask * falloff
			img.set_pixel(x, y, Color(v, v, v, v))
	var tex := ImageTexture.create_from_image(img)

	ResourceSaver.save(tex, "res://player/point_light_tex.res")
