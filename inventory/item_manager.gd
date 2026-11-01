extends Node

@export var lib:Dictionary[StringName, InventoryItem]

func get_item_node(id:StringName) -> Item2D:
	var item:InventoryItem = lib.get(id)
	if item == null:
		return null
	var node:Item2D = item.item_scene.instantiate()
	node.id = id
	node.weight = item.item_weight
	node.size = item.item_size

	return node
