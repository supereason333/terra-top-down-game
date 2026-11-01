extends Projectile

@export var max_length := 600.0
@export var max_bounces := 1
@export_flags_2d_physics var hit_mask := 0b1010
@export var width := 2.0
@export var color := Color.RED
@export var fade_time := 0.5

@export var end_gradient:GradientTexture2D
@export var join_gradient:GradientTexture2D

@export var light_energy := 2.0

var light_color:Color

var points := PackedVector2Array()  # local space to draw
var lights:Array[Light2D]

func _proj_init() -> void:
	light_color = color / max(color.r, color.g, color.b)
	await get_tree().physics_frame
	_fire()
	kill()

func _fire() -> void:
	var space := get_world_2d().direct_space_state
	var start := global_position
	var dir := Vector2.RIGHT.rotated(global_rotation)
	var remaining := max_length
	var bounces_left := max_bounces
	var exclude: Array[RID] = []

	points.append(Vector2.ZERO)

	while remaining > 0.0:
		var query := PhysicsRayQueryParameters2D.create(start, start + dir * remaining, hit_mask)
		query.exclude = exclude
		var hit := space.intersect_ray(query)

		if hit.is_empty():
			points.append(to_local(start + dir * remaining))
			break

		var hit_pos: Vector2 = hit.position
		points.append(to_local(hit_pos))
		remaining -= start.distance_to(hit_pos)

		if hit.collider is Entity:
			_damage(hit.collider)
			hits += 1
			if hits >= penetration:
				break
			exclude.append(hit.rid)  # pass through this enemy
			start = hit_pos
		else:
			if bounces_left <= 0:
				break
			bounces_left -= 1
			dir = dir.bounce(hit.normal)
			start = hit_pos + hit.normal * 0.1

	add_lights()
	queue_redraw()

func add_lights():
	for i in points.size() - 1:
		var start := points[i]
		var end := points[i + 1]
		var dist = start.distance_to(end)
		var segment := Node2D.new()
		var start_light := PointLight2D.new()
		start_light.texture = end_gradient
		start_light.position.x = -16
		start_light.rotation_degrees = 180
		start_light.energy = light_energy
		start_light.color = light_color
		var end_light := PointLight2D.new()
		end_light.texture = end_gradient
		end_light.position.x = dist + 16
		end_light.energy = light_energy
		end_light.color = light_color
		var segment_light := PointLight2D.new()
		segment_light.texture = join_gradient
		segment_light.scale.x = dist
		segment_light.position.x = dist / 2
		segment_light.energy = light_energy
		segment_light.color = light_color
		segment.add_child(start_light)
		segment.add_child(end_light)
		segment.add_child(segment_light)
		segment.position = start
		segment.rotation = start.angle_to_point(end)
		add_child(segment)

		lights.append(start_light)
		lights.append(end_light)
		lights.append(segment_light)

func _damage(entity: Entity) -> void:
	if entity.health_node:
		entity.health_node.damage(base_damage)

func _draw() -> void:
	if points.size() >= 2:
		draw_polyline(points, color, width)

func _kill() -> void:
	var tween := create_tween()
	tween.tween_method(set_alpha, 1.0, 0.0, fade_time)
	tween.tween_callback(queue_free)

func set_alpha(a:float):
	modulate.a = a
	for light in lights:
		light.energy = a * light_energy
