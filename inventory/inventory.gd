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
			for i in preload_inv[item]:
				add_item(itm.duplicate())
		else:
			print_debug("Item get node null")
		itm.free()	# stupid

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
	if inv.size() <= reserved_slots:
		if inv.size() < reserved_slots:
			inv.resize(reserved_slots)
		inv.append(new)
		items_changed.emit()
		return true

	inv.append(new)
	items_changed.emit()
	return true

func swap_item(a:int, b:int):
	if a < 0 or a >= inv.size(): return
	if b < 0 or b >= inv.size(): return

	var a_item := inv[a]
	inv[a] = inv[b]
	inv[b] = a_item

	items_changed.emit()

func take_item(slot:int) -> Item2D:
	if slot < 0 or slot >= inv.size(): return null
	if slot >= reserved_slots:
		var itm = inv.pop_at(slot)
		items_changed.emit()
		return itm

	var item = inv[slot]
	inv[slot] = null
	items_changed.emit()
	return item



func find_item(id:StringName, in_reserved:bool = false) -> int:
	var r:Array
	if inv.size() < reserved_slots: inv.resize(reserved_slots)
	if in_reserved: r = range(0, inv.size())
	else: r = range(reserved_slots, inv.size())
	for i in r:
		if !inv[i]: continue
		if inv[i].id == id:
			return i
	return -1

func find_item_class(item:Item2D, in_reserved:bool = false) -> int:
	var r:Array
	if inv.size() < reserved_slots: inv.resize(reserved_slots)
	if in_reserved: r = range(0, inv.size())
	else: r = range(reserved_slots, inv.size())
	for i in r:
		if inv[i] == item:
			return i
	return -1
