extends Node
class_name Inventory

@export var preload_inv:Array[StringName]
@export var equip_0:bool = false
@export var equip_point:EquipPoint

var inv:Array[Item2D]

func _ready() -> void:
	for item in preload_inv:
		var itm := ItemMngr.get_item_node(item)
		if itm:
			inv.append(itm)
		else:
			print_debug("Item get node null")
	if equip_0:
		change_equipped(0)

func change_equipped(slot:int):
	if slot < 0 or slot >= inv.size(): return
	equip_point.equip(inv[slot])
