extends Resource
class_name PropLibrary

@export var lib:Dictionary[StringName, PropResource]

func get_prop_node(id:StringName) -> Node2D:
	var l:PropResource = lib.get(id)
	if !l: return null
	return l.scene.instantiate()

func initilise() -> void:
	pass
