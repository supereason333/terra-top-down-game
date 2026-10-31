extends Node
class_name Inventory

signal items_changed

@export var preload_inv:Dictionary[StringName, int]
@export var reserved_slots:int = 1

var inv:Array[Item2D]

func _ready() -> void:

	inv.resize(reserved_slots)

	for item in preload_inv.keys():
		var itm:Item2D = ItemMngr.get_item_node(item)
		if itm:
			if itm.stackable:
				itm.amount = preload_inv[item]
			add_item(itm)
		else:
			print_debug("Item get node null")

# Retursn weather added or not
# slot is for adding to reserved slots
func add_item(new:Item2D, slot:int = -1) -> bool:
	if slot >= 0:
		if slot >= reserved_slots: return false
		# if already something, dont add
		if inv[slot]: return false
		inv[slot] = new
		items_changed.emit()
		return true
	# just append to inv, no items or not stackable
	if inv.size() <= reserved_slots or !new.stackable or new.unique:
		if inv.size() < reserved_slots:
			inv.resize(reserved_slots)
		inv.append(new)
		items_changed.emit()
		return true

	# search for same item to stack with
	for i in range(reserved_slots, inv.size()):
		if inv[i].id == new.id:
			inv[i].amount += new.amount
			items_changed.emit()
			return true

	inv.append(new)
	return true


func take_item(slot:int, count:int = 0) -> Item2D:
	if slot < 0 or slot >= inv.size(): return null
	if !inv[slot]:
		if slot >= reserved_slots:
			inv.remove_at(slot)
			items_changed.emit()
			return null
		return null
	if count <= 0 or count >= inv[slot].amount or !inv[slot].stackable:
		var parent:Node = inv[slot].get_parent()
		if parent:
			parent.remove_child(inv[slot])
		var itm := inv.pop_at(slot) as Item2D
		items_changed.emit()
		return itm
	inv[slot].amount -= count
	var item := ItemMngr.get_item_node(inv[slot].id)
	item.amount = count
	items_changed.emit()
	return item



func find_item(id:StringName, in_reserved:bool = false) -> int:
	var r:Array
	if inv.size() < reserved_slots: inv.resize(reserved_slots)
	if in_reserved: r = range(0, inv.size())
	else: r = range(reserved_slots, inv.size())
	for i in r:
		if inv[i].id == id:
			return i
	return -1
