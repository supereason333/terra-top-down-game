extends ColorRect

const RECT_SIZE = 1

func _ready() -> void:
	GameMngr.get_world().loaded_new_level.connect(_on_new_level)
	queue_redraw()

func _on_new_level(_pos:PackedInt32Array):
	queue_redraw()

func _draw() -> void:
	var world := GameMngr.get_world()
	if !world: return

	for x in world.current_level_data.world_tiles.size():
		for y in world.current_level_data.world_tiles[x].size():
			if world.current_level_data.world_tiles[x][y]:
				var rect = Rect2i(x * RECT_SIZE, y * RECT_SIZE, RECT_SIZE, RECT_SIZE)
				draw_rect(rect, Color.WHITE)

	size = Vector2(
		world.current_level_data.world_tiles.size() * RECT_SIZE,
		world.current_level_data.world_tiles[0].size() * RECT_SIZE
	)
