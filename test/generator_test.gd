extends Node2D

@onready var tile_map: TileMapLayer = $TileMapLayer

@export var draw_interval := 0.01
const ROOM_SCALE := 5

var level: LevelData
var rooms_drawn := 0

func _ready() -> void:
	level = WorldGenerator.generate_level(23232)
	for x in level.world_tiles.size():
		for y in level.world_tiles[x].size():
			if level.world_tiles[x][y]:
				tile_map.set_cell(Vector2i(x, y), 0, Vector2i(1, 0))
	_reveal_rooms()

func _reveal_rooms() -> void:
	for i in level.rooms.size():
		rooms_drawn = i + 1
		queue_redraw()
		await get_tree().create_timer(draw_interval).timeout

func _draw() -> void:
	if level == null:
		return
	for i in rooms_drawn:
		var room: Rect2 = Rect2(level.rooms[i].position * ROOM_SCALE, level.rooms[i].size * ROOM_SCALE)
		draw_rect(room, Color.WHITE, false)
