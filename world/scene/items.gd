extends Node2D
class_name ItemDropMngr

const ITEM_PICKUP = preload("uid://rk4bwjytop44")

func add_drop_from_id(id:StringName, pos:Vector2):
	var item = Global.item_library.get_item_node(id)
	if !item: return
	add_drop(item, pos)

func add_drop(item:Item2D, pos:Vector2):
	var pickup:ItemPickup = ITEM_PICKUP.instantiate()
	pickup.item = item
	pickup.position = pos
	get_tree().create_timer(120).timeout.connect(pickup.queue_free)	# queue old items for deletion
	add_child(pickup)

func clear_items():
	for child in get_children():
		child.queue_free()
