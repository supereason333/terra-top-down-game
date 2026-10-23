extends Node2D
class_name World

@onready var projectiles:Node2D = $Projectiles
@onready var tilemap:TileMapLayer = $TileMapLayer

@onready var enemy_movement:EntityMovement = $BasicEnemy/EntityMovement

var astar := AStarGrid2D.new()


var path:PackedVector2Array

var other_path:PackedVector2Array

func _ready() -> void:
	setup_astar()

	enemy_movement.set_target(Vector2(0, 0))

func setup_astar():
	var used_rect: Rect2i = tilemap.get_used_rect()
	astar.region = used_rect
	astar.cell_size = tilemap.tile_set.tile_size
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER # Adjust as needed
	astar.update()

	for cell in tilemap.get_used_cells():
		var source_id := tilemap.get_cell_source_id(cell)
		if source_id == -1: continue
		var tile := tilemap.get_cell_tile_data(cell)
		if tile == null: continue
		if tile.get_collision_polygons_count(0) > 0:
			astar.set_point_solid(cell)

func register_projectile(proj:Projectile):
	projectiles.add_child(proj)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var tilemap_end:Vector2i = tilemap.local_to_map(tilemap.get_local_mouse_position())
			if path.is_empty():
				path.append(tilemap_end)
			else:
				path = astar.get_point_path(tilemap.local_to_map(path[path.size() - 1]), tilemap_end)
				print(path)
				queue_redraw()

func _draw() -> void:
	var i = 0
	for point in path:
		point += Vector2(6, 6)
		draw_circle(point, 2, Color.WHITE)
		if i > 0:
			draw_line(point, path[i - 1] + Vector2(6, 6), Color.WHITE)

		i += 1

	i = 0
	for point in other_path:
		# point += Vector2(6, 6)
		draw_circle(point, 2, Color.WHITE)
		if i > 0:
			draw_line(point, other_path[i - 1], Color.WHITE)

		i += 1

func draw_path(p:PackedVector2Array):
	other_path = p
	queue_redraw()
