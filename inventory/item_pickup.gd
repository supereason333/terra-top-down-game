extends Node2D
class_name ItemPickup

var item:Item2D

func _ready() -> void:
	if !item:
		queue_free()
		return
	add_child(item)

func _on_interact_area_interacted(player: Player) -> void:
	var inv := player.get_inventory()
	if inv.add_item(item):
		remove_child(item)
		queue_free()
