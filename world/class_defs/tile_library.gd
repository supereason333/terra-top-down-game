extends Resource
class_name TileLibrary

@export var library:Dictionary[int, TileDataResource]

var initilized := false

func initilize():
	for num_id in library.keys():
		library[num_id].num_id = num_id

	initilized = true

func id_from_num_id(id:int) -> StringName:
	return ""
