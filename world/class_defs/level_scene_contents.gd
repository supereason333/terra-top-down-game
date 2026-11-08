class_name LevelSceneContents

var base_tilemap:TileMapLayer
var mid_tilemap:TileMapLayer
var uppper_tilemap:TileMapLayer

var props:Array[Node2D]

var entities:Array[Entity]

var solid_mask:Array[PackedByteArray]	# wether the tile is solid or not; 1 is solid, 0 is not used for pathfinding
