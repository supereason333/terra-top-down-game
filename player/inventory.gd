extends Node
class_name Inventory

@export var preload_inv:Array[StringName]
@export var equip_point:Marker2D

var inv:Array[Item2D]

var equipped:Item2D

func _ready() -> void:
	for item in preload_inv:
		inv.append(ItemMngr.get_item_node(item))

	change_equipped(0)

func change_equipped(slot:int):
	if equipped:
		equipped.get_parent().remove_child(equipped)
	equipped = inv[slot]
	equip_point.add_child(equipped)
