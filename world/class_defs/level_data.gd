# Data for levels, generated only if player goes to that level
extends Resource
class_name LevelData

var level_size:Vector2i
var world_tiles:Array[PackedInt32Array]
var rooms:Array[Rect2i]

func _init(size: Vector2i) -> void:
    level_size = size
    world_tiles.resize(size.x)
    for x in size.x:
        var column := PackedInt32Array()
        column.resize(size.y)
        world_tiles[x] = column
