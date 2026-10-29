# Data thats generated and displayed on the map
extends Resource
class_name LevelDisplayData

var position:PackedInt32Array

func _init(pos:PackedInt32Array) -> void:
	position = pos
