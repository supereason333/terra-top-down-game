extends Node

func get_world() -> World:
	for child in get_parent().get_children():
		if child is World: return child
	return null
