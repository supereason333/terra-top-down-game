extends Node
class_name EntityMovement

@onready var entity:RigidBody2D = $".."

@export var follow_radius := 6.0
var follow_radius_sq:
	get(): return follow_radius * follow_radius
@export var tracking_lose_radius := 8.0
var tracking_lose_radius_sq:
	get(): return tracking_lose_radius * tracking_lose_radius
@export var speed := 30.0
@export var force := 10.0
@export var close_enough := 3.0
var close_enough_sq:
	get(): return close_enough * close_enough

var world:World

## Path in world coords to follow if any
## i = 0 is first point, ; > i is next
var path:PackedVector2Array
## curr point in path arr
var tracking_point:int = -1

func _ready() -> void:
	world = GameMngr.get_world()
	if !world:
		printerr("Entity Movement cannot get world")

func set_path(p:PackedVector2Array):
	path = p
	# print("Path set to:")
	# print(path)
	world.draw_path(path)
	tracking_point = -1

func set_target(targ:Vector2):
	var from:Vector2i = world.tilemap.local_to_map(entity.position)
	var to:Vector2i = world.tilemap.local_to_map(targ)
	var new:PackedVector2Array = world.astar.get_point_path(from, to)
	for i in new.size():
		new[i] += Vector2(6, 6)

	set_path(new)

func clear_path():
	path.clear()
	world.draw_path(path)

func _physics_process(_delta: float) -> void:
	if path.is_empty(): return

	if tracking_point == -1:
		var closest_point := get_closest_point(entity.position)
		if entity.position.distance_squared_to(path[closest_point]) <= follow_radius_sq:
			tracking_point = closest_point
			return
		move_to(path[closest_point])
		return

	var after := tracking_point + 1
	if after >= path.size():
		if entity.position.distance_squared_to(path[tracking_point]) <= close_enough_sq:
			path.clear()
			tracking_point = -1
			return
		move_to(path[tracking_point])
		return

	if entity.position.distance_squared_to(path[after]) <= follow_radius_sq:
		tracking_point += 1
		after += 1
		if after >= path.size():
			move_to(path[tracking_point])
			return

	var seg_closest := Geometry2D.get_closest_point_to_segment(
		entity.position, path[tracking_point], path[after])
	if entity.position.distance_squared_to(seg_closest) > tracking_lose_radius_sq:
		tracking_point = -1
		return

	var intersections := circle_line_intersections(
		path[tracking_point],
		path[after],
		entity.position,
		follow_radius)

	var track_to: Vector2
	if intersections.is_empty():
		track_to = seg_closest
	elif intersections.size() == 1:
		track_to = intersections[0]
	elif intersections[1].distance_squared_to(path[after]) < intersections[0].distance_squared_to(path[after]):
		track_to = intersections[1]
	else:
		track_to = intersections[0]

	move_to(track_to)


func move_to(point:Vector2):
	var pos_error := point - entity.position
	if pos_error.length_squared() <= close_enough_sq: return
	var targ_velocity := pos_error.normalized() * speed
	var velocity_error := targ_velocity - entity.linear_velocity
	velocity_error = velocity_error.limit_length(force)

	entity.apply_central_force(velocity_error)

func get_closest_point(pos:Vector2) -> int:
	var best:int
	var dist:float = INF
	var i = 0
	for point in path:
		var dist_to = point.distance_squared_to(pos)
		if dist_to < dist:
			dist = dist_to
			best = i

		i += 1

	return best

func circle_line_intersections(a: Vector2, b: Vector2, c: Vector2, r: float, segment_only: bool = true) -> Array[Vector2]:
	var d := b - a
	var f := a - c
	var qa := d.dot(d)
	var qb := 2.0 * f.dot(d)
	var qc := f.dot(f) - r * r
	var result: Array[Vector2] = []

	if is_zero_approx(qa):
		return result

	var disc := qb * qb - 4.0 * qa * qc
	if disc < 0.0:
		return result

	var ts: Array[float] = []
	if is_zero_approx(disc):
		ts.append(-qb / (2.0 * qa))
	else:
		var s := sqrt(disc)
		ts.append((-qb - s) / (2.0 * qa))
		ts.append((-qb + s) / (2.0 * qa))

	for t in ts:
		if segment_only and (t < 0.0 or t > 1.0):
			continue
		result.append(a + t * d)
		return result
	return result
