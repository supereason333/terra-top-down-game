extends Resource
class_name TileDataResource

@export var display_name:String = "Tile"
@export var id:StringName

# Stuff to be set by TileLibrary at runtime
var source_id:PackedInt32Array
var atlas_coords:Array[Vector2i]
var alternate_id:PackedInt32Array
