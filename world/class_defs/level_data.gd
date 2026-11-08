# Data for levels, generated only if player goes to that level
extends Resource
class_name LevelData

var level_size:Vector2i

var base_tiles:Array[PackedInt32Array]	# main tiles like walls and floors
var mid_tiles:Array[PackedInt32Array]	# little details between the world tiles and non functional tiles like stains etc
var upper_tiles:Array[PackedInt32Array]	# functional stuff like chests
var solid_mask:Array[PackedByteArray]	# wether the tile is solid or not; 1 is solid, 0 is not

var props:Array[StringName]
var prop_positions:Array[Vector2i]
var prop_data:Dictionary[int, PropDataResource]

var entities:Array[StringName]
var entity_positions:PackedVector2Array

# var rooms:Array[RoomData]	# dont think i need room data, for like non-room levels just need tiles
# generator should output the same type so world builder can build any world generated yk

var spawn_pos:Vector2
var teleport_thing_pos:Vector2

func _init(size: Vector2i) -> void:
	level_size = size
	base_tiles.resize(size.x)
	mid_tiles.resize(size.x)
	upper_tiles.resize(size.x)
	for x in size.x:
		base_tiles[x] = PackedInt32Array()
		mid_tiles[x] = PackedInt32Array()
		upper_tiles[x] = PackedInt32Array()
		base_tiles[x].resize(size.y)
		mid_tiles[x].resize(size.y)
		upper_tiles[x].resize(size.y)
