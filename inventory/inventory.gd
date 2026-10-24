extends Node
class_name Inventory

signal item_added(item:Item2D)
signal item_removed(item:Item2D)
signal equipped_changed(slot_new:int, slot_old:int)
signal items_changed

@export var preload_inv:Array[StringName]
@export var equip_0:bool = false
@export var equip_point:EquipPoint

var inv:Array[Item2D]
var equipped:int = -1

func _ready() -> void:
	for item in preload_inv:
		var itm := ItemMngr.get_item_node(item)
		if itm:
			inv.append(itm)
		else:
			print_debug("Item get node null")
	# print("SIGNAL")
	items_changed.emit()
	if equip_0:
		set_equipped(0)

func set_equipped(slot:int):
	if slot == -1:
		equip_point.unequip()
		equipped_changed.emit(-1, equipped)
		equipped = -1
	if slot < 0 or slot >= inv.size(): return
	if slot == equipped: return
	equip_point.equip(inv[slot])
	equipped_changed.emit(slot, equipped)
	equipped = slot
