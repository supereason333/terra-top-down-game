extends Node2D
class_name ItemPickup

var item:Item2D

func _ready() -> void:
	if !item:
		queue_free()
		return

func _on_interact_area_interacted(player: Player) -> void:
	var inv := player.get_inventory()
	inv.add_item(item)
	queue_free()
