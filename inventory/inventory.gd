extends Node
class_name Inventory

signal equipped_changed(slot_new:int, slot_old:int)
signal items_changed

@export var preload_inv:Dictionary[StringName, int]
@export var equip_0:bool = false
@export var equip_point:EquipPoint

var inv:Array[Item2D]
var equipped:int = -1

func _ready() -> void:
	for item in preload_inv.keys():
		var itm:Item2D = ItemMngr.get_item_node(item)
		if itm:
			if itm.stackable:
				itm.amount = preload_inv[item]
			add_item(itm)
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

func add_item(new:Item2D):
	if new.unique or !new.stackable:
		inv.append(new)
		items_changed.emit()
		return
	for item in inv:
		if item.id == new.id and !item.unique:
			item.amount += new.amount
			items_changed.emit()
			return
	inv.append(new)
	items_changed.emit()

func take_item(slot:int, count:int = 0) -> Item2D:
	if slot < 0 or slot >= inv.size(): return null
	var item:Item2D = inv[slot]
	if count == 0 or item.amount <= count or !item.stackable:
		if equipped == slot:
			set_equipped(-1)
		inv.remove_at(slot)
		items_changed.emit()
		return item
	item.amount -= count

	var new:Item2D
	if item.unique:
		new = item.duplicate()
	else:
		new = ItemMngr.get_item_node(item.id)
	new.amount = count
	items_changed.emit()
	return new


func find_magazine() -> int:
	var i := 0
	for item in inv:
		if item.id == &"magazine":
			return i
		i += 1
	return -1

func take_magazine() -> Item2D:
	var slot := find_magazine()
	if slot == -1: return null
	return take_item(slot, 1)
