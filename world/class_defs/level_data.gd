extends Resource
class_name LevelData

var level_size:Vector2i
var world_tiles:Array[PackedInt32Array]
var rooms:Array[Rect2i]

func _init(size:Vector2i):
	level_size = size
	world_tiles.resize(level_size.x)
	world_tiles.fill([])
	for x in world_tiles.size():
		world_tiles[x].resize(level_size.y)
