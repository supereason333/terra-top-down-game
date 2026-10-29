# stores data for a whole world like each level and stuff
extends Resource
class_name WorldData

var world_seed:int

func _init(_seed:int) -> void:
	world_seed = _seed
